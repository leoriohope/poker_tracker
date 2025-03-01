import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// 应用入口函数
void main() {
  runApp(const PokerTrackerApp());
}

// 应用根组件
class PokerTrackerApp extends StatelessWidget {
  const PokerTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Tracker',
      // 配置应用主题
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,  // 深色主题
        useMaterial3: true,  // 使用Material 3设计
      ),
      home: const HomeScreen(),  // 设置首页
    );
  }
}

// 首页界面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Scaffold提供基本的应用布局结构
      appBar: AppBar(
        title: const Text('Poker Tracker'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '欢迎使用Poker Tracker',
          style: TextStyle(fontSize: 20),
        ),
      ),
      // 添加浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 稍后实现添加新记录的功能
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
