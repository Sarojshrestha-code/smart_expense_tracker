 import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';
import '../../widgets/summary_card.dart';
import '../auth/login_screen.dart';
import '../budget/budget_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ExpenseService _expenseService =
      ExpenseService();

  final AuthService _authService =
      AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_bus;
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
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
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
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final expenses = snapshot.data ?? [];

          final total =
              _expenseService.calculateTotal(expenses);

          final monthly =
              _expenseService.calculateMonthlyTotal(
            expenses,
          );

          final recent =
              expenses.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome back 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 5),

              Text(
                user?.email ?? 'User',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              SummaryCard(
                title: 'Total Expenses',
                amount:
                    'Rs. ${total.toStringAsFixed(2)}',
                icon:
                    Icons.account_balance_wallet,
              ),

              const SizedBox(height: 12),

              SummaryCard(
                title: 'This Month',
                amount:
                    'Rs. ${monthly.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
              ),

              const SizedBox(height: 12),

              SummaryCard(
                title: 'Transactions',
                amount: '${expenses.length}',
                icon: Icons.receipt_long,
              ),

              const SizedBox(height: 28),

              Text(
                'Quick Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddExpenseScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label:
                          const Text('Add Expense'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExpenseListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('View All'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BudgetScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.account_balance_wallet,
                  ),
                  label: const Text(
                    'Manage Monthly Budget',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Recent Expenses',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              if (recent.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recent.map(
                  (expense) => Card(
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
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${expense.category} • '
                        '${expense.date.day}/'
                        '${expense.date.month}/'
                        '${expense.date.year}',
                      ),
                      trailing: Text(
                        'Rs. ${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}