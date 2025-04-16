import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/widgets/theme_card.dart';

class BarChartComponent extends StatelessWidget {
  final List<BarData> data;
  final String title;
  final String subtitle;
  final String totalLabel;
  final bool showCountryFlags;
  final Color barColor;
  final bool showValues;
  final double? maxY;

  const BarChartComponent({
    super.key,
    required this.data,
    required this.title,
    this.subtitle = '',
    this.totalLabel = '',
    this.showCountryFlags = false,
    this.barColor = Colors.blue,
    this.showValues = true,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate maxY if not provided
    final calculatedMaxY = maxY ??
        (data.isNotEmpty
            ? (data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.2)
            : 10.0);

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
          const SizedBox(height: 8),

          // Bar Chart
          Expanded(
            child: ThemeCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: calculatedMaxY,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
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
                            if (value.toInt() >= 0 &&
                                value.toInt() < data.length) {
                              final item = data[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    if (showCountryFlags &&
                                        item.countryCode != null)
                                      CountryFlag.fromCountryCode(
                                        item.countryCode!,
                                        width: 16,
                                        height: 11,
                                        shape: const RoundedRectangle(6),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          reservedSize: 60,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    barGroups: _generateBarGroups(colorScheme),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(ColorScheme colorScheme) {
    return List.generate(
      data.length,
      (index) {
        final item = data[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.value.toDouble(),
              color: barColor,
              width: 16,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY ??
                    (data.isNotEmpty
                        ? (data
                                .map((d) => d.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2)
                        : 10.0),
                color: barColor.withOpacity(0.1),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BarData {
  final String label;
  final int value;
  final String? countryCode;
  final DateTime? date;

  BarData({
    required this.label,
    required this.value,
    this.countryCode,
    this.date,
  });
}
