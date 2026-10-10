import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الفئات'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'المصروفات'),
              Tab(text: 'الإيرادات'),
            ],
          ),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _CategoryList(
                  categories: provider.mainExpenseCategories,
                  type: 'expense',
                ),
                _CategoryList(
                  categories: provider.mainIncomeCategories,
                  type: 'income',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String type;

  const _CategoryList({required this.categories, required this.type});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        categories.isEmpty
            ? const Center(child: Text('لا توجد فئات'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cat.color.withOpacity(0.15),
                        child: Icon(cat.icon, color: cat.color),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showCategoryDialog(
                              context,
                              category: cat,
                              type: type,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(context, cat),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

        // ✅ زر الإضافة العائم
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(context, type: type),
            icon: const Icon(Icons.add),
            label: const Text('إضافة فئة جديدة'),
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
  }

  void _showCategoryDialog(
    BuildContext context, {
    CategoryModel? category,
    required String type,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.iconName ?? 'category';
    String selectedColor = category?.colorHex ?? '#757575';

    final icons = {
      'category': Icons.category,
      'restaurant': Icons.restaurant,
      'car': Icons.directions_car,
      'shopping': Icons.shopping_bag,
      'receipt': Icons.receipt_long,
      'health': Icons.local_hospital,
      'school': Icons.school,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'gift': Icons.card_giftcard,
      'home': Icons.home,
      'phone': Icons.phone_android,
      'flight': Icons.flight,
      'sports': Icons.sports_soccer,
      'pets': Icons.pets,
    };

    final colors = [
      '#E53935', '#FB8C00', '#FDD835', '#43A047',
      '#00ACC1', '#1E88E5', '#3949AB', '#8E24AA',
      '#D81B60', '#6D4C41', '#546E7A', '#757575',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'إضافة فئة' : 'تعديل الفئة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الفئة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('الأيقونة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.entries.map((entry) {
                        final isSelected = selectedIcon == entry.key;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = entry.key),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              entry.value,
                              color: isSelected ? AppColors.primary : Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('اللون:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((hex) {
                        final isSelected = selectedColor == hex;
                        final color = Color(
                          int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
                        );
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = hex),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 3)
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
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;

                    final newCategory = CategoryModel(
                      id: category?.id,
                      name: nameController.text.trim(),
                      type: type,
                      iconName: selectedIcon,
                      colorHex: selectedColor,
                    );

                    final provider = context.read<SettingsProvider>();
                    if (category == null) {
                      await provider.addCategory(newCategory);
                    } else {
                      await provider.updateCategory(newCategory);
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('هل أنت متأكد من حذف "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final error = await context
                  .read<SettingsProvider>()
                  .deleteCategory(category);

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