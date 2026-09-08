class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
