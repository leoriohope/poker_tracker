import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import '../screens/edit_session_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;
  final DatabaseService _databaseService = DatabaseService();

  SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final profit = session.cashOut - session.buyIn;
    final profitColor = profit >= 0 ? Colors.green : Colors.red;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(session.location),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSessionScreen(
                    session: session,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true); // 返回上一页并刷新列表
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认删除'),
                  content: const Text('确定要删除这条记录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await _databaseService.deleteSession(session.id!);
                  if (context.mounted) {
                    Navigator.pop(context, true); // 返回true表示数据已更改
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('删除失败: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('盈亏'),
                    trailing: Text(
                      '${profit >= 0 ? '+' : ''}$profit',
                      style: TextStyle(
                        color: profitColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildDetailRow('日期', dateFormat.format(session.date)),
                  _buildDetailRow('地点', session.location),
                  _buildDetailRow('买入', '${session.buyIn}'),
                  _buildDetailRow('结束', '${session.cashOut}'),
                  _buildDetailRow('时长', '${session.duration} 分钟'),
                  if (session.notes?.isNotEmpty ?? false)
                    _buildDetailRow('备注', session.notes!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
} 