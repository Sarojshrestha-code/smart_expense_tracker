 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _expenses.add({
      'userId': user.uid,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Expense>> getExpenses() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _expenses
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Expense.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenses.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expenses.doc(expenseId).delete();
  }
}