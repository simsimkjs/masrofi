import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  String _period = 'all';
  String _format = 'pdf';
  bool _isExporting = false;

  final Map<String, String> _periods = {
    'all': 'الكل',
    'daily': 'اليوم',
    'weekly': 'هذا الأسبوع',
    'monthly': 'هذا الشهر',
    'yearly': 'هذه السنة',
  };

  @override
  Widget build(BuildContext context) {
    final account = context.read<AccountProvider>().selectedAccount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تصدير التقرير',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: account == null
          ? const Center(child: Text('الرجاء اختيار عهدة أولاً'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ✅ بطاقة العهدة
                _buildAccountCard(account),
                const SizedBox(height: 24),

                // ✅ اختيار الفترة
                const Text(
                  'الفترة:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _periods.entries.map((entry) {
                    final isSelected = _period == entry.key;
                    return ChoiceChip(
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _period = entry.key),
                      selectedColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ✅ اختيار الصيغة
                const Text(
                  'صيغة الملف:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _formatCard(
                        title: 'PDF',
                        icon: Icons.picture_as_pdf,
                        color: Colors.red,
                        isSelected: _format == 'pdf',
                        onTap: () => setState(() => _format = 'pdf'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _formatCard(
                        title: 'Excel',
                        icon: Icons.table_chart,
                        color: Colors.green,
                        isSelected: _format == 'excel',
                        onTap: () => setState(() => _format = 'excel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ✅ زر التصدير
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : () => _export(account),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _isExporting ? 'جاري التصدير...' : 'تصدير التقرير',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: account.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: account.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: account.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              account.icon,
              color: account.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'الرصيد الافتتاحي: ${account.openingBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[600],
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(AccountModel account) async {
    setState(() => _isExporting = true);

    try {
      final txProvider = context.read<TransactionProvider>();

      // ✅ تصفية المعاملات حسب الفترة
      final transactions = _period == 'all'
          ? txProvider.transactions
          : txProvider.getTransactionsByPeriod(_period);

      if (transactions.isEmpty) {
        _showError('لا توجد معاملات في هذه الفترة');
        setState(() => _isExporting = false);
        return;
      }

      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);

      final balance = totalIncome - totalExpense;

      final categoryTotals = txProvider.getCategoryTotals(
        type: 'expense',
        period: _period,
      );

      File file;
      if (_format == 'pdf') {
        file = await ExportService.exportToPdf(
          account: account,
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: balance,
          categoryTotals: categoryTotals,
        );
      } else {
        file = await ExportService.exportToExcel(
          account: account,
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: balance,
          categoryTotals: categoryTotals,
        );
      }

      if (!mounted) return;

      // ✅ عرض خيارات المشاركة
      _showSuccessDialog(file);
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ✅ دالة عرض نجاح التصدير
  void _showSuccessDialog(File file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'تم التصدير بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        content: Text(
          'تم حفظ الملف في:\n${file.path}',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          // ✅ مشاركة (فقط لـ PDF)
          if (_format == 'pdf')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ExportService.shareFile(file);
              },
              icon: const Icon(Icons.share),
              label: const Text(
                'مشاركة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          // ✅ طباعة (فقط لـ PDF)
          if (_format == 'pdf')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ExportService.printPdf(file);
              },
              icon: const Icon(Icons.print),
              label: const Text(
                'طباعة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ دالة عرض الأخطاء
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}