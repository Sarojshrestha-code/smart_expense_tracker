import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _budgets =>
      _firestore.collection('budgets');

  String? get _userId => _auth.currentUser?.uid;

  String get _currentMonth {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> get _monthlyBudgetDocument {
    final userId = _userId;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    return _budgets.doc(userId).collection('monthly').doc(_currentMonth);
  }

  // Get the current month's budget once.
  Future<double> getMonthlyBudget() async {
    final snapshot = await _monthlyBudgetDocument.get();

    if (!snapshot.exists) {
      return 0.0;
    }

    final data = snapshot.data();

    return (data?['amount'] as num?)?.toDouble() ?? 0.0;
  }

  // Save or update the current month's budget.
  Future<void> setMonthlyBudget(double amount) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    if (amount <= 0) {
      throw Exception('Budget must be greater than zero');
    }

    await _monthlyBudgetDocument.set({
      'userId': _userId,
      'amount': amount,
      'month': _currentMonth,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Real-time budget stream.
  Stream<double> monthlyBudgetStream() {
    final userId = _userId;

    if (userId == null) {
      return Stream.value(0.0);
    }

    return _budgets
        .doc(userId)
        .collection('monthly')
        .doc(_currentMonth)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return 0.0;
          }

          final data = snapshot.data();

          return (data?['amount'] as num?)?.toDouble() ?? 0.0;
        });
  }
}
