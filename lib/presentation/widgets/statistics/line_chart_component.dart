import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:trackie/presentation/widgets/theme_card.dart';

class LineChartComponent extends StatelessWidget {
  final List<MonthlyActivityData> data;
  final String title;
  final String subtitle;
  final String totalLabel;
  final Color lineColor;
  final double? maxY;
  final bool showArea;
  final bool showDots;

  const LineChartComponent({
    super.key,
    required this.data,
    required this.title,
    this.subtitle = '',
    this.totalLabel = '',
    this.lineColor = Colors.blue,
    this.maxY,
    this.showArea = true,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate maxY if not provided
    final calculatedMaxY = maxY ??
        (data.isNotEmpty
            ? (data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.2)
            : 5.0);

    // Convert data to chart points
    final spots = <FlSpot>[];
    final labels = <String>[];
    final dateFormat = DateFormat('MMM yy');

    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].value.toDouble()));
      labels.add(dateFormat.format(data[i].date));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Card
          ThemeCard(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (totalLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            totalLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Line Chart
          Expanded(
            child: ThemeCard(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 32, 8, 12),
                child: LineChart(
                  _generateLineChartData(
                      colorScheme, spots, labels, calculatedMaxY),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _generateLineChartData(ColorScheme colorScheme,
      List<FlSpot> spots, List<String> labels, double yMax) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: colorScheme.onSurface.withOpacity(0.1),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: colorScheme.onSurface.withOpacity(0.1),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                // Only show every other month to avoid crowding
                if (value.toInt() % 2 == 0) {
                  return Text(
                    labels[value.toInt()],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  );
                }
              }
              return const SizedBox();
            },
            reservedSize: 24,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
          left: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      minX: 0,
      maxX: spots.length - 1.0,
      minY: 0,
      maxY: yMax,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: showArea
              ? BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      lineColor.withOpacity(0.4),
                      lineColor.withOpacity(0.1),
                    ],
                  ),
                )
              : null,
          dotData: FlDotData(
            show: showDots,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final date = data[spot.x.toInt()].date;
              final formattedDate = DateFormat('MMMM yyyy').format(date);

              return LineTooltipItem(
                '${spot.y.toInt()} entries\n$formattedDate',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

class MonthlyActivityData {
  final DateTime date;
  final int value;
  final String? label;

  MonthlyActivityData({
    required this.date,
    required this.value,
    this.label,
  });
}
