import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/country_chart.dart';
import '../db/country_adapter.dart';

// Displays country visit statistics in a chart.
class ChartScreen extends StatelessWidget {
  final Box<CountryVisit> box;
  const ChartScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20), // Prevents tooltip overlap
      child: CountryChart(box: box),
    );
  }
}
