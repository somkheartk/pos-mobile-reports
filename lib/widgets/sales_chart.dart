import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sales_report.dart';

class SalesChart extends StatelessWidget {
  final List<SalesReport> reports;

  const SalesChart({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(child: Text('ไม่มีข้อมูล'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Text('0');
                if (value >= 1000) {
                  return Text('${(value / 1000).toStringAsFixed(0)}k');
                }
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < reports.length) {
                  final date = reports[index].date;
                  return Text(
                    '${date.day}/',
                    style: TextStyle(fontSize: 10),
                  );
                }
                return Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: reports.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalRevenue);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
        minX: 0,
        maxX: reports.length.toDouble() - 1,
        minY: 0,
        maxY: reports.isNotEmpty ? 
          reports.map((r) => r.totalRevenue).reduce((a, b) => a > b ? a : b) * 1.1 : 
          1000,
      ),
    );
  }
}
