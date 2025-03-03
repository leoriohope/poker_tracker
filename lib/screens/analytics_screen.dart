import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _databaseService.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sessions.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final totalProfit = _sessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.cashOut - session.buyIn),
    );

    final totalDuration = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    final avgProfitPerHour = totalDuration > 0
        ? (totalProfit / totalDuration * 60).toDouble()
        : 0.0;

    // 按场地分组统计
    final locationStats = <String, double>{};
    for (var session in _sessions) {
      final profit = session.cashOut - session.buyIn;
      locationStats[session.location] = 
          (locationStats[session.location] ?? 0) + profit;
    }

    // 按月份分组统计
    final monthlyStats = <String, double>{};
    for (var session in _sessions) {
      final monthKey = DateFormat('yyyy-MM').format(session.date);
      final profit = session.cashOut - session.buyIn;
      monthlyStats[monthKey] = (monthlyStats[monthKey] ?? 0.0) + profit;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(totalProfit.toDouble(), totalDuration, avgProfitPerHour),
          const SizedBox(height: 16),
          _buildMonthlyStats(monthlyStats),
          const SizedBox(height: 16),
          _buildProfitChart(),
          const SizedBox(height: 16),
          _buildLocationStats(locationStats),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalProfit,
    int totalDuration,
    double avgProfitPerHour,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '总场次: ${_sessions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '总盈亏: ${totalProfit.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: totalProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '总时长: ${(totalDuration / 60).toStringAsFixed(1)}小时',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '每小时盈亏: ${avgProfitPerHour.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(Map<String, double> monthlyStats) {
    final sortedMonths = monthlyStats.keys.toList()
      ..sort((a, b) => b.compareTo(a));  // 按月份降序排序

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('月度统计', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ...sortedMonths.map((month) {
              final profit = monthlyStats[month]!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(month),
                    Row(
                      children: [
                        Text(
                          profit.toStringAsFixed(2),
                          style: TextStyle(
                            color: profit >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profit >= 0)
                          const Icon(Icons.trending_up, color: Colors.green, size: 16)
                        else
                          const Icon(Icons.trending_down, color: Colors.red, size: 16),
                      ],
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

  Widget _buildProfitChart() {
    if (_sessions.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('需要至少两条记录来显示趋势图'),
        ),
      );
    }

    // 按日期排序
    final sortedSessions = List<Session>.from(_sessions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedSessions.map((session) {
      final profit = session.cashOut - session.buyIn;
      // 使用 DateTime.millisecondsSinceEpoch 作为 x 轴的值
      return FlSpot(
        session.date.millisecondsSinceEpoch.toDouble(),
        profit,
      );
    }).toList();

    // 计算最大和最小盈亏，用于设置Y轴范围
    final profits = sortedSessions.map((s) => s.cashOut - s.buyIn).toList();
    final maxProfit = profits.reduce((max, value) => value > max ? value : max);
    final minProfit = profits.reduce((min, value) => value < min ? value : min);
    final profitRange = (maxProfit - minProfit).abs();
    final yMargin = profitRange * 0.1; // 上下留10%的边距

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('盈亏趋势', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // 增加图表高度
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: profitRange / 5, // 横向网格线间隔
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
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
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
                        interval: 86400000 * 7, // 每7天显示一个标签
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MM-dd').format(date),
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
                  minX: spots.first.x,
                  maxX: spots.last.x,
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
                          final profit = spot.y;
                          return FlDotCirclePainter(
                            radius: 6,
                            color: profit >= 0 ? Colors.green : Colors.red,
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
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            touchedSpot.x.toInt(),
                          );
                          return LineTooltipItem(
                            '${DateFormat('yyyy-MM-dd').format(date)}\n',
                            const TextStyle(color: Colors.white, fontSize: 12),
                            children: [
                              TextSpan(
                                text: touchedSpot.y.toStringAsFixed(2),
                                style: TextStyle(
                                  color: touchedSpot.y >= 0 ? Colors.green[200] : Colors.red[200],
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

  Widget _buildLocationStats(Map<String, double> locationStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('场地统计', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ...locationStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      entry.value.toStringAsFixed(2),
                      style: TextStyle(
                        color: entry.value >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 