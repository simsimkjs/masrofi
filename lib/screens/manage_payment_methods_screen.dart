import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment_method_model.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class ManagePaymentMethodsScreen extends StatelessWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              provider.paymentMethods.isEmpty
                  ? const Center(child: Text('لا توجد طرق دفع'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: provider.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final pm = provider.paymentMethods[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE3F2FD),
                              child: Icon(
                                Icons.payment,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              pm.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      _showDialog(context, pm: pm),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _delete(context, pm),
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
                  onPressed: () => _showDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة طريقة دفع جديدة'),
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

  void _showDialog(BuildContext context, {PaymentMethodModel? pm}) {
    final nameController = TextEditingController(text: pm?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pm == null ? 'إضافة طريقة دفع' : 'تعديل طريقة الدفع'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'الاسم',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final provider = context.read<SettingsProvider>();
              final newPm = PaymentMethodModel(
                id: pm?.id,
                name: nameController.text.trim(),
              );

              if (pm == null) {
                await provider.addPaymentMethod(newPm);
              } else {
                await provider.updatePaymentMethod(newPm);
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, PaymentMethodModel pm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف طريقة الدفع'),
        content: Text('هل أنت متأكد من حذف "${pm.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final error =
                  await context.read<SettingsProvider>().deletePaymentMethod(pm);

              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}