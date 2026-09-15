 import 'package:flutter/material.dart';

import '../../services/export_service.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() =>
      _DataExportScreenState();
}

class _DataExportScreenState
    extends State<DataExportScreen> {
  final ExportService _exportService =
      ExportService();

  bool _isExportingCsv = false;
  bool _isExportingPdf = false;

  // ==========================================================
  // EXPORT CSV
  // ==========================================================

  Future<void> _exportCsv() async {
    if (_isExportingCsv ||
        _isExportingPdf) {
      return;
    }

    setState(() {
      _isExportingCsv = true;
    });

    try {
      await _exportService.exportCsv();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'CSV report saved successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save CSV: '
            '${e.toString().replaceFirst(
                  'Exception: ',
                  '',
                )}',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingCsv = false;
        });
      }
    }
  }

  // ==========================================================
  // EXPORT PDF
  // ==========================================================

  Future<void> _exportPdf() async {
    if (_isExportingCsv ||
        _isExportingPdf) {
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      await _exportService.exportPdf();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'PDF report saved successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save PDF: '
            '${e.toString().replaceFirst(
                  'Exception: ',
                  '',
                )}',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isExporting =
        _isExportingCsv ||
        _isExportingPdf;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Export & Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .insert_chart_outlined,
                    size: 55,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Expense Reports',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Export your expense data and '
                    'generate professional reports.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // EXPORT DATA TITLE
          // ==================================================

          const Text(
            'Export Data',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // ==================================================
          // CSV
          // ==================================================

          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(
                  Icons.table_chart,
                ),
              ),
              title: const Text(
                'Export as CSV',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle: const Padding(
                padding:
                    EdgeInsets.only(top: 5),
                child: Text(
                  'Export date, title, category, '
                  'amount and description.',
                ),
              ),
              trailing: _isExportingCsv
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.chevron_right,
                    ),
              onTap: isExporting
                  ? null
                  : _exportCsv,
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // PDF
          // ==================================================

          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(
                  Icons.picture_as_pdf,
                ),
              ),
              title: const Text(
                'Generate PDF Report',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle: const Padding(
                padding:
                    EdgeInsets.only(top: 5),
                child: Text(
                  'Generate a detailed report with '
                  'summary and category-wise spending.',
                ),
              ),
              trailing: _isExportingPdf
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.chevron_right,
                    ),
              onTap: isExporting
                  ? null
                  : _exportPdf,
            ),
          ),

          const SizedBox(height: 30),

          // ==================================================
          // INFORMATION
          // ==================================================

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Report Information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  _infoRow(
                    Icons.receipt_long,
                    'All your expenses',
                  ),

                  _infoRow(
                    Icons.category_outlined,
                    'Category-wise spending',
                  ),

                  _infoRow(
                    Icons.calculate_outlined,
                    'Total spending',
                  ),

                  _infoRow(
                    Icons.calendar_month,
                    'Expense dates',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMATION ROW
  // ==========================================================

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}