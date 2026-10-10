import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  int? _accountId;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // ✅ تعيين العهدة الحالية
  void setAccount(int? accountId) {
    _accountId = accountId;
    loadAll();
  }

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    if (_accountId != null) {
      _transactions =
          await DBHelper.instance.getTransactionsByAccount(_accountId!);
    } else {
      _transactions = await DBHelper.instance.getAllTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await DBHelper.instance.insertTransaction(tx);
    await loadAll();
  }

  Future<void> deleteTransaction(int id) async {
    await DBHelper.instance.deleteTransaction(id);
    await loadAll();
  }

  List<TransactionModel> getTransactionsByPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(2000);
    }

    return _transactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  Map<String, double> getCategoryTotals({
    required String type,
    String period = 'monthly',
  }) {
    final filtered = getTransactionsByPeriod(period)
        .where((t) => t.type == type)
        .toList();

    final Map<String, double> totals = {};
    for (final tx in filtered) {
      final key = tx.subCategoryName != null && tx.subCategoryName!.isNotEmpty
          ? '${tx.categoryName} › ${tx.subCategoryName}'
          : tx.categoryName;
      totals[key] = (totals[key] ?? 0) + tx.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  Map<String, double> getMainCategoryTotals({
    required String type,
    String period = 'monthly',
  }) {
    final filtered = getTransactionsByPeriod(period)
        .where((t) => t.type == type)
        .toList();

    final Map<String, double> totals = {};
    for (final tx in filtered) {
      totals[tx.categoryName] = (totals[tx.categoryName] ?? 0) + tx.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  double getTotalByPeriod(String type, String period) {
    return getTransactionsByPeriod(period)
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getChartDataByPeriod({
    required String type,
    required String period,
  }) {
    final Map<String, double> data = {};
    final now = DateTime.now();

    if (period == 'daily' || period == 'weekly') {
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        final total = _transactions
            .where((t) =>
                t.type == type &&
                t.date.isAfter(dayStart) &&
                t.date.isBefore(dayEnd))
            .fold(0.0, (sum, t) => sum + t.amount);
        data['${date.day}/${date.month}'] = total;
      }
    } else if (period == 'monthly') {
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthStart = DateTime(date.year, date.month, 1);
        final monthEnd = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
        final total = _transactions
            .where((t) =>
                t.type == type &&
                t.date.isAfter(monthStart) &&
                t.date.isBefore(monthEnd))
            .fold(0.0, (sum, t) => sum + t.amount);
        final months = [
          'يناير','فبراير','مارس','أبريل','مايو','يونيو',
          'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
        ];
        data[months[date.month - 1]] = total;
      }
    } else {
      for (int i = 4; i >= 0; i--) {
        final year = now.year - i;
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year, 12, 31, 23, 59, 59);
        final total = _transactions
            .where((t) =>
                t.type == type &&
                t.date.isAfter(yearStart) &&
                t.date.isBefore(yearEnd))
            .fold(0.0, (sum, t) => sum + t.amount);
        data['$year'] = total;
      }
    }

    return data;
  }
}