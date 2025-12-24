import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketDataService {
  final String apiKey;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _updateController =
      StreamController.broadcast();

  // Keep track of subscriptions to resubscribe on reconnect if needed
  final Set<String> _subscribedTickers = {};

  MarketDataService({required this.apiKey});

  Stream<Map<String, dynamic>> get updates => _updateController.stream;

  void connect() {
    if (_channel != null) return;

    try {
      if (kDebugMode) print('Connecting to Polygon WebSocket...');
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://socket.polygon.io/stocks'),
      );

      _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          if (kDebugMode) print('WebSocket Error: $error');
          _reconnect();
        },
        onDone: () {
          if (kDebugMode) print('WebSocket Closed');
          _reconnect();
        },
      );

      // Authenticate immediatley upon connection
      _send({'action': 'auth', 'params': apiKey});
    } catch (e) {
      if (kDebugMode) print('Connection failed: $e');
      _reconnect();
    }
  }

  void subscribe(List<String> tickers) {
    if (tickers.isEmpty) return;

    // Add to our local tracking set
    _subscribedTickers.addAll(tickers);

    if (_channel == null) {
      connect(); // Connect will trigger auth, but we need to wait for auth success to subscribe.
      // However, typical flow: Auth -> success -> Subscribe.
      // For simplicity, we send subscribe command. If auth isn't ready, it might fail,
      // but usually we can queue or just send.
      // Polygon usually requires Auth first.
      // We will handle subscription in _onMessage upon 'status':'auth_success'.
      return;
    }

    // Use aggregates (A) for efficient real-time updates (per second)
    // Detailed enough for viewing price changes as they happen.
    final params = tickers.map((t) => 'A.$t').join(',');
    _send({'action': 'subscribe', 'params': params});
    if (kDebugMode) print('Subscribing to: $params');
  }

  void _send(Map<String, dynamic> data) {
    try {
      final jsonStr = jsonEncode(data);
      _channel?.sink.add(jsonStr);
    } catch (e) {
      if (kDebugMode) print('Send failed: $e');
    }
  }

  void _onMessage(dynamic message) {
    try {
      final List<dynamic> events = jsonDecode(message);
      for (final event in events) {
        final type = event['ev'];

        if (type == 'status') {
          final msg = event['message'];
          if (kDebugMode) print('Polygon Status: $msg');

          if (event['status'] == 'auth_success') {
            // Re-subscribe to pending tickers
            if (_subscribedTickers.isNotEmpty) {
              final params = _subscribedTickers.map((t) => 'A.$t').join(',');
              _send({'action': 'subscribe', 'params': params});
            }
          }
        } else if (type == 'A') {
          // A = Second Aggregate
          // c: close price (current price in this second)
          // sym: symbol
          _updateController.add(event);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Parse error: $e');
    }
  }

  void _reconnect() {
    _channel = null;
    // Simple backoff or retry logic could go here
    // For now, prevent infinite instant loops
    Future.delayed(const Duration(seconds: 5), () {
      if (_channel == null) connect();
    });
  }

  void dispose() {
    _channel?.sink.close();
    _updateController.close();
  }
}
