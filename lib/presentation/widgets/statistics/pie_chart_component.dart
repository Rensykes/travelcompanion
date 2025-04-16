import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/widgets/theme_card.dart';

class PieChartComponent extends StatefulWidget {
  final Map<String, int> data;
  final List<Color> colorsList;
  final String title;
  final String subtitle;
  final String totalLabel;
  final bool showCountryFlags;
  final Widget Function(
      BuildContext, int, MapEntry<String, int>, Color, double)? itemBuilder;

  const PieChartComponent({
    super.key,
    required this.data,
    required this.colorsList,
    required this.title,
    this.subtitle = '',
    this.totalLabel = '',
    this.showCountryFlags = false,
    this.itemBuilder,
  });

  @override
  State<PieChartComponent> createState() => _PieChartComponentState();
}

class _PieChartComponentState extends State<PieChartComponent> {
  int _touchedIndex = -1;
  late List<MapEntry<String, int>> sortedEntries;
  late int total;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(PieChartComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _processData();
    }
  }

  void _processData() {
    // Sort entries by value (descending)
    sortedEntries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate total
    total = sortedEntries.fold(0, (sum, entry) => sum + entry.value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
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
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.totalLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            widget.totalLabel,
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
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pie Chart
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: 300,
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
                  sectionsSpace: 1,
                  centerSpaceRadius: 20,
                  sections: _generatePieChartSections(),
                ),
              ),
            ),
          ),

          // Data List
          ThemeCard(
            elevation: 2,
            child: Container(
              height: 300,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: sortedEntries.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  final key = entry.key;
                  final value = entry.value;
                  final color =
                      widget.colorsList[index % widget.colorsList.length];
                  final percentage = (value / total) * 100;

                  if (widget.itemBuilder != null) {
                    return widget.itemBuilder!(
                        context, index, entry, color, percentage);
                  }

                  return ListTile(
                    dense: true,
                    horizontalTitleGap: 8,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (widget.showCountryFlags)
                          CountryFlag.fromCountryCode(
                            key,
                            width: 24,
                            height: 16,
                            shape: const RoundedRectangle(6),
                          ),
                      ],
                    ),
                    title: Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '$value (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    return List.generate(
      sortedEntries.length > 8 ? 8 : sortedEntries.length,
      (i) {
        final entry = sortedEntries[i];
        final isTouched = i == _touchedIndex;
        final fontSize = isTouched ? 14.0 : 12.0;
        final radius = isTouched ? 110.0 : 100.0;
        final badgeSize = isTouched ? 32.0 : 26.0;
        final percentage = (entry.value / total) * 100;
        final color = widget.colorsList[i % widget.colorsList.length];

        return PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
          ),
          badgeWidget: widget.showCountryFlags
              ? _CountryBadge(
                  countryCode: entry.key,
                  size: badgeSize,
                )
              : null,
          badgePositionPercentageOffset: .80,
        );
      },
    );
  }
}

class _CountryBadge extends StatelessWidget {
  final String countryCode;
  final double size;

  const _CountryBadge({
    required this.countryCode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .1),
      child: CountryFlag.fromCountryCode(
        countryCode,
        shape: const Circle(),
      ),
    );
  }
}
