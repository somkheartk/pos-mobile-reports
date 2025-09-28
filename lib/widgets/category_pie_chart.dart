import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> salesByCategory;

  const CategoryPieChart({Key? key, required this.salesByCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (salesByCategory.isEmpty) {
      return Center(child: Text('ไม่มีข้อมูล'));
    }

    final total = salesByCategory.values.reduce((a, b) => a + b);
    final sections = salesByCategory.entries.map((entry) {
      final index = salesByCategory.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / total * 100);
      
      return PieChartSectionData(
        color: Colors.primaries[index % Colors.primaries.length],
        value: entry.value,
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
      ),
    );
  }
}
