import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// ❌ لا تستورد share_plus أو open_filex

import '../models/account_model.dart';
import '../models/transaction_model.dart';

class ExportService {
  // ========== تصدير Excel ==========
  static Future<File> exportToExcel({
    required AccountModel account,
    required List<TransactionModel> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> categoryTotals,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير ${account.name}'];

    sheet.appendRow([TextCellValue('تقرير العهدة: ${account.name}')]);
    sheet.appendRow([TextCellValue('تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([TextCellValue('إجمالي الإيرادات'), TextCellValue(totalIncome.toStringAsFixed(2))]);
    sheet.appendRow([TextCellValue('إجمالي المصروفات'), TextCellValue(totalExpense.toStringAsFixed(2))]);
    sheet.appendRow([TextCellValue('الرصيد'), TextCellValue(balance.toStringAsFixed(2))]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([TextCellValue('التفاصيل حسب الفئة')]);
    sheet.appendRow([TextCellValue('الفئة'), TextCellValue('المبلغ'), TextCellValue('النسبة %')]);

    final total = totalIncome + totalExpense;
    categoryTotals.forEach((key, value) {
      final percentage = total > 0 ? (value / total * 100) : 0;
      sheet.appendRow([
        TextCellValue(key),
        TextCellValue(value.toStringAsFixed(2)),
        TextCellValue('${percentage.toStringAsFixed(2)}%'),
      ]);
    });
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([TextCellValue('جميع المعاملات')]);
    sheet.appendRow([
      TextCellValue('التاريخ'),
      TextCellValue('النوع'),
      TextCellValue('الفئة'),
      TextCellValue('الفئة الفرعية'),
      TextCellValue('المبلغ'),
      TextCellValue('طريقة الدفع'),
      TextCellValue('الملاحظة'),
    ]);

    for (final tx in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(tx.date)),
        TextCellValue(tx.type == 'income' ? 'إيراد' : 'مصروف'),
        TextCellValue(tx.categoryName),
        TextCellValue(tx.subCategoryName ?? '-'),
        TextCellValue(tx.amount.toStringAsFixed(2)),
        TextCellValue(tx.paymentMethod ?? '-'),
        TextCellValue(tx.note ?? '-'),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('فشل إنشاء الملف');

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'تقرير_${account.name}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file;
  }

  // ========== تصدير PDF ==========
  static Future<File> exportToPdf({
    required AccountModel account,
    required List<TransactionModel> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> categoryTotals,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex(account.colorHex ?? '#1565C0'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('تقرير العهدة: ${account.name}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 8),
                pw.Text('تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.white)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('الملخص المالي', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _pdfSummaryBox('إجمالي الإيرادات', totalIncome, PdfColors.green),
              pw.SizedBox(width: 10),
              _pdfSummaryBox('إجمالي المصروفات', totalExpense, PdfColors.red),
              pw.SizedBox(width: 10),
              _pdfSummaryBox('الرصيد', balance, PdfColors.blue),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('التفاصيل حسب الفئة', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['الفئة', 'المبلغ', 'النسبة %'],
            data: categoryTotals.entries.map((e) {
              final total = totalIncome + totalExpense;
              final percentage = total > 0 ? (e.value / total * 100) : 0;
              return [e.key, e.value.toStringAsFixed(2), '${percentage.toStringAsFixed(2)}%'];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
            cellAlignment: pw.Alignment.centerRight,
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          pw.Text('جميع المعاملات (${transactions.length})',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['التاريخ', 'النوع', 'الفئة', 'المبلغ'],
            data: transactions.map((tx) {
              return [
                DateFormat('yyyy-MM-dd').format(tx.date),
                tx.type == 'income' ? 'إيراد' : 'مصروف',
                tx.fullCategoryName,
                tx.amount.toStringAsFixed(2),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
            cellAlignment: pw.Alignment.centerRight,
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'تقرير_${account.name}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _pdfSummaryBox(String title, double value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(value.toStringAsFixed(2),
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          ],
        ),
      ),
    );
  }

  // ========== مشاركة الملف (باستخدام printing فقط) ==========
  static Future<void> shareFile(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;

    if (fileName.endsWith('.pdf')) {
      // ✅ مشاركة PDF
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      // ✅ مشاركة ملفات أخرى (Excel) - استخدم طباعة كحل بديل
      // ملاحظة: printing لا يدعم Excel مباشرة
      throw Exception('مشاركة Excel غير مدعومة حالياً. استخدم الطباعة لـ PDF.');
    }
  }

  // ========== طباعة PDF ==========
  static Future<void> printPdf(File file) async {
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }
}