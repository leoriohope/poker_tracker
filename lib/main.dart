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
