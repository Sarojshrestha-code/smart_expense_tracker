import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _expenses {
    return _firestore.collection('expenses');
  }

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // CREATE
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    final expense = Expense(
      id: '',
      userId: _userId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );

    await _expenses.add(expense.toMap());
  }

  // READ
  Stream<List<Expense>> getExpenses() {
    return _expenses
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final expenses = snapshot.docs.map((doc) {
        return Expense.fromMap(doc.id, doc.data());
      }).toList();

      expenses.sort((a, b) => b.date.compareTo(a.date));

      return expenses;
    });
  }

  // UPDATE
  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    await _expenses.doc(id).update({
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    });
  }

  // DELETE
  Future<void> deleteExpense(String id) async {
    await _expenses.doc(id).delete();
  }

  // TOTAL EXPENSES
  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  // THIS MONTH'S EXPENSES
  double calculateMonthlyTotal(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses
        .where(
          (expense) =>
              expense.date.year == now.year &&
              expense.date.month == now.month,
        )
        .fold(
          0,
          (total, expense) => total + expense.amount,
        );
  }
}