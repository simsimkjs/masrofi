class TransactionModel {
  final int? id;
  final double amount;
  final String type;
  final String categoryName;
  final String? subCategoryName;
  final String? paymentMethod;
  final String? note;
  final int? accountId; // ✅ مضاف
  final DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.subCategoryName,
    this.paymentMethod,
    this.note,
    this.accountId,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type,
        'categoryName': categoryName,
        'subCategoryName': subCategoryName,
        'paymentMethod': paymentMethod,
        'note': note,
        'accountId': accountId,
        'date': date.toIso8601String(),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        categoryName: map['categoryName'] as String,
        subCategoryName: map['subCategoryName'] as String?,
        paymentMethod: map['paymentMethod'] as String?,
        note: map['note'] as String?,
        accountId: map['accountId'] as int?,
        date: DateTime.parse(map['date'] as String),
      );

  String get fullCategoryName {
    if (subCategoryName != null && subCategoryName!.isNotEmpty) {
      return '$categoryName › $subCategoryName';
    }
    return categoryName;
  }
}