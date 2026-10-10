import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'account_selection_screen.dart';
import 'add_transaction_screen.dart';
import 'export_report_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'transactions_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Consumer<AccountProvider>(
          builder: (context, provider, child) {
            final account = provider.selectedAccount;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  account?.name ?? AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (account != null)
                  Text(
                    'الرصيد الافتتاحي: ${account.openingBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Cairo',
                      color: Colors.white70,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          // ✅ تبديل العهدة
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'تبديل العهدة',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSelectionScreen(),
                ),
              );
            },
          ),
          // ✅ تصدير التقرير
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'تصدير التقرير',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExportReportScreen(),
                ),
              );
            },
          ),
          // ✅ التقارير
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'التقارير',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
          ),
          // ✅ الإعدادات
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.loadAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ✅ بطاقة الملخص
                SummaryCard(
                  income: provider.totalIncome,
                  expense: provider.totalExpense,
                  balance: provider.balance,
                ),
                const SizedBox(height: 20),

                // ✅ الأزرار الرئيسية
                _buildMainActions(context),
                const SizedBox(height: 20),

                // ✅ عنوان آخر المعاملات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.recentTransactions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionsListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      label: const Text(
                        'عرض الكل',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ✅ قائمة آخر المعاملات
                if (provider.transactions.isEmpty)
                  _buildEmptyState(context)
                else
                  ...provider.transactions.take(5).map(
                        (tx) => TransactionTile(
                          transaction: tx,
                          onDelete: () =>
                              provider.deleteTransaction(tx.id!),
                        ),
                      ),

                // ✅ زر عرض جميع المعاملات
                if (provider.transactions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  if (provider.transactions.length > 5)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TransactionsListScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'عرض جميع المعاملات (${provider.transactions.length})',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ الأزرار الرئيسية (6 أزرار)
  Widget _buildMainActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        // إضافة المصروفات
        _actionButton(
          context,
          title: AppStrings.addExpense,
          icon: Icons.remove_circle_outline,
          color: AppColors.expense,
          onTap: () => _openAddScreen(context, 'expense'),
        ),

        // إضافة الإيرادات
        _actionButton(
          context,
          title: AppStrings.addIncome,
          icon: Icons.add_circle_outline,
          color: AppColors.income,
          onTap: () => _openAddScreen(context, 'income'),
        ),

        // المعاملات
        _actionButton(
          context,
          title: AppStrings.transactions,
          icon: Icons.list_alt,
          color: AppColors.transactions,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionsListScreen(),
              ),
            );
          },
        ),

        // التقارير
        _actionButton(
          context,
          title: 'التقارير',
          icon: Icons.pie_chart,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportsScreen(),
              ),
            );
          },
        ),

        // تصدير التقرير
        _actionButton(
          context,
          title: 'تصدير',
          icon: Icons.download,
          color: Colors.indigo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExportReportScreen(),
              ),
            );
          },
        ),

        // الإعدادات
        _actionButton(
          context,
          title: 'الإعدادات',
          icon: Icons.settings,
          color: Colors.blueGrey,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ✅ زر مخصص
  Widget _actionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ حالة فارغة
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاملات بعد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة مصروفاتك وإيراداتك',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openAddScreen(context, 'expense'),
            icon: const Icon(Icons.add),
            label: const Text(
              'إضافة معاملة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ فتح شاشة إضافة معاملة
  void _openAddScreen(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(type: type),
      ),
    );
  }
}