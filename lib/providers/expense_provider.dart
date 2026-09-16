import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService;

  ExpenseProvider({ExpenseService? expenseService})
      : _expenseService = expenseService ?? ExpenseService();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<Expense>>? _expenseSubscription;

  // =========================
  // GETTERS
  // =========================

  List<Expense> get expenses => List.unmodifiable(_expenses);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // =========================
  // START REAL-TIME STREAM
  // =========================

  void startListening() {
    _expenseSubscription?.cancel();

    _setLoading(true);
    _clearError();

    _expenseSubscription = _expenseService.getExpenses().listen(
      (expenses) {
        _expenses = expenses;
        _setLoading(false);
      },
      onError: (error) {
        debugPrint('Expense stream error: $error');

        _errorMessage = 'Unable to load expenses.';
        _setLoading(false);
      },
    );
  }

  // =========================
  // CREATE
  // =========================

  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _expenseService.addExpense(
        title: title,
        amount: amount,
        category: category,
        description: description,
        date: date,
      );

      return true;
    } catch (e) {
      debugPrint('Add expense error: $e');

      _errorMessage = 'Unable to add expense.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    _clearError();

    try {
      await _expenseService.updateExpense(expense);

      return true;
    } catch (e) {
      debugPrint('Update expense error: $e');

      _errorMessage = 'Unable to update expense.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    _clearError();

    try {
      await _expenseService.deleteExpense(expenseId);

      return true;
    } catch (e) {
      debugPrint('Delete expense error: $e');

      _errorMessage = 'Unable to delete expense.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}