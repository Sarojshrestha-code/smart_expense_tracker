import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';


class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  static final ExpenseService _expenseService =
      ExpenseService();

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;

      case 'Transportation':
        return Icons.directions_car;

      case 'Utilities & Bills':
        return Icons.lightbulb;

      case 'Housing':
        return Icons.home;

      case 'Entertainment & Leisure':
        return Icons.movie;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Subscriptions':
        return Icons.subscriptions;

      case 'Health & Medical':
        return Icons.health_and_safety;

      case 'Other / Miscellaneous':
        return Icons.category;

      default:
        return Icons.category;
    }
  }

  Future<void> _deleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    final colorScheme =
        Theme.of(context).colorScheme;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Are you sure you want to delete '
            '"${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    colorScheme.error,
                foregroundColor:
                    colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _expenseService.deleteExpense(
        expense.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expense deleted successfully.',
          ),
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

  void _openAddExpense(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddExpenseScreen(),
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
      builder: (context) => EditExpenseScreen(
        expense: expense,
      ),
    ),
  );
}

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),

        builder: (context, snapshot) {
          // ==========================================================
          // LOADING
          // ==========================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==========================================================
          // ERROR
          // ==========================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error
                          .toString()
                          .replaceFirst(
                            'Exception: ',
                            '',
                          ),
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final expenses =
              snapshot.data ?? [];

          // ==========================================================
          // EMPTY STATE
          // ==========================================================

          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration:
                          BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons
                            .receipt_long_outlined,
                        size: 42,
                        color: colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your spending '
                      'by adding your first expense.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
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

          // ==========================================================
          // EXPENSE LIST
          // ==========================================================

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            itemCount: expenses.length,
            itemBuilder: (
              context,
              index,
            ) {
              final expense =
                  expenses[index];

              return _buildExpenseCard(
                context,
                expense,
              );
            },
          );
        },
      ),

      // ============================================================
      // ADD EXPENSE FAB
      // ============================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            _openAddExpense(context),
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Expense',
        ),
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    Expense expense,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryIcon =
        _getCategoryIcon(
      expense.category,
    );

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ========================================================
            // CATEGORY ICON
            // ========================================================

            Container(
              width: 50,
              height: 50,
              decoration:
                  BoxDecoration(
                color: colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Icon(
                categoryIcon,
                color: colorScheme
                    .onPrimaryContainer,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            // ========================================================
            // EXPENSE INFORMATION
            // ========================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        categoryIcon,
                        size: 14,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          expense.category,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 13,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _formatDate(
                          expense.date,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  if (expense.description
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      expense.description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ========================================================
            // AMOUNT + ACTIONS
            // ========================================================

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // EDIT
                    IconButton(
                      tooltip: 'Edit',
                      visualDensity:
                          VisualDensity.compact,
                      onPressed: () {
                        _openEditExpense(
                          context,
                          expense,
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 21,
                      ),
                    ),

                    // DELETE
                    IconButton(
                      tooltip: 'Delete',
                      visualDensity:
                          VisualDensity.compact,
                      onPressed: () {
                        _deleteExpense(
                          context,
                          expense,
                        );
                      },
                      icon: Icon(
                        Icons
                            .delete_outline,
                        size: 21,
                        color:
                            colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}