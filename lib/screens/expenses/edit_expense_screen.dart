 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() =>
      _EditExpenseScreenState();
}

class _EditExpenseScreenState
    extends State<EditExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController =
      TextEditingController();

  String _category = 'Food & Dining';

  late DateTime _selectedDate;

  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Utilities & Bills',
    'Housing',
    'Entertainment & Leisure',
    'Shopping',
    'Subscriptions',
    'Health & Medical',
    'Other / Miscellaneous',
  ];

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

  String _convertOldCategory(String category) {
    switch (category) {
      case 'Food':
        return 'Food & Dining';
      case 'Transport':
        return 'Transportation';
      case 'Bills':
        return 'Utilities & Bills';
      case 'Entertainment':
        return 'Entertainment & Leisure';
      case 'Health':
        return 'Health & Medical';
      case 'Education':
        return 'Other / Miscellaneous';
      case 'Other':
        return 'Other / Miscellaneous';
      default:
        if (_categories.contains(category)) {
          return category;
        }

        return 'Other / Miscellaneous';
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.expense.title;

    _amountController.text =
        widget.expense.amount.toStringAsFixed(2);

    _descriptionController.text =
        widget.expense.description;

    _category =
        _convertOldCategory(widget.expense.category);

    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _updateExpense() async {
    final title = _titleController.text.trim();

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (title.isEmpty) {
      _showMessage('Please enter expense title');
      return;
    }

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount');
      return;
    }

    final provider = context.read<ExpenseProvider>();

    final updatedExpense = Expense(
      id: widget.expense.id,
      userId: widget.expense.userId,
      title: title,
      amount: amount,
      category: _category,
      description:
          _descriptionController.text.trim(),
      date: _selectedDate,
    );

    final success =
        await provider.updateExpense(updatedExpense);

    if (!mounted) return;

    if (success) {
      _showMessage(
        'Expense updated successfully',
      );

      Navigator.pop(context);
    } else {
      _showMessage(
        provider.errorMessage ??
            'Unable to update expense.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<ExpenseProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              enabled: !isLoading,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs. ',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: isLoading ? null : _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon:
                      Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_selectedDate.day}/'
                  '${_selectedDate.month}/'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
                prefixIcon:
                    Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading ? null : _updateExpense,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Icon(Icons.update),
                label: Text(
                  isLoading
                      ? 'Updating...'
                      : 'Update Expense',
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}