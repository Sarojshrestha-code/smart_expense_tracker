import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Export & Reports')),
      body: StreamBuilder<List<Expense>>(
        stream: expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data ?? const <Expense>[];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Export your expenses',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose PDF or CSV to save or share your spending data.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: expenses.isEmpty
                      ? null
                      : () async => _exportPdf(context, expenses),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export as PDF'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: expenses.isEmpty
                      ? null
                      : () async => _exportCsv(context, expenses),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Export as CSV'),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    child: expenses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No expenses found yet. Add some expenses to export them.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: expenses.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];

                              return ListTile(
                                title: Text(expense.title),
                                subtitle: Text(
                                  '${expense.category} • ${_formatDate(expense.date)}',
                                ),
                                trailing: Text(
                                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, List<Expense> expenses) async {
    final pdfDocument = pw.Document();

    pdfDocument.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Category', 'Amount', 'Date'],
                data: [
                  for (final expense in expenses)
                    [
                      expense.title,
                      expense.category,
                      'Rs. ${expense.amount.toStringAsFixed(2)}',
                      _formatDate(expense.date),
                    ],
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_report.pdf');
    await file.writeAsBytes(await pdfDocument.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Expense report PDF'),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF export created and shared.')),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context, List<Expense> expenses) async {
    final buffer = StringBuffer();
    buffer.writeln('Title,Category,Amount,Date');

    for (final expense in expenses) {
      final escapedTitle = _escapeCsv(expense.title);
      final escapedCategory = _escapeCsv(expense.category);
      buffer.writeln(
        '$escapedTitle,$escapedCategory,${expense.amount.toStringAsFixed(2)},${_formatDate(expense.date)}',
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_report.csv');
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Expense report CSV'),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV export created and shared.')),
      );
    }
  }

  String _escapeCsv(String value) {
    final sanitized = value.replaceAll('"', '""');
    if (sanitized.contains(',') ||
        sanitized.contains('"') ||
        sanitized.contains('\n')) {
      return '"$sanitized"';
    }
    return sanitized;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
