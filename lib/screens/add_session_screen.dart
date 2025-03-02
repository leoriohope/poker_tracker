import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AddSessionScreen');

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _buyInController = TextEditingController();
  final _cashOutController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _databaseService = DatabaseService();

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      try {
        final session = Session(
          date: DateTime.now(),
          location: _locationController.text,
          buyIn: double.parse(_buyInController.text),
          cashOut: double.parse(_cashOutController.text),
          duration: int.parse(_durationController.text),
          notes: _notesController.text,
        );

        _logger.info('开始保存...');
        final result = await _databaseService.insertSession(session);
        _logger.info('保存完成，ID: $result');
        
        if (mounted) {
          // 显示保存成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存成功'),
              duration: Duration(seconds: 2),
            ),
          );
          // 确保 SnackBar 显示完整
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true);
        }
      } catch (e) {
        _logger.severe('保存错误: $e'); // 调试日志
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新记录'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '地点'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入地点';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _buyInController,
              decoration: const InputDecoration(labelText: '买入金额'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入买入金额';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的数字';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _cashOutController,
              decoration: const InputDecoration(labelText: '结束金额'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入结束金额';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的数字';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: '时长（分钟）'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入时长';
                }
                if (int.tryParse(value) == null) {
                  return '请输入有效的整数';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: '备注'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSession,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _buyInController.dispose();
    _cashOutController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 