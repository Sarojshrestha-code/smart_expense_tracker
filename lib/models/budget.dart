 class Budget {
  final String id;
  final String userId;
  final double amount;
  final String month;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'month': month,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Budget(
      id: id,
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'],
      ),
    );
  }
}