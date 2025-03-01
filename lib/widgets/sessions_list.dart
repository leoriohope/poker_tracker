import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionsList extends StatelessWidget {
  const SessionsList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 替换为实际的数据源
    final List<Session> sessions = [];

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionListTile(session: session);
      },
    );
  }
}

class SessionListTile extends StatelessWidget {
  final Session session;

  const SessionListTile({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${session.location} - ${session.date}'),
      subtitle: Text('Duration: ${session.duration} minutes'),
      trailing: Text(
        '${session.profit >= 0 ? '+' : ''}${session.profit.toStringAsFixed(2)}',
        style: TextStyle(
          color: session.profit >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // TODO: 导航到详情页面
      },
    );
  }
} 