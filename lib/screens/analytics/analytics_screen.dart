 import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final ExpenseService _expenseService = ExpenseService();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spending Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildDashboard(context, expenses);
        },
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<Expense> expenses,
  ) {
    final double totalSpending = expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final DateTime now = DateTime.now();

    final List<Expense> currentMonthExpenses = expenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month;
    }).toList();

    final double currentMonthSpending = currentMonthExpenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final Map<String, double> categoryTotals =
        _calculateCategoryTotals(expenses);

    final Map<String, double> monthlyTotals =
        _calculateMonthlyTotals(expenses);

    final String topCategory = categoryTotals.isEmpty
        ? 'None'
        : categoryTotals.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
          ).key;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Spending Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Understand where your money goes',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          _buildSummaryGrid(
            totalSpending,
            currentMonthSpending,
            expenses.length,
            categoryTotals.length,
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'Category Spending',
            'Where you spend the most',
          ),

          const SizedBox(height: 12),

          _buildCategoryChart(
            categoryTotals,
            totalSpending,
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'Monthly Spending',
            'Spending trend over time',
          ),

          const SizedBox(height: 12),

          _buildMonthlyChart(monthlyTotals),

          const SizedBox(height: 24),

          _buildTopCategoryCard(
            topCategory,
            categoryTotals[topCategory] ?? 0,
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'Category Details',
            'Breakdown of your expenses',
          ),

          const SizedBox(height: 12),

          _buildCategoryDetails(
            categoryTotals,
            totalSpending,
          ),

          const SizedBox(height: 24),

          _buildSpendingInsight(
            totalSpending,
            currentMonthSpending,
            topCategory,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(
    double totalSpending,
    double currentMonthSpending,
    int transactionCount,
    int categoryCount,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildSummaryCard(
          title: 'Total Spending',
          value: _currencyFormat.format(totalSpending),
          icon: Icons.account_balance_wallet_outlined,
        ),
        _buildSummaryCard(
          title: 'This Month',
          value: _currencyFormat.format(currentMonthSpending),
          icon: Icons.calendar_month_outlined,
        ),
        _buildSummaryCard(
          title: 'Transactions',
          value: transactionCount.toString(),
          icon: Icons.receipt_long_outlined,
        ),
        _buildSummaryCard(
          title: 'Categories',
          value: categoryCount.toString(),
          icon: Icons.category_outlined,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(
    Map<String, double> categoryTotals,
    double totalSpending,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 65,
                      sections: _buildPieSections(
                        categoryTotals,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _shortAmount(totalSpending),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _buildCategoryLegend(categoryTotals),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> totals,
  ) {
    final entries = totals.entries.toList();

    return List.generate(
      entries.length,
      (index) {
        final entry = entries[index];

        return PieChartSectionData(
          value: entry.value,
          title: '',
          radius: 55,
          color: _getChartColor(index),
        );
      },
    );
  }

  Widget _buildCategoryLegend(
    Map<String, double> categoryTotals,
  ) {
    final entries = categoryTotals.entries.toList();

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: List.generate(
        entries.length,
        (index) {
          final entry = entries[index];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getChartColor(index),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthlyChart(
    Map<String, double> monthlyTotals,
  ) {
    final entries = monthlyTotals.entries.toList();

    if (entries.isEmpty) {
      return const SizedBox();
    }

    final double maxValue = entries
        .map((entry) => entry.value)
        .reduce((a, b) => a > b ? a : b);

    final double chartMaxY = maxValue == 0
        ? 100
        : (maxValue * 1.25);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          20,
          20,
          12,
        ),
        child: SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              maxY: chartMaxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: chartMaxY / 4,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _shortAmount(value),
                        style: const TextStyle(
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();

                      if (index < 0 ||
                          index >= entries.length) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Text(
                          entries[index].key,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(
                entries.length,
                (index) {
                  final value = entries[index].value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCategoryCard(
    String category,
    double amount,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getChartColor(0).withValues(
                  alpha: 0.12,
                ),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: _getChartColor(0),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Spending Category',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              _currencyFormat.format(amount),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDetails(
    Map<String, double> categoryTotals,
    double totalSpending,
  ) {
    final entries = categoryTotals.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: List.generate(
            entries.length,
            (index) {
              final entry = entries[index];

              final double percentage =
                  totalSpending == 0
                      ? 0
                      : entry.value / totalSpending;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == entries.length - 1
                      ? 0
                      : 18,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getChartColor(index)
                                .withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            _getCategoryIcon(
                              entry.key,
                            ),
                            size: 17,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Text(
                          _currencyFormat.format(
                            entry.value,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.grey.shade200,
                              valueColor:
                                  AlwaysStoppedAnimation(
                                _getChartColor(index),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        SizedBox(
                          width: 40,
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingInsight(
    double totalSpending,
    double currentMonthSpending,
    String topCategory,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 28,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending Insight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Your highest spending category is '
                    '$topCategory. '
                    'This month you have spent '
                    '${_currencyFormat.format(currentMonthSpending)} '
                    'out of your total spending of '
                    '${_currencyFormat.format(totalSpending)}.',
                    style: TextStyle(
                      height: 1.5,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Analytics Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add some expenses to see your spending '
              'analytics and reports.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(
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

  Map<String, double> _calculateMonthlyTotals(
    List<Expense> expenses,
  ) {
    final Map<String, double> totals = {};

    final DateTime now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final DateTime month = DateTime(
        now.year,
        now.month - i,
      );

      final String key = DateFormat(
        'MMM',
      ).format(month);

      totals[key] = 0;
    }

    for (final expense in expenses) {
      final DateTime date = expense.date;

      final int monthDifference =
          (now.year - date.year) * 12 +
              now.month -
              date.month;

      if (monthDifference >= 0 &&
          monthDifference <= 5) {
        final String key = DateFormat(
          'MMM',
        ).format(date);

        totals[key] =
            (totals[key] ?? 0) + expense.amount;
      }
    }

    return totals;
  }

  String _shortAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }

  Color _getChartColor(int index) {
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;

      case 'transport':
        return Icons.directions_car_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'bills':
        return Icons.receipt_long_outlined;

      case 'entertainment':
        return Icons.movie_outlined;

      case 'health':
        return Icons.health_and_safety_outlined;

      case 'education':
        return Icons.school_outlined;

      default:
        return Icons.category_outlined;
    }
  }
}