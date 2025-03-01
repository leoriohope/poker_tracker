import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/database_service.dart';

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

        print('Saving session: ${session.toMap()}'); // 添加日志

        await _databaseService.insertSession(session);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('Error saving session: $e'); // 添加错误日志
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