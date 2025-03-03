import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import '../screens/edit_session_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;
  final DatabaseService _databaseService = DatabaseService();

  SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  title: Text(l10n.confirmDelete),
                  content: Text(l10n.confirmDeleteMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete),
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
                      SnackBar(content: Text('${l10n.deleteError}: $e')),
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
                    title: Text(l10n.profit),
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
                  _buildDetailRow(l10n.date, dateFormat.format(session.date)),
                  _buildDetailRow(l10n.location, session.location),
                  _buildDetailRow(l10n.buyIn, '${session.buyIn}'),
                  _buildDetailRow(l10n.cashOut, '${session.cashOut}'),
                  _buildDetailRow(l10n.duration, '${session.duration} ${l10n.minutes}'),
                  if (session.notes?.isNotEmpty ?? false)
                    _buildDetailRow(l10n.notes, session.notes!),
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