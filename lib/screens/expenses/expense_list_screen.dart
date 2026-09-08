
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  ExpenseListScreen({super.key});

  final ExpenseService _expenseService = ExpenseService();

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _expenseService.deleteExpense(
        expense.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
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
                textAlign: TextAlign.center,
              ),
            );
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first expense',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      _getCategoryIcon(
                        expense.category,
                      ),
                    ),
                  ),

                  title: Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        expense.category,
                      ),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(expense.date),
                      ),

                      if (expense.description.isNotEmpty)
                        Text(
                          expense.description,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                    ],
                  ),

                  trailing: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditExpenseScreen(
                                    expense: expense,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                            ),
                            onPressed: () {
                              _deleteExpense(
                                context,
                                expense,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          // Add Expense screen can be opened
          // from Home screen.
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
