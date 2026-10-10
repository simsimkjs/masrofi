class PaymentMethodModel {
  final int? id;
  final String name;

  PaymentMethodModel({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) =>
      PaymentMethodModel(
        id: map['id'] as int?,
        name: map['name'] as String,
      );
}