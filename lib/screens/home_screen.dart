import 'package:flutter/material.dart';
import '../widgets/sessions_list.dart';
import './add_session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poker Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // TODO: 导航到统计页面
            },
          ),
        ],
      ),
      body: const SessionsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSessionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 