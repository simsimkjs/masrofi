import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/category_model.dart';
import '../models/payment_method_model.dart';

class SettingsProvider extends ChangeNotifier {
  List<CategoryModel> _mainExpenseCategories = [];
  List<CategoryModel> _mainIncomeCategories = [];
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;
  int? _accountId;

  List<CategoryModel> get mainExpenseCategories => _mainExpenseCategories;
  List<CategoryModel> get mainIncomeCategories => _mainIncomeCategories;
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;

  // ✅ تعيين العهدة
  void setAccount(int? accountId) {
    _accountId = accountId;
    loadAll();
  }

  Future<void> loadAll() async {
    if (_accountId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _mainExpenseCategories = await DBHelper.instance.getMainCategoriesByType(
        type: 'expense',
        accountId: _accountId!,
      );
      _mainIncomeCategories = await DBHelper.instance.getMainCategoriesByType(
        type: 'income',
        accountId: _accountId!,
      );
      _paymentMethods = await DBHelper.instance.getAllPaymentMethods();
    } catch (e) {
      debugPrint('خطأ: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<CategoryModel>> getSubCategories(int parentId) async {
    return await DBHelper.instance.getSubCategories(parentId);
  }

  Future<void> addCategory(CategoryModel category) async {
    final withAccount = CategoryModel(
      id: category.id,
      name: category.name,
      type: category.type,
      iconName: category.iconName,
      colorHex: category.colorHex,
      parentId: category.parentId,
      customIconPath: category.customIconPath,
      accountId: _accountId,
    );
    await DBHelper.instance.insertCategory(withAccount);
    await loadAll();
  }

  Future<String?> updateCategory(CategoryModel category) async {
    try {
      final oldCategory = await DBHelper.instance.getCategoryById(category.id!);
      if (oldCategory == null) return 'الفئة غير موجودة';

      if (oldCategory.name != category.name) {
        await DBHelper.instance.updateCategoryNameInTransactions(
          oldName: oldCategory.name,
          newName: category.name,
        );
      }

      await DBHelper.instance.updateCategory(category);
      await loadAll();
      return null;
    } catch (e) {
      return 'حدث خطأ: $e';
    }
  }

  Future<String?> deleteCategoryWithMove({
    required CategoryModel category,
    required String moveToCategory,
  }) async {
    try {
      final count = await DBHelper.instance
          .countTransactionsByCategory(category.name);

      if (count > 0) {
        await DBHelper.instance.deleteCategoryWithMove(
          categoryId: category.id!,
          categoryName: category.name,
          moveToCategory: moveToCategory,
        );
      } else {
        await DBHelper.instance.deleteCustomIcon(category.customIconPath);
        await DBHelper.instance.deleteCategory(category.id!);
      }

      await loadAll();
      return null;
    } catch (e) {
      return 'حدث خطأ: $e';
    }
  }

  Future<String?> deleteCategory(CategoryModel category) async {
    final count = await DBHelper.instance
        .countTransactionsByCategory(category.name);
    if (count > 0) {
      return 'لا يمكن حذف الفئة لأنها مستخدمة في $count معاملة';
    }
    await DBHelper.instance.deleteCustomIcon(category.customIconPath);
    await DBHelper.instance.deleteCategory(category.id!);
    await loadAll();
    return null;
  }

  // ========== طرق الدفع ==========
  Future<void> addPaymentMethod(PaymentMethodModel pm) async {
    await DBHelper.instance.insertPaymentMethod(pm);
    await loadAll();
  }

  Future<void> updatePaymentMethod(PaymentMethodModel pm) async {
    await DBHelper.instance.updatePaymentMethod(pm);
    await loadAll();
  }

  Future<String?> deletePaymentMethod(PaymentMethodModel pm) async {
    final count = await DBHelper.instance
        .countTransactionsByPaymentMethod(pm.name);
    if (count > 0) {
      return 'لا يمكن حذف طريقة الدفع لأنها مستخدمة في $count معاملة';
    }
    await DBHelper.instance.deletePaymentMethod(pm.id!);
    await loadAll();
    return null;
  }
}