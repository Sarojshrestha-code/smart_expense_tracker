 import 'package:flutter/material.dart';

import '../../models/expense_model.dart';
import '../../services/budget_service.dart';
import '../../services/expense_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final BudgetService _budgetService = BudgetService();

  final TextEditingController _budgetController =
      TextEditingController();

  double _budget = 0;
  bool _loadingBudget = true;
  bool _savingBudget = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // Load the saved monthly budget from Firestore.
  Future<void> _loadBudget() async {
    try {
      final budget = await _budgetService.getMonthlyBudget();

      if (!mounted) return;

      setState(() {
        _budget = budget;
        _loadingBudget = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingBudget = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  // Save the monthly budget to Firestore.
  Future<void> _setBudget() async {
    final value = double.tryParse(
      _budgetController.text.trim(),
    );

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount'),
        ),
      );
      return;
    }

    setState(() {
      _savingBudget = true;
    });

    try {
      await _budgetService.setMonthlyBudget(value);

      if (!mounted) return;

      setState(() {
        _budget = value;
      });

      _budgetController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monthly budget saved successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save budget: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingBudget = false;
        });
      }
    }
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rs. ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Budget',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load expenses:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final expenses = snapshot.data ?? [];

          final now = DateTime.now();

          final monthlyExpenses = expenses.where((expense) {
            return expense.date.year == now.year &&
                expense.date.month == now.month;
          }).toList();

          double monthlyTotal = 0;

          for (final expense in monthlyExpenses) {
            monthlyTotal += expense.amount;
          }

          final remaining = _budget - monthlyTotal;

          double progress = 0;

          if (_budget > 0) {
            progress = monthlyTotal / _budget;

            if (progress > 1) {
              progress = 1;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Budget card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 45,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (_loadingBudget)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          )
                        else
                          Text(
                            'Rs. ${_budget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: _budget > 0 ? progress : 0,
                          minHeight: 10,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _loadingBudget
                              ? 'Loading budget...'
                              : _budget == 0
                                  ? 'Set your monthly budget'
                                  : '${(progress * 100).toStringAsFixed(1)}% of budget used',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Summary
                _summaryCard(
                  title: 'Spent This Month',
                  amount: monthlyTotal,
                  icon: Icons.trending_down,
                ),

                const SizedBox(height: 10),

                _summaryCard(
                  title: 'Remaining',
                  amount: remaining,
                  icon: Icons.savings,
                ),

                const SizedBox(height: 25),

                // Set budget section
                const Text(
                  'Set Monthly Budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    hintText: 'Enter monthly budget',
                    prefixText: 'Rs. ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.account_balance_wallet,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _savingBudget ? null : _setBudget,
                  icon: _savingBudget
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _savingBudget
                        ? 'Saving...'
                        : 'Set Budget',
                  ),
                ),

                const SizedBox(height: 25),

                // Budget message
                if (!_loadingBudget)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _budget == 0
                            ? 'Set a monthly budget to start tracking your spending.'
                            : monthlyTotal > _budget
                                ? '⚠️ You have exceeded your monthly budget by '
                                    'Rs. ${(monthlyTotal - _budget).toStringAsFixed(2)}.'
                                : 'You have Rs. ${remaining.toStringAsFixed(2)} remaining '
                                    'for this month.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}