import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الرصيد
          Text(
            AppStrings.balance,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            balance.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: balance >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _item(
                  AppStrings.income,
                  income,
                  AppColors.income,
                  Icons.arrow_downward,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _item(
                  AppStrings.expenses,
                  expense,
                  AppColors.expense,
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}