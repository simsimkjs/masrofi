import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'manage_accounts_screen.dart';

class AccountSelectionScreen extends StatelessWidget {
  const AccountSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('اختر العهدة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wallet, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('لا توجد عهد. أضف عهدة جديدة.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openManageAccounts(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة عهدة'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'اختر العهدة للبدء:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              ...provider.accounts.map((account) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: account.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: account.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        account.icon,
                        color: account.color,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    subtitle: Text(
                      'الرصيد الافتتاحي: ${account.openingBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // ✅ تعيين العهدة
                      context.read<AccountProvider>().selectAccount(account.id);
                      context.read<TransactionProvider>().setAccount(account.id);
                      context.read<SettingsProvider>().setAccount(account.id);

                      // ✅ الانتقال للوحة التحكم
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _openManageAccounts(context),
                icon: const Icon(Icons.settings),
                label: const Text('إدارة العهد'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openManageAccounts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageAccountsScreen()),
    );
  }
}