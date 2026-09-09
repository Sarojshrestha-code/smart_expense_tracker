import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final ExpenseService _expenseService =
      ExpenseService();

  final NumberFormat _currencyFormat =
      NumberFormat('#,##0.00');

  final DateFormat _monthFormat =
      DateFormat('MMM yyyy');

  String _formatAmount(double amount) {
    return 'Rs. ${_currencyFormat.format(amount)}';
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month;
  }

  Map<String, double> _categoryTotals(
    List<Expense> expenses,
  ) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) +
              expense.amount;
    }

    return totals;
  }

  Map<String, double> _monthlyTotals(
    List<Expense> expenses,
  ) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      final key = _monthFormat.format(
        expense.date,
      );

      totals[key] =
          (totals[key] ?? 0) + expense.amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics & Reports',
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load analytics.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final expenses =
              snapshot.data ?? <Expense>[];

          double totalExpenses = 0;
          double monthlyExpenses = 0;

          for (final expense in expenses) {
            totalExpenses += expense.amount;

            if (_isCurrentMonth(
              expense.date,
            )) {
              monthlyExpenses += expense.amount;
            }
          }

          final categoryTotals =
              _categoryTotals(expenses);

          final monthlyTotals =
              _monthlyTotals(expenses);

          String topCategory = 'None';
          double topCategoryAmount = 0;

          for (final entry
              in categoryTotals.entries) {
            if (entry.value >
                topCategoryAmount) {
              topCategory = entry.key;
              topCategoryAmount =
                  entry.value;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Your Spending Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Understand where your money goes.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons
                          .account_balance_wallet,
                      title: 'Total Spending',
                      value: _formatAmount(
                        totalExpenses,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      icon: Icons.calendar_month,
                      title: 'This Month',
                      value: _formatAmount(
                        monthlyExpenses,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.receipt_long,
                      title: 'Transactions',
                      value:
                          '${expenses.length}',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      icon: Icons.category,
                      title: 'Categories',
                      value:
                          '${categoryTotals.length}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Top category
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Spending Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (expenses.isEmpty)
                        const Text(
                          'No expense data available.',
                        )
                      else
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              child: Icon(
                                _getCategoryIcon(
                                  topCategory,
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    topCategory,
                                    style:
                                        const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    _formatAmount(
                                      topCategoryAmount,
                                    ),
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category-wise spending
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category-wise Spending',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (categoryTotals.isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'No spending data yet.',
                            ),
                          ),
                        )
                      else
                        ..._buildCategoryRows(
                          categoryTotals,
                          totalExpenses,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Monthly spending
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Spending',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (monthlyTotals.isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'No monthly data yet.',
                            ),
                          ),
                        )
                      else
                        ..._buildMonthlyRows(
                          monthlyTotals,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Financial insight
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 30,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Spending Insight',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              expenses.isEmpty
                                  ? 'Start adding expenses to receive spending insights.'
                                  : 'Your highest spending category is $topCategory with ${_formatAmount(topCategoryAmount)} spent.',
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCategoryRows(
    Map<String, double> totals,
    double total,
  ) {
    final entries = totals.entries.toList()
      ..sort(
        (a, b) =>
            b.value.compareTo(a.value),
      );

    return entries.map((entry) {
      final percentage = total > 0
          ? entry.value / total
          : 0.0;

      return Padding(
        padding:
            const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(
                    entry.key,
                  ),
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),

                Text(
                  _formatAmount(
                    entry.value,
                  ),
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(10),
            ),

            const SizedBox(height: 4),

            Text(
              '${(percentage * 100).toStringAsFixed(1)}% of total spending',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildMonthlyRows(
    Map<String, double> totals,
  ) {
    final entries = totals.entries.toList();

    return entries.reversed
        .take(6)
        .map((entry) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          child: Icon(
            Icons.calendar_month,
          ),
        ),
        title: Text(
          entry.key,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          _formatAmount(entry.value),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
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

      default:
        return Icons.category;
    }
  }
}