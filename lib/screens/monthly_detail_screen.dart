import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';

class MonthlyDetailScreen extends StatelessWidget {
  final String monthKey;  // 格式: "yyyy-MM"
  final List<Session> sessions;

  const MonthlyDetailScreen({
    super.key,
    required this.monthKey,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('$monthKey 详细统计')),
        body: const Center(child: Text('暂无数据')),
      );
    }

    final totalProfit = sessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.cashOut - session.buyIn),
    );

    final totalDuration = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    final avgProfitPerHour = totalDuration > 0
        ? (totalProfit / totalDuration * 60).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('$monthKey 详细统计')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMonthSummary(totalProfit, totalDuration, avgProfitPerHour),
          const SizedBox(height: 16),
          _buildDailyTrendChart(),
          const SizedBox(height: 16),
          _buildSessionList(),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(double totalProfit, int totalDuration, double avgProfitPerHour) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('月度总结', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSummaryRow('总场次', sessions.length.toString()),
            _buildSummaryRow(
              '总盈亏',
              totalProfit.toStringAsFixed(2),
              valueColor: totalProfit >= 0 ? Colors.green : Colors.red,
            ),
            _buildSummaryRow('总时长', '${(totalDuration / 60).toStringAsFixed(1)}小时'),
            _buildSummaryRow(
              '每小时盈亏',
              avgProfitPerHour.toStringAsFixed(2),
              valueColor: avgProfitPerHour >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTrendChart() {
    if (sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无数据'),
        ),
      );
    }

    // 按日期分组并计算每日总盈亏
    final dailyProfits = <int, double>{};
    for (var session in sessions) {
      final dayOfMonth = session.date.day;
      final profit = session.cashOut - session.buyIn;
      dailyProfits[dayOfMonth] = (dailyProfits[dayOfMonth] ?? 0) + profit;
    }

    // 按日期排序
    final sortedDays = dailyProfits.keys.toList()..sort();

    // 生成数据点
    final spots = sortedDays.map((day) {
      return FlSpot(day.toDouble(), dailyProfits[day]!);
    }).toList();

    // 计算Y轴范围
    final profits = dailyProfits.values.toList();
    final maxProfit = profits.reduce((max, value) => value > max ? value : max);
    final minProfit = profits.reduce((min, value) => value < min ? value : min);
    final profitRange = (maxProfit - minProfit).abs();
    final yMargin = profitRange * 0.1;
    
    // 确保网格间隔不会为0
    final horizontalInterval = profitRange > 0 ? profitRange / 5 : 1.0;
    final leftTitlesInterval = profitRange > 0 ? profitRange / 4 : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('日盈亏趋势', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: horizontalInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        interval: leftTitlesInterval,
                        getTitlesWidget: (value, meta) {
                          String text = value >= 1000 || value <= -1000
                              ? '${(value / 1000).toStringAsFixed(1)}k'
                              : value.toStringAsFixed(0);
                          return Text(
                            text,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5, // 每5天显示一个标签
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}日',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 1, // 从1号开始
                  maxX: 31, // 到31号结束
                  minY: minProfit - yMargin,
                  maxY: maxProfit + yMargin,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: spot.y >= 0 ? Colors.green : Colors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.x.toInt()}日\n',
                            const TextStyle(color: Colors.white, fontSize: 12),
                            children: [
                              TextSpan(
                                text: spot.y.toStringAsFixed(2),
                                style: TextStyle(
                                  color: spot.y >= 0 ? Colors.green[200] : Colors.red[200],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));  // 按日期降序排序

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('详细记录', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(flex: 2, child: Text('日期')),
                Expanded(flex: 3, child: Text('场地')),
                Expanded(flex: 2, child: Text('盈亏')),
                Expanded(flex: 2, child: Text('时长')),
              ],
            ),
            const Divider(),
            ...sortedSessions.map((session) {
              final profit = session.cashOut - session.buyIn;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(DateFormat('dd日').format(session.date)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(session.location),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        profit.toStringAsFixed(2),
                        style: TextStyle(
                          color: profit >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${session.duration}分钟'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}