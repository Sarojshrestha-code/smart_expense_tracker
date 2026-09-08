 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _budgetController =
      TextEditingController();

  double _budget = 0;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _setBudget() {
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
      _budget = value;
    });

    _budgetController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Monthly budget updated'),
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
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Budget Overview',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  DateFormat(
                    'MMMM yyyy',
                  ).format(now),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Rs. ${_budget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _budget == 0
                              ? 'Set your monthly budget'
                              : '${(progress * 100).toStringAsFixed(1)}% of budget used',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Spent',
                        amount: monthlyTotal,
                        icon: Icons.trending_down,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _summaryCard(
                        title: 'Remaining',
                        amount: remaining,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Set Monthly Budget',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _budgetController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText: 'Budget Amount',
                            hintText: 'e.g. 30000',
                            prefixText: 'Rs. ',
                            prefixIcon:
                                Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _setBudget,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Set Budget',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        if (_budget == 0)
                          const Text(
                            'Set a monthly budget to start tracking your spending.',
                          )
                        else if (monthlyTotal > _budget)
                          Text(
                            '⚠️ You have exceeded your monthly budget by Rs. ${(monthlyTotal - _budget).toStringAsFixed(2)}.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            'You have Rs. ${remaining.toStringAsFixed(2)} remaining this month.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
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

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Rs. ${amount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}