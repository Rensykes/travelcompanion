import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../db/country_adapter.dart';

class CountryChart extends StatelessWidget {
  final Box<CountryVisit> box;

  const CountryChart({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    Map<String, int> countryData = {};

    for (var visit in box.values) {
      countryData.update(visit.countryCode, (value) => value + visit.daysSpent, ifAbsent: () => visit.daysSpent);
    }

    List<BarChartGroupData> barGroups = [];
    int index = 0;

    countryData.forEach((country, days) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(toY: days.toDouble(), color: Colors.blue, width: 16),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    });

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(countryData.keys.toList()[value.toInt()]),
                  );
                },
              ),
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
