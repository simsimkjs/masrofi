import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../utils/constants.dart';

class ManageAccountsScreen extends StatelessWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العهد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              provider.accounts.isEmpty
                  ? const Center(child: Text('لا توجد عهد'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: provider.accounts.length,
                      itemBuilder: (context, index) {
                        final account = provider.accounts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  account.color.withOpacity(0.15),
                              child: Icon(
                                account.icon,
                                color: account.color,
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            subtitle: Text(
                              'الرصيد الافتتاحي: ${account.openingBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _showAccountDialog(context, account),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteAccount(context, account),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: () => _showAccountDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة عهدة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAccountDialog(BuildContext context, [AccountModel? account]) {
    final nameController =
        TextEditingController(text: account?.name ?? '');
    final openingBalanceController = TextEditingController(
        text: account?.openingBalance.toString() ?? '0');
    String selectedIcon = account?.iconName ?? 'wallet';
    String selectedColor = account?.colorHex ?? '#1565C0';

    final icons = {
      'wallet': Icons.account_balance_wallet,
      'person': Icons.person,
      'work': Icons.work,
      'store': Icons.store,
      'home': Icons.home,
      'car': Icons.directions_car,
      'school': Icons.school,
      'business': Icons.business,
      'factory': Icons.factory,
    };

    final colors = [
      '#1565C0', '#2E7D32', '#C62828', '#EF6C00',
      '#6A1B9A', '#00838F', '#4E342E', '#37474F',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            account == null ? 'إضافة عهدة جديدة' : 'تعديل العهدة',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العهدة',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: مصروفات شخصية، الورشة',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: openingBalanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الرصيد الافتتاحي',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('الأيقونة:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.entries.map((entry) {
                    final isSelected = selectedIcon == entry.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => selectedIcon = entry.key),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('اللون:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((hex) {
                    final isSelected = selectedColor == hex;
                    final color = Color(int.parse(
                        'FF${hex.replaceFirst('#', '')}',
                        radix: 16));
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final balance = double.tryParse(
                        openingBalanceController.text.trim()) ??
                    0;

                final provider = context.read<AccountProvider>();

                final newAccount = AccountModel(
                  id: account?.id,
                  name: nameController.text.trim(),
                  iconName: selectedIcon,
                  colorHex: selectedColor,
                  openingBalance: balance,
                  createdAt: account?.createdAt ?? DateTime.now(),
                  isActive: true,
                );

                if (account == null) {
                  await provider.addAccount(newAccount);
                } else {
                  await provider.updateAccount(newAccount);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ',
                  style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccount(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العهدة',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف "${account.name}"؟\nسيتم حذف جميع معاملاتها وفئاتها.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final error =
                  await context.read<AccountProvider>().deleteAccount(account);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف',
                style: TextStyle(
                    color: Colors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}