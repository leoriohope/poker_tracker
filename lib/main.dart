import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/home_screen.dart';

// 应用入口函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  if (kIsWeb) {
    // Web平台
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 桌面平台
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS 平台不需要特殊初始化

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
