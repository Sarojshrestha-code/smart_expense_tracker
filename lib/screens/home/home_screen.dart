 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';
import '../expenses/add_expense_screen.dart'; 
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Expense>>(
        stream: expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final expenses = snapshot.data ?? [];

          double total = 0;

          for (final expense in expenses) {
            total += expense.amount;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 45,
                        ),

                        const SizedBox(width: 20),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Total Expenses'),
                            const SizedBox(height: 5),
                            Text(
                              'Rs. ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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

                    Text('${expenses.length} expenses'),
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: expenses.isEmpty
                      ? const Center(
                          child: Text(
                            'No expenses yet.\nAdd your first expense!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];

                            return Card(
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

                                subtitle: Text(
                                  '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                                ),

                                trailing: Text(
                                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  static IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }
}