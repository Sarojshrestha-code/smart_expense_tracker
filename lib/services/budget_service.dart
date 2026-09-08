 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  String getCurrentMonth() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> setBudget(double amount) async {
    final month = getCurrentMonth();

    final existing = await _firestore
        .collection('budgets')
        .where(
          'userId',
          isEqualTo: _userId,
        )
        .where(
          'month',
          isEqualTo: month,
        )
        .get();

    if (existing.docs.isEmpty) {
      final budget = Budget(
        id: '',
        userId: _userId,
        amount: amount,
        month: month,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('budgets')
          .add(budget.toMap());
    } else {
      await _firestore
          .collection('budgets')
          .doc(existing.docs.first.id)
          .update({
        'amount': amount,
      });
    }
  }

  Stream<Budget?> getCurrentBudget() {
    final month = getCurrentMonth();

    return _firestore
        .collection('budgets')
        .where(
          'userId',
          isEqualTo: _userId,
        )
        .where(
          'month',
          isEqualTo: month,
        )
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;

      return Budget.fromMap(
        doc.id,
        doc.data(),
      );
    });
  }
}