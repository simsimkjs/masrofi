import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _period = 'monthly';
  String _type = 'expense';
  bool _showMainCategoriesOnly = false;

  final Map<String, String> _periods = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
    'yearly': 'سنوي',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والرسوم البيانية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'دائري', icon: Icon(Icons.pie_chart)),
            Tab(text: 'شريطي', icon: Icon(Icons.bar_chart)),
            Tab(text: 'خطي', icon: Icon(Icons.show_chart)),
          ],
        ),
      ),
      body: Column(
        children: [
          // ✅ شريط الفلاتر
          _buildFilters(color),

          // ✅ المحتوى
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categoryData = _showMainCategoriesOnly
                    ? provider.getMainCategoryTotals(
                        type: _type, period: _period)
                    : provider.getCategoryTotals(
                        type: _type, period: _period);

                final chartData = provider.getChartDataByPeriod(
                  type: _type,
                  period: _period,
                );

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // ✅ Pie Chart
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryCard(
                            title: isExpense ? 'إجمالي المصروفات' : 'إجمالي الإيرادات',
                            value: provider.getTotalByPeriod(_type, _period),
                            color: color,
                          ),
                          const SizedBox(height: 16),
                          if (categoryData.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('لا توجد بيانات لعرضها'),
                            )
                          else
                            PieChartWidget(
                              data: categoryData,
                              defaultColor: color,
                            ),
                        ],
                      ),
                    ),

                    // ✅ Bar Chart
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryCard(
                            title: 'مقارنة الفترات',
                            value: provider.getTotalByPeriod(_type, _period),
                            color: color,
                          ),
                          const SizedBox(height: 16),
                          BarChartWidget(data: chartData, color: color),
                        ],
                      ),
                    ),

                    // ✅ Line Chart
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryCard(
                            title: 'اتجاه ${isExpense ? "المصروفات" : "الإيرادات"}',
                            value: provider.getTotalByPeriod(_type, _period),
                            color: color,
                          ),
                          const SizedBox(height: 16),
                          LineChartWidget(data: chartData, color: color),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Color color) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // ✅ تصفية بالفترة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periods.entries.map((entry) {
                final isSelected = _period == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _period = entry.key),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ✅ تصفية بالنوع + تجميع
          Row(
            children: [
              Expanded(
                child: ToggleButtons(
                  isSelected: [_type == 'expense', _type == 'income'],
                  onPressed: (index) {
                    setState(() => _type = index == 0 ? 'expense' : 'income');
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: color,
                  constraints: const BoxConstraints(minHeight: 36),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('مصروفات'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('إيرادات'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ✅ خيار تجميع الفئات الفرعية
              Tooltip(
                message: _showMainCategoriesOnly
                    ? 'عرض الفئات الفرعية'
                    : 'تجميع الفئات الفرعية',
                child: IconButton(
                  onPressed: () => setState(
                      () => _showMainCategoriesOnly = !_showMainCategoriesOnly),
                  icon: Icon(
                    _showMainCategoriesOnly
                        ? Icons.compress
                        : Icons.expand,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}