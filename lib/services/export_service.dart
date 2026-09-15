 import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================
  // GET EXPENSES
  // ==========================================================

  Future<List<Map<String, dynamic>>> _getExpenses() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final snapshot = await _firestore
        .collection('expenses')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .get();

    final expenses = snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'title': data['title']?.toString() ?? '',
        'category': data['category']?.toString() ?? '',
        'amount': (data['amount'] as num?)?.toDouble() ?? 0,
        'date': data['date'],
        'description':
            data['description']?.toString() ?? '',
      };
    }).toList();

    // Sort newest first.
    expenses.sort((a, b) {
      final dateA = _convertToDateTime(a['date']);
      final dateB = _convertToDateTime(b['date']);

      return dateB.compareTo(dateA);
    });

    return expenses;
  }

  // ==========================================================
  // DATE HELPERS
  // ==========================================================

  DateTime _convertToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime(2000);
    }

    return DateTime(2000);
  }

  String _formatDate(dynamic value) {
    final date = _convertToDateTime(value);

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double _calculateTotal(
    List<Map<String, dynamic>> expenses,
  ) {
    double total = 0;

    for (final expense in expenses) {
      total += expense['amount'] as double;
    }

    return total;
  }

  Map<String, double> _calculateCategoryTotals(
    List<Map<String, dynamic>> expenses,
  ) {
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      final category =
          expense['category'] as String;

      final amount =
          expense['amount'] as double;

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }

  // ==========================================================
  // CSV GENERATION
  // ==========================================================

  Future<String> generateCsv() async {
    final expenses = await _getExpenses();

    final buffer = StringBuffer();

    // CSV header.
    buffer.writeln(
      'Date,Title,Category,Amount,Description',
    );

    for (final expense in expenses) {
      final date =
          _formatDate(expense['date']);

      final title =
          _escapeCsv(expense['title']);

      final category =
          _escapeCsv(expense['category']);

      final amount =
          (expense['amount'] as double)
              .toStringAsFixed(2);

      final description =
          _escapeCsv(expense['description']);

      buffer.writeln(
        '$date,$title,$category,$amount,$description',
      );
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    final escaped =
        value.replaceAll('"', '""');

    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n')) {
      return '"$escaped"';
    }

    return escaped;
  }

  // ==========================================================
  // SAVE CSV TO PHONE
  // ==========================================================

  Future<void> exportCsv() async {
    final csv = await generateCsv();

    final bytes = Uint8List.fromList(
      utf8.encode(csv),
    );

    await FlutterFileSaver().writeFileAsBytes(
      fileName: 'smart_expense_report.csv',
      bytes: bytes,
    );
  }

  // ==========================================================
  // PDF GENERATION
  // ==========================================================

  Future<Uint8List> generatePdf() async {
    final expenses = await _getExpenses();

    final total =
        _calculateTotal(expenses);

    final categoryTotals =
        _calculateCategoryTotals(expenses);

    final pdf = pw.Document();

    final user = _auth.currentUser;

    final email =
        user?.email ?? 'Unknown user';

    final now = DateTime.now();

    final generatedDate =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // ==================================================
            // TITLE
            // ==================================================

            pw.Text(
              'Smart Expense Tracker',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Text(
              'Expense Report',
              style: pw.TextStyle(
                fontSize: 18,
                color: PdfColors.grey700,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Text('User: $email'),

            pw.Text(
              'Generated: $generatedDate',
            ),

            pw.SizedBox(height: 25),

            // ==================================================
            // SUMMARY
            // ==================================================

            pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              padding:
                  const pw.EdgeInsets.all(12),
              decoration:
                  pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                ),
                borderRadius:
                    pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceAround,
                children: [
                  _summaryItem(
                    'Total Expenses',
                    'Rs. ${total.toStringAsFixed(2)}',
                  ),
                  _summaryItem(
                    'Transactions',
                    expenses.length.toString(),
                  ),
                  _summaryItem(
                    'Categories',
                    categoryTotals.length
                        .toString(),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            // ==================================================
            // CATEGORY SUMMARY
            // ==================================================

            pw.Text(
              'Category-wise Spending',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (categoryTotals.isEmpty)
              pw.Text(
                'No expenses available.',
              )
            else
              pw.Table(
                border:
                    pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
                children: [
                  pw.TableRow(
                    children: [
                      _tableHeader(
                        'Category',
                      ),
                      _tableHeader(
                        'Amount',
                      ),
                    ],
                  ),
                  ...categoryTotals.entries
                      .map(
                    (entry) {
                      return pw.TableRow(
                        children: [
                          _tableCell(
                            entry.key,
                          ),
                          _tableCell(
                            'Rs. ${entry.value.toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

            pw.SizedBox(height: 25),

            // ==================================================
            // EXPENSE DETAILS
            // ==================================================

            pw.Text(
              'Expense Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (expenses.isEmpty)
              pw.Text(
                'No expenses available.',
              )
            else
              pw.Table(
                border:
                    pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(
                    1.2,
                  ),
                  1: const pw.FlexColumnWidth(
                    1.8,
                  ),
                  2: const pw.FlexColumnWidth(
                    1.5,
                  ),
                  3: const pw.FlexColumnWidth(
                    1.2,
                  ),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _tableHeader('Date'),
                      _tableHeader('Title'),
                      _tableHeader(
                        'Category',
                      ),
                      _tableHeader('Amount'),
                    ],
                  ),
                  ...expenses.map(
                    (expense) {
                      return pw.TableRow(
                        children: [
                          _tableCell(
                            _formatDate(
                              expense['date'],
                            ),
                          ),
                          _tableCell(
                            expense['title']
                                as String,
                          ),
                          _tableCell(
                            expense['category']
                                as String,
                          ),
                          _tableCell(
                            'Rs. ${(expense['amount'] as double).toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================================
  // PDF HELPERS
  // ==========================================================

  pw.Widget _summaryItem(
    String title,
    String value,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _tableHeader(
    String text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
              pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _tableCell(
    String text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }

  // ==========================================================
  // SAVE PDF TO PHONE
  // ==========================================================

  Future<void> exportPdf() async {
    final pdfBytes = await generatePdf();

    await FlutterFileSaver().writeFileAsBytes(
      fileName: 'smart_expense_report.pdf',
      bytes: pdfBytes,
    );
  }
}