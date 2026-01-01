class StockAlert {
  final String id;
  final String symbol;
  final double targetPrice;
  final String condition; // 'above' or 'below'
  final bool isActive;
  final String userId;
  final DateTime createdAt;

  StockAlert({
    required this.id,
    required this.symbol,
    required this.targetPrice,
    required this.condition,
    required this.isActive,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'targetPrice': targetPrice,
      'condition': condition,
      'isActive': isActive,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StockAlert.fromMap(Map<String, dynamic> map, String docId) {
    return StockAlert(
      id: docId,
      symbol: map['symbol'] ?? '',
      targetPrice: (map['targetPrice'] as num).toDouble(),
      condition: map['condition'] ?? 'above',
      isActive: map['isActive'] ?? true,
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
