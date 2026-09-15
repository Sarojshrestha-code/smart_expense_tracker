 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import '../analytics/analytics_screen.dart';
import '../auth/login_screen.dart';
import '../budget/budget_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExpenseService _expenseService = ExpenseService();

  final NumberFormat _currencyFormat =
      NumberFormat('#,##0.00');

  final DateFormat _dateFormat =
      DateFormat('dd MMM');

  String _formatAmount(double amount) {
    return 'Rs. ${_currencyFormat.format(amount)}';
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month;
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData =
            userSnapshot.data?.data();

        final firstName =
            userData?['firstName']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true
                ? userData!['firstName']
                    .toString()
                    .trim()
                : 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Smart Expense Tracker',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(
                  Icons.logout_outlined,
                ),
                onPressed: () =>
                    _showLogoutDialog(context),
              ),
              const SizedBox(width: 4),
            ],
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
                return _buildErrorState(
                  context,
                  snapshot.error.toString(),
                );
              }

              final expenses =
                  snapshot.data ?? <Expense>[];

              double totalExpenses = 0;
              double currentMonthExpenses = 0;

              for (final expense in expenses) {
                totalExpenses += expense.amount;

                if (_isCurrentMonth(
                  expense.date,
                )) {
                  currentMonthExpenses +=
                      expense.amount;
                }
              }

              final recentExpenses =
                  [...expenses]
                    ..sort(
                      (a, b) =>
                          b.date.compareTo(
                        a.date,
                      ),
                    );

              final recent =
                  recentExpenses.take(5).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(
                    const Duration(
                      milliseconds: 400,
                    ),
                  );
                },
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    100,
                  ),
                  children: [
                    // ==================================================
                    // GREETING
                    // ==================================================
                    Text(
                      'Welcome, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Keep track of your spending and stay '
                      'in control of your money.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // TOTAL SPENDING
                    // ==================================================
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration:
                                      BoxDecoration(
                                    color: colorScheme
                                        .primaryContainer,
                                    borderRadius:
                                        BorderRadius
                                            .circular(14),
                                  ),
                                  child: Icon(
                                    Icons
                                        .account_balance_wallet_outlined,
                                    color: colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'Total Spending',
                                        style:
                                            TextStyle(
                                          fontSize: 14,
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'All recorded expenses',
                                        style:
                                            TextStyle(
                                          fontSize: 12,
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Text(
                              _formatAmount(
                                totalExpenses,
                              ),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // SUMMARY CARDS
                    // ==================================================
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _summaryCard(
                            context,
                            icon:
                                Icons.calendar_month_outlined,
                            title: 'This Month',
                            value: _formatAmount(
                              currentMonthExpenses,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _summaryCard(
                            context,
                            icon:
                                Icons.receipt_long_outlined,
                            title: 'Transactions',
                            value:
                                '${expenses.length}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // QUICK ACTIONS
                    // ==================================================
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            context,
                            icon: Icons.add,
                            label: 'Add Expense',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddExpenseScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _actionButton(
                            context,
                            icon:
                                Icons.receipt_long_outlined,
                            label: 'All Expenses',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ExpenseListScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _actionButton(
                            context,
                            icon: Icons
                                .account_balance_wallet_outlined,
                            label: 'Budget',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BudgetScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ANALYTICS BUTTON
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnalyticsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.analytics_outlined,
                        ),
                        label: const Text(
                          'View Analytics & Reports',
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // RECENT EXPENSES HEADER
                    // ==================================================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        if (expenses.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ExpenseListScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // RECENT EXPENSES
                    // ==================================================
                    if (recent.isEmpty)
                      _buildEmptyExpenses(
                        context,
                      )
                    else
                      ...recent.map(
                        (expense) =>
                            _buildExpenseCard(
                          context,
                          expense,
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),

          // ============================================================
          // FLOATING ACTION BUTTON
          // ============================================================
          floatingActionButton:
              FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AddExpenseScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Expense'),
          ),
        );
      },
    );
  }

  // ================================================================
  // SUMMARY CARD
  // ================================================================

  Widget _summaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color:
                    colorScheme.onSecondaryContainer,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color:
                    colorScheme.onSurfaceVariant,
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // QUICK ACTION BUTTON
  // ================================================================

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return SizedBox(
      height: 94,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 27,
                  color: colorScheme.primary,
                ),

                const SizedBox(height: 7),

                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // RECENT EXPENSE CARD
  // ================================================================

  Widget _buildExpenseCard(
    BuildContext context,
    Expense expense,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme
                .secondaryContainer,
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            _getCategoryIcon(
              expense.category,
            ),
            color:
                colorScheme.onSecondaryContainer,
          ),
        ),

        title: Text(
          expense.title,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 3),
          child: Text(
            '${expense.category} • '
            '${_dateFormat.format(expense.date)}',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
        ),

        trailing: Text(
          _formatAmount(
            expense.amount,
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // EMPTY EXPENSE STATE
  // ================================================================

  Widget _buildEmptyExpenses(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 30,
                color:
                    colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Start tracking your expenses '
              'to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddExpenseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add First Expense',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState(
    BuildContext context,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 58,
              color: Theme.of(context)
                  .colorScheme
                  .error,
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
              error,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CATEGORY ICONS
  // ================================================================

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
      case 'Food & Dining':
        return Icons.restaurant;

      case 'Transport':
      case 'Transportation':
        return Icons.directions_car;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Bills':
      case 'Utilities':
      case 'Utilities & Bills':
        return Icons.receipt_long;

      case 'Housing':
        return Icons.home;

      case 'Entertainment':
      case 'Entertainment & Leisure':
        return Icons.movie;

      case 'Subscriptions':
        return Icons.subscriptions;

      case 'Health':
      case 'Health & Medical':
        return Icons.medical_services;

      case 'Education':
        return Icons.school;

      case 'Other':
      case 'Other / Miscellaneous':
        return Icons.category;

      default:
        return Icons.payments;
    }
  }

  // ================================================================
  // LOGOUT DIALOG
  // ================================================================

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}