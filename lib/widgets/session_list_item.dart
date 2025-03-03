import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';

class SessionListItem extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final profit = session.cashOut - session.buyIn;
    final profitColor = profit >= 0 ? Colors.green : Colors.red;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(session.location),
        subtitle: Text(
          '${dateFormat.format(session.date)} (${session.duration}分钟)',
        ),
        trailing: Text(
          '${profit >= 0 ? '+' : ''}$profit',
          style: TextStyle(
            color: profitColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
} 