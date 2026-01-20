from firebase_functions import scheduler_fn, params
from firebase_admin import initialize_app, firestore, messaging
import requests
import os
import time

initialize_app()

# Define the secret parameter (Ensure FMP_API_KEY is set in Firebase secrets)
FMP_API_KEY = params.SecretParam("FMP_API_KEY")

@scheduler_fn.on_schedule(schedule="every 1 hours", secrets=[FMP_API_KEY])
def check_price_alerts(event: scheduler_fn.ScheduledEvent) -> None:
    db = firestore.client()
    alerts_ref = db.collection("alerts").where("isActive", "==", True)
    docs = alerts_ref.stream()

    alerts = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        alerts.append(data)
    
    if not alerts:
        print("No active alerts.")
        return

    # Cache locally within this execution to avoid hitting API multiple times for same symbol
    # if multiple alerts track the same stock. But each Fetch is done INDIVIDUALLY.
    symbol_price_cache = {}

    for alert in alerts:
        symbol = alert['symbol']
        
        # Check cache first
        if symbol in symbol_price_cache:
            current_price = symbol_price_cache[symbol]
        else:
            # Fetch individually as requested (No batching)
            current_price = fetch_single_price(symbol)
            symbol_price_cache[symbol] = current_price # Store even if None to avoid re-fetching
            
            # Rate limiting / politeness sleep if needed (optional, keeping it simple for now)
            # time.sleep(0.1) 

        if current_price is None:
            print(f"Skipping alert {alert['id']} for {symbol}: Could not fetch price.")
            continue
            
        target = alert['targetPrice']
        condition = alert['condition'] # 'above' or 'below'
        last_status = alert.get('lastStatus') # 'above', 'below', or None
        
        should_alert = False
        new_status = None
        
        # Logic: Trigger only when crossing the threshold (Change of status)
        if condition == 'above':
            if current_price > target:
                new_status = 'above'
                if last_status != 'above':
                    should_alert = True
            else:
                new_status = 'below'
                
        elif condition == 'below':
            if current_price < target:
                new_status = 'below'
                if last_status != 'below':
                    should_alert = True
            else:
                new_status = 'above'

        if should_alert:
            send_notification(alert, current_price)
        
        if new_status and new_status != last_status:
            db.collection("alerts").document(alert['id']).update({"lastStatus": new_status})

def fetch_single_price(symbol):
    """
    Fetches price for a SINGLE symbol using FMP's Quote API.
    No batching is performed.
    """
    try:
        # Fetching strictly for one symbol
        url = f"https://financialmodelingprep.com/stable/quote?symbol={symbol}&apikey={FMP_API_KEY.value}"
        resp = requests.get(url, timeout=10)
        
        if resp.status_code == 200:
            data = resp.json()
            if isinstance(data, list) and len(data) > 0:
                item = data[0]
                price = item.get('price')
                if price is not None:
                    return float(price)
            else:
                print(f"Empty or invalid data for {symbol}: {data}")
        else:
            print(f"Error fetching {symbol}: Status {resp.status_code}")
            
    except Exception as e:
        print(f"Exception fetching {symbol}: {e}")
        
    return None

def send_notification(alert, current_price):
    token = alert.get('fcmToken')
    if not token: 
        return
    
    diff = current_price - alert['targetPrice']
    condition_text = "exceeded" if diff > 0 else "dropped below"
    
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"Price Alert: {alert['symbol']}",
            body=f"{alert['symbol']} has {condition_text} your target of ${alert['targetPrice']:.2f}. Current: ${current_price:.2f}"
        ),
        token=token,
    )
    try:
        response = messaging.send(message)
        print(f"Successfully sent message: {response}")
    except messaging.UnregisteredError:
        print(f"Token unregistered. Deleting alert {alert['id']}...")
        db = firestore.client()
        db.collection("alerts").document(alert['id']).delete()
    except messaging.SenderIdMismatchError: 
         print(f"Sender ID mismatch for alert {alert['id']}.")
    except Exception as e:
        print(f"Error sending FCM: {e}")