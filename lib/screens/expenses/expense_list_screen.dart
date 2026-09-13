 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  ExpenseListScreen({super.key});

  final ExpenseService _expenseService =
      ExpenseService();

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Delete'),
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Expense deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  void _openAddExpense(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddExpenseScreen(),
      ),
    );
  }

  void _openEditExpense(
    BuildContext context,
    Expense expense,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditExpenseScreen(
          expense: expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('My Expenses'),
      ),

      body: StreamBuilder<List<Expense>>(
        stream:
            _expenseService.getExpenses(),
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final expenses =
              snapshot.data ?? [];

          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 70,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Add your first expense',
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed: () =>
                          _openAddExpense(
                        context,
                      ),
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add Expense',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount: expenses.length,
            itemBuilder:
                (context, index) {
              final expense =
                  expenses[index];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // Category icon
                      CircleAvatar(
                        radius: 28,
                        child: Icon(
                          _getCategoryIcon(
                            expense.category,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // Expense information
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              expense.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              expense.category,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                fontSize: 15,
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(
                                expense.date,
                              ),
                              style:
                                  TextStyle(
                                fontSize: 14,
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),

                            if (expense
                                .description
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                expense
                                    .description,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      // Right side
                      SizedBox(
                        width: 105,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                          children: [
                            Text(
                              'Rs. ${expense.amount.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              textAlign:
                                  TextAlign.right,
                              style:
                                  const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .end,
                              children: [
                                // Edit
                                InkWell(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                  onTap: () {
                                    _openEditExpense(
                                      context,
                                      expense,
                                    );
                                  },
                                  child:
                                      const Padding(
                                    padding:
                                        EdgeInsets
                                            .all(
                                      7,
                                    ),
                                    child:
                                        Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                // Delete
                                InkWell(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                  onTap: () {
                                    _deleteExpense(
                                      context,
                                      expense,
                                    );
                                  },
                                  child:
                                      const Padding(
                                    padding:
                                        EdgeInsets
                                            .all(
                                      7,
                                    ),
                                    child:
                                        Icon(
                                      Icons.delete,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
        tooltip: 'Add Expense',
        onPressed: () {
          _openAddExpense(context);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(
    String category,
  ) {
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

      case 'Utilities':
        return Icons
            .electrical_services;

      default:
        return Icons.category;
    }
  }
}