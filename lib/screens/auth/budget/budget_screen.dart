import 'package:flutter/material.dart';

import '../../models/budget.dart';
import '../../models/expense.dart';
import '../../services/budget_service.dart';
import '../../services/expense_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _budgetController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount =
        double.tryParse(_budgetController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid budget amount.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _budgetService.setBudget(amount);

      if (!mounted) return;

      _budgetController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget saved successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
        centerTitle: true,
      ),
      body: StreamBuilder<Budget?>(
        stream: _budgetService.getCurrentBudget(),
        builder: (context, budgetSnapshot) {
          if (budgetSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final budget = budgetSnapshot.data;

          return StreamBuilder<List<Expense>>(
            stream: _expenseService.getExpenses(),
            builder: (context, expenseSnapshot) {
              if (expenseSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final expenses = expenseSnapshot.data ?? [];

              final monthlyExpense =
                  _expenseService.calculateMonthlyTotal(
                expenses,
              );

              final budgetAmount = budget?.amount ?? 0;

              final remaining =
                  budgetAmount - monthlyExpense;

              double progress = 0;

              if (budgetAmount > 0) {
                progress =
                    monthlyExpense / budgetAmount;

                if (progress > 1) {
                  progress = 1;
                }
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 70,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Set Monthly Budget',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: _budgetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Budget Amount',
                      hintText: 'e.g. 30000',
                      prefixIcon:
                          Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSaving ? null : _saveBudget,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : budget == null
                                ? 'Set Budget'
                                : 'Update Budget',
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (budget != null) ...[
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'This Month',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Rs. ${budget.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),

                            const SizedBox(height: 15),

                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% used',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Spent',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rs. ${monthlyExpense.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rs. ${remaining.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 17,
                                      color: remaining < 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (remaining < 0)
                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You have exceeded your monthly budget by '
                                  'Rs. ${(-remaining).toStringAsFixed(2)}.',
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ] else ...[
                    const SizedBox(height: 20),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.savings,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No budget set yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Set a monthly budget to track your spending.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}