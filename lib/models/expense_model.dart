 class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  factory Expense.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Expense(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? 'Other',
      description: data['description'] ?? '',
      date: DateTime.tryParse(
            data['date'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}