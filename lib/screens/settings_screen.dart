import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'manage_categories_screen.dart';
import 'manage_payment_methods_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _sectionTitle('التخصيص'),
          _settingsTile(
            context,
            icon: Icons.category,
            title: 'إدارة الفئات',
            subtitle: 'إضافة، تعديل، حذف فئات المصروفات والإيرادات',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              );
            },
          ),
          _settingsTile(
            context,
            icon: Icons.payment,
            title: 'طرق الدفع',
            subtitle: 'إضافة، تعديل، حذف طرق الدفع',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagePaymentMethodsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _sectionTitle('عام'),
          _settingsTile(
            context,
            icon: Icons.info_outline,
            title: 'حول التطبيق',
            subtitle: 'الإصدار 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'إدارة المصروفات',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}