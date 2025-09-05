import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PriceChartWidget extends StatefulWidget {
  final Map<String, dynamic> instrumentData;

  const PriceChartWidget({
    Key? key,
    required this.instrumentData,
  }) : super(key: key);

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  String selectedPeriod = '1D';
  final List<String> timePeriods = ['1D', '1W', '1M', '3M', '1Y'];

  // Mock chart data based on selected period
  List<FlSpot> getChartData() {
    switch (selectedPeriod) {
      case '1D':
        return [
          FlSpot(0, 450.0),
          FlSpot(1, 452.5),
          FlSpot(2, 448.0),
          FlSpot(3, 455.0),
          FlSpot(4, 460.2),
          FlSpot(5, 458.5),
          FlSpot(6, 462.0),
        ];
      case '1W':
        return [
          FlSpot(0, 440.0),
          FlSpot(1, 445.0),
          FlSpot(2, 450.0),
          FlSpot(3, 455.0),
          FlSpot(4, 460.2),
          FlSpot(5, 465.0),
          FlSpot(6, 462.0),
        ];
      case '1M':
        return [
          FlSpot(0, 420.0),
          FlSpot(1, 430.0),
          FlSpot(2, 440.0),
          FlSpot(3, 450.0),
          FlSpot(4, 460.2),
          FlSpot(5, 455.0),
          FlSpot(6, 462.0),
        ];
      case '3M':
        return [
          FlSpot(0, 380.0),
          FlSpot(1, 400.0),
          FlSpot(2, 420.0),
          FlSpot(3, 440.0),
          FlSpot(4, 460.2),
          FlSpot(5, 450.0),
          FlSpot(6, 462.0),
        ];
      case '1Y':
        return [
          FlSpot(0, 300.0),
          FlSpot(1, 350.0),
          FlSpot(2, 380.0),
          FlSpot(3, 420.0),
          FlSpot(4, 460.2),
          FlSpot(5, 440.0),
          FlSpot(6, 462.0),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = getChartData();
    final currentPrice = widget.instrumentData['currentPrice'] as double;
    final dayChange = widget.instrumentData['dayChange'] as double;
    final isPositive = dayChange >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector
          Container(
            height: 6.h,
            child: Row(
              children: timePeriods.map((period) {
                final isSelected = period == selectedPeriod;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPeriod = period;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          period,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 3.h),

          // Chart container
          Container(
            height: 35.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            padding: EdgeInsets.all(3.w),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = Text('9:30', style: style);
                            break;
                          case 1:
                            text = Text('10:30', style: style);
                            break;
                          case 2:
                            text = Text('11:30', style: style);
                            break;
                          case 3:
                            text = Text('12:30', style: style);
                            break;
                          case 4:
                            text = Text('1:30', style: style);
                            break;
                          case 5:
                            text = Text('2:30', style: style);
                            break;
                          case 6:
                            text = Text('3:30', style: style);
                            break;
                          default:
                            text = Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '৳${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: 6,
                minY: chartData
                        .map((spot) => spot.y)
                        .reduce((a, b) => a < b ? a : b) -
                    10,
                maxY: chartData
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b) +
                    10,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        isPositive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        isPositive
                            ? AppTheme.successColor.withValues(alpha: 0.3)
                            : AppTheme.errorColor.withValues(alpha: 0.3),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          isPositive
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1),
                          isPositive
                              ? AppTheme.successColor.withValues(alpha: 0.05)
                              : AppTheme.errorColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          '৳${barSpot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Volume indicator
          Container(
            height: 8.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Volume',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      '2.5M',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Avg: 1.8M',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
