from firebase_functions import scheduler_fn, params
from firebase_admin import initialize_app, firestore, messaging
import requests
import os

initialize_app()

# Define the secret parameter (Ensure FMP_API_KEY is set in Firebase secrets)
FMP_API_KEY = params.SecretParam("FMP_API_KEY")

@scheduler_fn.on_schedule(schedule="every 1 hours", secrets=[FMP_API_KEY])
def check_price_alerts(event: scheduler_fn.ScheduledEvent) -> None:
    db = firestore.client()
    alerts_ref = db.collection("alerts").where("isActive", "==", True)
    docs = alerts_ref.stream()

    alerts = []
    symbols = set()

    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        alerts.append(data)
        symbols.add(data['symbol'])
    
    if not symbols:
        print("No active alerts.")
        return

    # Fetch current prices for all symbols
    prices = fetch_prices(list(symbols))

    for alert in alerts:
        symbol = alert['symbol']
        current_price = prices.get(symbol)
        
        if current_price is None:
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
                # Trigger if we were NOT above previously (i.e. 'below' or None)
                if last_status != 'above':
                    should_alert = True
            else:
                new_status = 'below' # Reset state (arming the alert for next crossing)
                
        elif condition == 'below':
            if current_price < target:
                new_status = 'below'
                # Trigger if we were NOT below previously
                if last_status != 'below':
                    should_alert = True
            else:
                new_status = 'above' # Reset state

        if should_alert:
            send_notification(alert, current_price)
        
        # Update status if changed
        if new_status and new_status != last_status:
            db.collection("alerts").document(alert['id']).update({"lastStatus": new_status})

def fetch_prices(symbols):
    """
    Fetches prices for a list of symbols using FMP's Quote API.
    """
    prices = {}
    
    # Remove duplicates and filter empty
    unique_symbols = [s for s in set(symbols) if s]
    if not unique_symbols:
        return prices

    # Chunk symbols into groups of 50 to avoid URL length limits
    # FMP can handle more, but 50 is a safe batch size
    chunk_size = 50
    for i in range(0, len(unique_symbols), chunk_size):
        chunk = unique_symbols[i:i + chunk_size]
        tickers_param = ",".join(chunk)
        
        try:
            # Use FMP Stable Quote API (Preferred over v3 legacy)
            # URL Structure: https://financialmodelingprep.com/stable/quote?symbol=AAPL,MSFT&apikey=...
            url = f"https://financialmodelingprep.com/stable/quote?symbol={tickers_param}&apikey={FMP_API_KEY.value}"
            resp = requests.get(url, timeout=10)
            
            if resp.status_code == 200:
                data = resp.json()
                # FMP returns a list of dictionaries
                if isinstance(data, list):
                    for item in data:
                        symbol = item.get('symbol')
                        price = item.get('price')
                        
                        if symbol and price is not None:
                            prices[symbol] = float(price)
                else:
                    print(f"Unexpected FMP response format for chunk {chunk}: {data}")
            else:
                print(f"Error fetching quotes for chunk: Status {resp.status_code}, {resp.text}")
                
        except Exception as e:
            print(f"Exception fetching prices for chunk {chunk}: {e}")
            
    return prices

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
        # Build logic to cleanup garbage tokens (e.g. 'InvalidArgument')
        # if "some_error_code" in str(e):
        #    db.collection("alerts").document(alert['id']).delete()