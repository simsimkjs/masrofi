import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart'; // ✅ مهم
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type;

  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // ✅ المتغيرات المطلوبة
  CategoryModel? _selectedMainCategory;
  CategoryModel? _selectedSubCategory;
  List<CategoryModel> _subCategories = [];
  bool _isLoadingSubs = false;

  String? _paymentMethod;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSubCategories(CategoryModel category) async {
    setState(() {
      _isLoadingSubs = true;
      _selectedSubCategory = null;
      _subCategories = [];
    });

    final subs = await context
        .read<SettingsProvider>()
        .getSubCategories(category.id!);

    if (mounted) {
      setState(() {
        _subCategories = subs;
        _isLoadingSubs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(isExpense ? AppStrings.addExpense : AppStrings.addIncome),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (settings.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = isExpense
              ? settings.mainExpenseCategories
              : settings.mainIncomeCategories;

          if (_paymentMethod == null && settings.paymentMethods.isNotEmpty) {
            _paymentMethod = settings.paymentMethods.first.name;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ========== المبلغ ==========
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppStrings.amount,
                    hintText: 'مثال: 100.50',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال المبلغ';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    if (parsed <= 0) {
                      return 'المبلغ يجب أن يكون أكبر من صفر';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ========== الفئة الرئيسية ==========
                if (categories.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا توجد فئات. الرجاء إضافة فئة من الإعدادات.',
                            style: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedMainCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'الفئة الرئيسية',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<CategoryModel>(
                        value: cat,
                        child: Row(
                          children: [
                            cat.iconWidget,
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedMainCategory = value);
                      if (value != null) {
                        _loadSubCategories(value);
                      }
                    },
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار فئة' : null,
                  ),
                const SizedBox(height: 16),

                // ========== الفئة الفرعية ==========
                if (_isLoadingSubs)
                  const Center(child: CircularProgressIndicator())
                else if (_subCategories.isNotEmpty)
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedSubCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'الفئة الفرعية (اختياري)',
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          const Icon(Icons.subdirectory_arrow_right),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _subCategories.map((cat) {
                      return DropdownMenuItem<CategoryModel>(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              color: cat.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSubCategory = value);
                    },
                  ),
                const SizedBox(height: 16),

                // ========== طريقة الدفع ==========
                if (settings.paymentMethods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا توجد طرق دفع. الرجاء إضافتها من الإعدادات.',
                            style: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.paymentMethod,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.payment),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: settings.paymentMethods.map((pm) {
                      return DropdownMenuItem<String>(
                        value: pm.name,
                        child: Text(
                          pm.name,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _paymentMethod = value);
                    },
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار طريقة دفع' : null,
                  ),
                const SizedBox(height: 16),

                // ========== الملاحظة ==========
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppStrings.note,
                    hintText: 'اختياري',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // ========== التاريخ ==========
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  title: const Text(
                    AppStrings.date,
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd – HH:mm', 'ar')
                        .format(_selectedDate),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 32),

                // ========== زر الحفظ ==========
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTransaction,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'جاري الحفظ...' : AppStrings.save,
                    style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: color.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ✅ دالة الحفظ
  Future<void> _saveTransaction() async {
    // 1. التحقق من النموذج
    if (!_formKey.currentState!.validate()) {
      _showError('الرجاء تعبئة جميع الحقول المطلوبة');
      return;
    }

    // 2. التحقق من الفئة
    if (_selectedMainCategory == null) {
      _showError('الرجاء اختيار الفئة الرئيسية');
      return;
    }

    // 3. التحقق من طريقة الدفع
    if (_paymentMethod == null || _paymentMethod!.isEmpty) {
      _showError('الرجاء اختيار طريقة الدفع');
      return;
    }

    // 4. ✅ التحقق من العهدة
    final accountId = context.read<AccountProvider>().selectedAccountId;
    if (accountId == null) {
      _showError('الرجاء اختيار عهدة أولاً');
      return;
    }

    // 5. التحقق من المبلغ
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('المبلغ غير صحيح');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tx = TransactionModel(
        amount: amount,
        type: widget.type,
        categoryName: _selectedMainCategory!.name,
        subCategoryName: _selectedSubCategory?.name,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        accountId: accountId, // ✅ ربط بالعهدة
        date: _selectedDate,
      );

      await context.read<TransactionProvider>().addTransaction(tx);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم حفظ ${widget.type == "expense" ? "المصروف" : "الإيراد"} بنجاح ✅',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.income,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('حدث خطأ أثناء الحفظ: $e');
      }
    }
  }

  // ✅ دالة عرض الأخطاء
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}