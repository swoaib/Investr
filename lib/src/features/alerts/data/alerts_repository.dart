import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../domain/stock_alert.dart';

class AlertsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> createAlert(StockAlert alert) async {
    try {
      // 1. Request Notification Permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        throw Exception('Notification permission denied');
      }

      // 2. Get FCM Token
      // 2. Get FCM Token (Wait for APNS on iOS)
      String? token;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          // Wait up to 3 seconds for APNS token
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await _messaging.getAPNSToken();
          }
        }
        if (apnsToken != null) {
          token = await _messaging.getToken();
        } else {
          debugPrint(
            'APNS Token not available. Notifications may not work on Simulator.',
          );
          // Attempt getToken anyway, though it may fail or be null
          try {
            token = await _messaging.getToken();
          } catch (e) {
            debugPrint('Failed to get FCM token without APNS: $e');
          }
        }
      } else {
        token = await _messaging.getToken();
      }

      // 3. Prepare Data
      final data = alert.toMap();
      data['fcmToken'] = token;
      // We also store 'lastStatus' to track if we've already triggered
      // Initialize it based on current logic, or null.
      data['lastStatus'] = null;

      // 4. Save to Firestore
      // distinct collection 'alerts' is easier for the Cloud Function to querying all
      await _firestore.collection('alerts').doc(alert.id).set(data);
    } catch (e) {
      debugPrint('Error creating alert: $e');
      rethrow;
    }
  }

  Stream<List<StockAlert>> getUserAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return StockAlert.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
