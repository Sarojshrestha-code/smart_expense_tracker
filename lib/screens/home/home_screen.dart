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
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    final displayName =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : user?.email?.split('@').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Expense Tracker',
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load expenses.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final expenses =
              snapshot.data ?? <Expense>[];

          double totalExpenses = 0;
          double currentMonthExpenses = 0;

          for (final expense in expenses) {
            totalExpenses += expense.amount;

            if (_isCurrentMonth(expense.date)) {
              currentMonthExpenses += expense.amount;
            }
          }

          final recentExpenses = [...expenses]
            ..sort(
              (a, b) => b.date.compareTo(a.date),
            );

          final recent =
              recentExpenses.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Greeting
                Text(
                  'Hello, $displayName 👋',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Manage your expenses smartly.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                // Total Spending Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: const Icon(
                                Icons
                                    .account_balance_wallet,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Total Spending',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          _formatAmount(totalExpenses),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        icon: Icons.calendar_month,
                        title: 'This Month',
                        value: _formatAmount(
                          currentMonthExpenses,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _summaryCard(
                        icon: Icons.receipt_long,
                        title: 'Transactions',
                        value:
                            '${expenses.length}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Existing 3 Quick Action Buttons
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
                              builder: (context) =>
                                  AddExpenseScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _actionButton(
                        context,
                        icon: Icons.list_alt,
                        label: 'All Expenses',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ExpenseListScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _actionButton(
                        context,
                        icon: Icons.account_balance,
                        label: 'Budget',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BudgetScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Analytics Button
                SizedBox(
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnalyticsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.analytics,
                    ),
                    label: const Text(
                      'View Analytics & Reports',
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Recent Expenses Header
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (expenses.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ExpenseListScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Recent Expenses
                if (recent.isEmpty)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 50,
                            color:
                                Colors.grey.shade400,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'No expenses yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Start tracking your expenses.',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 15),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddExpenseScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                            ),
                            label: const Text(
                              'Add First Expense',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...recent.map(
                    (expense) {
                      return Card(
                        margin:
                            const EdgeInsets.only(
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
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            '${expense.category} • '
                            '${_dateFormat.format(expense.date)}',
                          ),

                          trailing: Text(
                            _formatAmount(
                              expense.amount,
                            ),
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      // Floating Add Expense Button
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),
    );
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
            Icon(
              icon,
              size: 27,
            ),

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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 95,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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