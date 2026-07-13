import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:fl_chart/fl_chart.dart';

class ElevationChart extends StatelessWidget {
  final List<RoutePoint> points;
  final double height;

  const ElevationChart({
    super.key,
    required this.points,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    double distance = 0;

    spots.add(FlSpot(0, points.first.altitude ?? 0)); 

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final segment = Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
      distance += segment / 1000;
      spots.add(FlSpot(distance, curr.altitude ?? 0));
    }

    final altitudes = points.map((p) => p.altitude ?? 0).toList();
    final minAlt = altitudes.reduce((a, b) => a < b ? a : b);
    final maxAlt = altitudes.reduce((a, b) => a > b ? a : b);
    final altPadding = (maxAlt - minAlt) * 0.1;

    return Container(
      height: height,
      padding: const EdgeInsets.only(right: 8, top: 8, left: 4), 
      child: LineChart(
        LineChartData(
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()} м',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: spots.last.x / 5,
                getTitlesWidget: (value, _) => Text(
                  '${value.toStringAsFixed(1)} км',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          minY: minAlt - altPadding,
          maxY: maxAlt + altPadding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              dotData: const FlDotData(show: false),
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} м\n${spot.x.toStringAsFixed(2)} км',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}