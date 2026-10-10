import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;
  final Color defaultColor;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.defaultColor,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int _touchedIndex = -1;

  // ✅ ألوان جاهزة للرسم
  final List<Color> _colors = [
    const Color(0xFFE53935),
    const Color(0xFFFB8C00),
    const Color(0xFFFDD835),
    const Color(0xFF43A047),
    const Color(0xFF00ACC1),
    const Color(0xFF1E88E5),
    const Color(0xFF3949AB),
    const Color(0xFF8E24AA),
    const Color(0xFFD81B60),
    const Color(0xFF6D4C41),
    const Color(0xFF546E7A),
    const Color(0xFF757575),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'لا توجد بيانات لعرضها',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final total = widget.data.values.fold(0.0, (sum, v) => sum + v);

    return Column(
      children: [
        // ✅ الرسم الدائري
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _buildSections(total),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ✅ قائمة التفاصيل
        _buildLegend(total),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final entries = widget.data.entries.toList();

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final percentage = (entry.value / total) * 100;
      final isTouched = index == _touchedIndex;
      final color = _colors[index % _colors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: percentage >= 5
            ? '${percentage.toStringAsFixed(1)}%'
            : '',
        radius: isTouched ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildLegend(double total) {
    final entries = widget.data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          final percentage = (entry.value / total) * 100;
          final color = _colors[index % _colors.length];
          final isTouched = index == _touchedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // ✅ مربع اللون
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ اسم الفئة
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight:
                          isTouched ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ✅ النسبة
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ المبلغ
                Text(
                  entry.value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}