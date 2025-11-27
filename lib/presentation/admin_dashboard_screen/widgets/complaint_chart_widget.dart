import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';


class ComplaintChartWidget extends StatelessWidget {
  const ComplaintChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complaint Volume Trends',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Last 7 Days',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: Semantics(
                label: "Weekly complaint volume bar chart showing daily complaint counts",
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 50,
                    barTouchData: BarTouchData(
                      enabled: true,
                      // touchTooltipData: BarTouchTooltipData(
                      //   tooltipBgColor: theme.colorScheme.inverseSurface,
                      //   tooltipRoundedRadius: 8,
                      //   getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      touchTooltipData: BarTouchTooltipData(
                         tooltipBgColor: theme.colorScheme.inverseSurface,
                         tooltipRoundedRadius: 8,

                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            '${rod.toY.round()} complaints',
                            TextStyle(
                              color: theme.colorScheme.onInverseSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                         sideTitles: SideTitles(showTitles: false),
),
topTitles: AxisTitles(
  sideTitles: SideTitles(showTitles: false),
),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles( 
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: theme.textTheme.labelSmall,
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: theme.textTheme.labelSmall,
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    barGroups: _generateBarGroups(theme),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            _buildLegend(theme),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(ThemeData theme) {
    final complaintData = [
      {'total': 35, 'road': 15, 'water': 10, 'electricity': 10},
      {'total': 42, 'road': 18, 'water': 12, 'electricity': 12},
      {'total': 28, 'road': 12, 'water': 8, 'electricity': 8},
      {'total': 38, 'road': 16, 'water': 11, 'electricity': 11},
      {'total': 45, 'road': 20, 'water': 13, 'electricity': 12},
      {'total': 32, 'road': 14, 'water': 9, 'electricity': 9},
      {'total': 29, 'road': 13, 'water': 8, 'electricity': 8},
    ];

    return complaintData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (data['total'] as int).toDouble(),
            color: theme.colorScheme.primary,
            width: 6.w,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                (data['road'] as int).toDouble(),
                theme.colorScheme.primary,
              ),
              BarChartRodStackItem(
                (data['road'] as int).toDouble(),
                ((data['road'] as int) + (data['water'] as int)).toDouble(),
                theme.colorScheme.tertiary,
              ),
              BarChartRodStackItem(
                ((data['road'] as int) + (data['water'] as int)).toDouble(),
                (data['total'] as int).toDouble(),
                theme.colorScheme.error,
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Road Issues', theme.colorScheme.primary, theme),
        _buildLegendItem('Water Supply', theme.colorScheme.tertiary, theme),
        _buildLegendItem('Electricity', theme.colorScheme.error, theme),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}