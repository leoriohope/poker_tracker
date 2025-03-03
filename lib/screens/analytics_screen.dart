import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import './monthly_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        _sessions = sessions..sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.loadError}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sessions.isEmpty) {
      return Center(child: Text(l10n.noRecords));
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
        title: Text(l10n.analytics),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.totalSessions(_sessions.length),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.totalProfit}: ${totalProfit.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: totalProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.totalDuration((totalDuration / 60).toStringAsFixed(1)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.profitPerHour}: ${avgProfitPerHour.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(Map<String, double> monthlyStats) {
    final l10n = AppLocalizations.of(context)!;
    final sortedMonths = monthlyStats.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.monthlyStats, style: const TextStyle(fontSize: 18)),
                Text(
                  l10n.clickForDetails,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedMonths.map((month) {
              final profit = monthlyStats[month]!;
              final monthSessions = _sessions.where((session) {
                return DateFormat('yyyy-MM').format(session.date) == month;
              }).toList();

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyDetailScreen(
                        monthKey: month,
                        sessions: monthSessions,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        month,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            profit.toStringAsFixed(2),
                            style: TextStyle(
                              color: profit >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            profit >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: profit >= 0 ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChart() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noRecords),
        ),
      );
    }

    // 按日期分组并计算每日总盈亏
    final dailyProfits = <DateTime, double>{};
    for (var session in _sessions) {
      final day = DateTime(session.date.year, session.date.month, session.date.day);
      final profit = session.cashOut - session.buyIn;
      dailyProfits[day] = (dailyProfits[day] ?? 0) + profit;
    }

    final sortedDays = dailyProfits.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // 生成数据点
    final spots = sortedDays.map((day) {
      return FlSpot(
        day.millisecondsSinceEpoch.toDouble(),
        dailyProfits[day]!,
      );
    }).toList();

    // 计算Y轴范围
    final profits = dailyProfits.values.toList();
    final maxProfit = profits.reduce((max, value) => value > max ? value : max);
    final minProfit = profits.reduce((min, value) => value < min ? value : min);
    final profitRange = (maxProfit - minProfit).abs();
    final yMargin = profitRange * 0.1;

    // 确保网格间隔不为零
    final horizontalInterval = profitRange > 0 ? profitRange / 5 : 100.0;
    final leftTitlesInterval = profitRange > 0 ? profitRange / 4 : 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profitTrend,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
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
                          final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                          return LineTooltipItem(
                            '${DateFormat('yyyy-MM-dd').format(date)}\n',
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

  Widget _buildLocationStats(Map<String, double> locationStats) {
    final l10n = AppLocalizations.of(context)!;
    final sortedLocations = locationStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.locationStats,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...sortedLocations.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 16),
                    ),
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
            }).toList(),
          ],
        ),
      ),
    );
  }
} 