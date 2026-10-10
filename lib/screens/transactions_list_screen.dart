import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/transaction_tile.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _period = 'monthly';

  final Map<String, String> _periods = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
    'yearly': 'سنوي',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final filtered = provider.getTransactionsByPeriod(_period);

          return Column(
            children: [
              // ✅ شريط التصفية
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.entries.map((entry) {
                      final isSelected = _period == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _period = entry.key),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ✅ ملخص الفترة
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem(
                      'الإيرادات',
                      filtered
                          .where((t) => t.type == 'income')
                          .fold(0.0, (s, t) => s + t.amount),
                      AppColors.income,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _summaryItem(
                      'المصروفات',
                      filtered
                          .where((t) => t.type == 'expense')
                          .fold(0.0, (s, t) => s + t.amount),
                      AppColors.expense,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ✅ قائمة المعاملات
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا توجد معاملات في هذه الفترة'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return TransactionTile(
                            transaction: tx,
                            onDelete: () =>
                                provider.deleteTransaction(tx.id!),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}