import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/account_model.dart';

class AccountProvider extends ChangeNotifier {
  List<AccountModel> _accounts = [];
  int? _selectedAccountId;
  bool _isLoading = false;

  List<AccountModel> get accounts => _accounts;
  int? get selectedAccountId => _selectedAccountId;
  bool get isLoading => _isLoading;

  AccountModel? get selectedAccount {
    if (_selectedAccountId == null) return null;
    try {
      return _accounts.firstWhere((a) => a.id == _selectedAccountId);
    } catch (_) {
      return _accounts.isNotEmpty ? _accounts.first : null;
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await DBHelper.instance.getAllAccounts();

    // ✅ اختيار أول عهدة تلقائياً
    if (_selectedAccountId == null && _accounts.isNotEmpty) {
      _selectedAccountId = _accounts.first.id;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectAccount(int? id) {
    _selectedAccountId = id;
    notifyListeners();
  }

  Future<void> addAccount(AccountModel account) async {
    await DBHelper.instance.insertAccount(account);
    await loadAll();
  }

  Future<void> updateAccount(AccountModel account) async {
    await DBHelper.instance.updateAccount(account);
    await loadAll();
  }

  Future<String?> deleteAccount(AccountModel account) async {
    if (_accounts.length <= 1) {
      return 'لا يمكن حذف العهدة الأخيرة. يجب أن تكون هناك عهدة واحدة على الأقل.';
    }

    final count =
        await DBHelper.instance.countTransactionsByAccount(account.id!);
    if (count > 0) {
      return 'لا يمكن حذف العهدة لأنها تحتوي على $count معاملة. احذف المعاملات أولاً.';
    }

    await DBHelper.instance.deleteAccount(account.id!);
    await loadAll();
    return null;
  }
}