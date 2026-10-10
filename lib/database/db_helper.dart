import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/payment_method_model.dart';
import '../models/account_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 4, // ✅ رفع الإصدار
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ✅ جدول العهد (Accounts)
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconName TEXT,
        colorHex TEXT,
        openingBalance REAL DEFAULT 0,
        createdAt TEXT NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // جدول المعاملات (مع accountId)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        subCategoryName TEXT,
        paymentMethod TEXT,
        note TEXT,
        accountId INTEGER,
        date TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts(id)
      )
    ''');

    // جدول الفئات (مع accountId)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        iconName TEXT,
        colorHex TEXT,
        parentId INTEGER,
        customIconPath TEXT,
        accountId INTEGER,
        FOREIGN KEY (accountId) REFERENCES accounts(id)
      )
    ''');

    // جدول طرق الدفع
    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await _insertDefaultData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // ✅ إنشاء جدول الحسابات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          iconName TEXT,
          colorHex TEXT,
          openingBalance REAL DEFAULT 0,
          createdAt TEXT NOT NULL,
          isActive INTEGER DEFAULT 1
        )
      ''');

      // ✅ إضافة accountId للمعاملات
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN accountId INTEGER');
      } catch (_) {}

      // ✅ إضافة accountId للفئات
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN accountId INTEGER');
      } catch (_) {}

      // ✅ إنشاء عهدة افتراضية
      final defaultAccountId = await db.insert('accounts', {
        'name': 'العهدة الرئيسية',
        'iconName': 'wallet',
        'colorHex': '#1565C0',
        'openingBalance': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': 1,
      });

      // ✅ ربط جميع المعاملات والفئات بالعهدة الافتراضية
      await db.update('transactions', {'accountId': defaultAccountId});
      await db.update('categories', {'accountId': defaultAccountId});
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    // ✅ إنشاء عهدة افتراضية
    final accountId = await db.insert('accounts', {
      'name': 'مصروفات شخصية',
      'iconName': 'person',
      'colorHex': '#1565C0',
      'openingBalance': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': 1,
    });

    // فئات المصروفات
    final expenseCategories = [
      {'name': 'طعام', 'type': 'expense', 'iconName': 'restaurant', 'colorHex': '#E53935', 'accountId': accountId},
      {'name': 'مواصلات', 'type': 'expense', 'iconName': 'car', 'colorHex': '#FB8C00', 'accountId': accountId},
      {'name': 'تسوق', 'type': 'expense', 'iconName': 'shopping', 'colorHex': '#8E24AA', 'accountId': accountId},
      {'name': 'فواتير', 'type': 'expense', 'iconName': 'receipt', 'colorHex': '#3949AB', 'accountId': accountId},
      {'name': 'صحة', 'type': 'expense', 'iconName': 'health', 'colorHex': '#00897B', 'accountId': accountId},
      {'name': 'تعليم', 'type': 'expense', 'iconName': 'school', 'colorHex': '#1E88E5', 'accountId': accountId},
      {'name': 'أخرى', 'type': 'expense', 'iconName': 'category', 'colorHex': '#757575', 'accountId': accountId},
    ];

    final incomeCategories = [
      {'name': 'راتب', 'type': 'income', 'iconName': 'work', 'colorHex': '#43A047', 'accountId': accountId},
      {'name': 'عمل حر', 'type': 'income', 'iconName': 'laptop', 'colorHex': '#00ACC1', 'accountId': accountId},
      {'name': 'هدية', 'type': 'income', 'iconName': 'gift', 'colorHex': '#D81B60', 'accountId': accountId},
      {'name': 'أخرى', 'type': 'income', 'iconName': 'category', 'colorHex': '#757575', 'accountId': accountId},
    ];

    for (final cat in [...expenseCategories, ...incomeCategories]) {
      await db.insert('categories', cat);
    }

    // فئات فرعية للطعام
    final foodResult = await db.query('categories',
        where: 'name = ? AND parentId IS NULL AND accountId = ?',
        whereArgs: ['طعام', accountId],
        limit: 1);
    if (foodResult.isNotEmpty) {
      final foodId = foodResult.first['id'];
      for (final sub in ['فطور', 'غداء', 'عشاء']) {
        await db.insert('categories', {
          'name': sub,
          'type': 'expense',
          'iconName': 'restaurant',
          'colorHex': '#E53935',
          'parentId': foodId,
          'accountId': accountId,
        });
      }
    }

    for (final pm in ['نقدي', 'بطاقة', 'محفظة إلكترونية', 'تحويل بنكي']) {
      await db.insert('payment_methods', {'name': pm});
    }
  }

  // ========== العهد ==========
  Future<List<AccountModel>> getAllAccounts() async {
    final db = await database;
    final result = await db.query('accounts', orderBy: 'id ASC');
    return result.map((e) => AccountModel.fromMap(e)).toList();
  }

  Future<AccountModel?> getAccountById(int id) async {
    final db = await database;
    final result = await db.query('accounts',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return AccountModel.fromMap(result.first);
  }

  Future<int> insertAccount(AccountModel account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(AccountModel account) async {
    final db = await database;
    return await db.update('accounts', account.toMap(),
        where: 'id = ?', whereArgs: [account.id]);
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    // حذف جميع المعاملات والفئات المرتبطة
    await db.delete('transactions', where: 'accountId = ?', whereArgs: [id]);
    await db.delete('categories', where: 'accountId = ?', whereArgs: [id]);
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countTransactionsByAccount(int accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE accountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== المعاملات ==========
  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // ✅ معاملات عهدة محددة
  Future<List<TransactionModel>> getTransactionsByAccount(int accountId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ========== الفئات ==========
  Future<List<CategoryModel>> getMainCategoriesByType({
    required String type,
    required int accountId,
  }) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'type = ? AND parentId IS NULL AND accountId = ?',
      whereArgs: [type, accountId],
      orderBy: 'id ASC',
    );
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<List<CategoryModel>> getSubCategories(int parentId) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'parentId = ?',
      whereArgs: [parentId],
      orderBy: 'id ASC',
    );
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await database;
    final result = await db.query('categories',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return CategoryModel.fromMap(result.first);
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'parentId = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countTransactionsByCategory(String categoryName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE categoryName = ? OR subCategoryName = ?',
      [categoryName, categoryName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ✅ تحديث اسم الفئة في المعاملات
  Future<int> updateCategoryNameInTransactions({
    required String oldName,
    required String newName,
  }) async {
    final db = await database;
    final result1 = await db.update('transactions', {'categoryName': newName},
        where: 'categoryName = ?', whereArgs: [oldName]);
    final result2 = await db.update('transactions', {'subCategoryName': newName},
        where: 'subCategoryName = ?', whereArgs: [oldName]);
    return result1 + result2;
  }

  // ✅ نقل المعاملات من فئة إلى أخرى
  Future<int> moveTransactionsToCategory({
    required String fromCategory,
    required String toCategory,
  }) async {
    final db = await database;
    final result1 = await db.update('transactions', {'categoryName': toCategory},
        where: 'categoryName = ?', whereArgs: [fromCategory]);
    final result2 = await db.update('transactions', {'subCategoryName': toCategory},
        where: 'subCategoryName = ?', whereArgs: [fromCategory]);
    return result1 + result2;
  }

  Future<String?> deleteCategoryWithMove({
    required int categoryId,
    required String categoryName,
    required String moveToCategory,
  }) async {
    final db = await database;
    await moveTransactionsToCategory(
        fromCategory: categoryName, toCategory: moveToCategory);
    await db.delete('categories', where: 'parentId = ?', whereArgs: [categoryId]);
    await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
    return null;
  }

  // ========== طرق الدفع ==========
  Future<List<PaymentMethodModel>> getAllPaymentMethods() async {
    final db = await database;
    final result = await db.query('payment_methods', orderBy: 'id ASC');
    return result.map((e) => PaymentMethodModel.fromMap(e)).toList();
  }

  Future<int> insertPaymentMethod(PaymentMethodModel pm) async {
    final db = await database;
    return await db.insert('payment_methods', pm.toMap());
  }

  Future<int> updatePaymentMethod(PaymentMethodModel pm) async {
    final db = await database;
    return await db.update('payment_methods', pm.toMap(),
        where: 'id = ?', whereArgs: [pm.id]);
  }

  Future<int> deletePaymentMethod(int id) async {
    final db = await database;
    return await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countTransactionsByPaymentMethod(String methodName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE paymentMethod = ?',
      [methodName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ✅ حفظ صورة
  Future<String> saveImageToAppFolder(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final iconsDir = Directory(join(appDir.path, 'custom_icons'));
    if (!await iconsDir.exists()) {
      await iconsDir.create(recursive: true);
    }
    final fileName = 'icon_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await image.copy(join(iconsDir.path, fileName));
    return savedImage.path;
  }

  Future<void> deleteCustomIcon(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}