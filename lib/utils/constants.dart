import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFC62828);
  static const Color transfer = Color(0xFFEF6C00);
  static const Color transactions = Color(0xFF00838F);
  static const Color background = Color(0xFFF5F5F5);
}

class AppStrings {
  static const String appName = 'إدارة المصروفات';
  static const String income = 'الإيرادات';
  static const String expenses = 'المصروفات';
  static const String balance = 'الرصيد';
  static const String addExpense = 'إضافة المصروفات';
  static const String addIncome = 'إضافة الإيرادات';
  static const String transactions = 'المعاملات';
  static const String transfer = 'حوالة نقدية';
  static const String recentTransactions = 'آخر المعاملات';
  static const String save = 'حفظ';
  static const String amount = 'المبلغ';
  static const String category = 'الفئة';
  static const String paymentMethod = 'طريقة الدفع';
  static const String note = 'ملاحظة';
  static const String date = 'التاريخ';
  static const String cash = 'نقدي';
  static const String card = 'بطاقة';
  static const String wallet = 'محفظة إلكترونية';
}

// ✅ أنماط نصية جاهزة
class AppTextStyles {
  static const String fontFamily = 'Cairo';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}

class AppIcons {
  static const IconData income = Icons.add_circle_outline;
  static const IconData expense = Icons.remove_circle_outline;
  static const IconData transactions = Icons.list_alt;
  static const IconData transfer = Icons.swap_horiz;
  static const IconData food = Icons.restaurant;
  static const IconData transport = Icons.directions_car;
  static const IconData shopping = Icons.shopping_bag;
  static const IconData bills = Icons.receipt_long;
  static const IconData health = Icons.local_hospital;
  static const IconData education = Icons.school;
  static const IconData salary = Icons.work;
  static const IconData other = Icons.category;
}