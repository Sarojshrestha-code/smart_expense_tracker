 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> setMonthlyBudget(double amount) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();

    final String monthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    await _firestore
        .collection('budgets')
        .doc(user.uid)
        .collection('monthly')
        .doc(monthKey)
        .set({
      'userId': user.uid,
      'amount': amount,
      'month': monthKey,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<double> getMonthlyBudget() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 0;
    }

    final now = DateTime.now();

    final String monthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('budgets')
        .doc(user.uid)
        .collection('monthly')
        .doc(monthKey)
        .get();

    if (!doc.exists) {
      return 0;
    }

    final data = doc.data();

    return (data?['amount'] as num?)?.toDouble() ?? 0;
  }
}