 import 'package:flutter/material.dart';

import '../../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController =
      TextEditingController();

  final ExpenseService _expenseService =
      ExpenseService();

  String _category = 'Food';

  DateTime _selectedDate = DateTime.now();

  bool _loading = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

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

  Future<void> _saveExpense() async {
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

    setState(() {
      _loading = true;
    });

    try {
      await _expenseService.addExpense(
        title: title,
        amount: amount,
        category: _category,
        description:
            _descriptionController.text.trim(),
        date: _selectedDate,
      );

      if (!mounted) return;

      _showMessage('Expense added successfully');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                hintText: 'Example: Lunch',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Example: 250',
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
                prefixIcon:
                    Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration:
                    const InputDecoration(
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
              controller:
                  _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Optional description',
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
                    _loading ? null : _saveExpense,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _loading
                      ? 'Saving...'
                      : 'Save Expense',
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