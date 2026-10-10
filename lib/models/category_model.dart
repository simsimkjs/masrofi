import 'dart:io';
import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String type;
  final String? iconName;
  final String? colorHex;
  final int? parentId;
  final String? customIconPath;
  final int? accountId; // ✅ مضاف

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.iconName,
    this.colorHex,
    this.parentId,
    this.customIconPath,
    this.accountId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'iconName': iconName,
        'colorHex': colorHex,
        'parentId': parentId,
        'customIconPath': customIconPath,
        'accountId': accountId,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String,
        iconName: map['iconName'] as String?,
        colorHex: map['colorHex'] as String?,
        parentId: map['parentId'] as int?,
        customIconPath: map['customIconPath'] as String?,
        accountId: map['accountId'] as int?,
      );

  bool get isSubCategory => parentId != null;

  bool get hasCustomIcon =>
      customIconPath != null && customIconPath!.isNotEmpty;

  Widget get iconWidget {
    if (hasCustomIcon) {
      final file = File(customIconPath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, width: 24, height: 24, fit: BoxFit.cover),
        );
      }
    }
    return Icon(icon, color: color, size: 24);
  }

  IconData get icon {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'car': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'receipt': return Icons.receipt_long;
      case 'health': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'laptop': return Icons.laptop;
      case 'gift': return Icons.card_giftcard;
      case 'home': return Icons.home;
      case 'phone': return Icons.phone_android;
      case 'flight': return Icons.flight;
      case 'sports': return Icons.sports_soccer;
      case 'pets': return Icons.pets;
      case 'category':
      default: return Icons.category;
    }
  }

  Color get color {
    if (colorHex == null || colorHex!.isEmpty) return Colors.grey;
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}