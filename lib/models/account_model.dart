import 'package:flutter/material.dart';

class AccountModel {
  final int? id;
  final String name;
  final String? iconName;
  final String? colorHex;
  final double openingBalance;
  final DateTime createdAt;
  final bool isActive;

  AccountModel({
    this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    this.openingBalance = 0,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'colorHex': colorHex,
        'openingBalance': openingBalance,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive ? 1 : 0,
      };

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        iconName: map['iconName'] as String?,
        colorHex: map['colorHex'] as String?,
        openingBalance: (map['openingBalance'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isActive: (map['isActive'] as int?) == 1,
      );

  // ✅ الأيقونة
  IconData get icon {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'work':
        return Icons.work;
      case 'store':
        return Icons.store;
      case 'home':
        return Icons.home;
      case 'car':
        return Icons.directions_car;
      case 'school':
        return Icons.school;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'business':
        return Icons.business;
      case 'factory':
        return Icons.factory;
      default:
        return Icons.account_balance_wallet;
    }
  }

  // ✅ اللون
  Color get color {
    if (colorHex == null || colorHex!.isEmpty) return Colors.blue;
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}