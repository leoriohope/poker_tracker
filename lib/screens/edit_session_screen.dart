import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class EditSessionScreen extends StatefulWidget {
  final Session session;

  const EditSessionScreen({super.key, required this.session});

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _buyInController = TextEditingController();
  final _cashOutController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _databaseService = DatabaseService();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  @override
  void initState() {
    super.initState();
    // 初始化表单数据
    _locationController.text = widget.session.location;
    _buyInController.text = widget.session.buyIn.toString();
    _cashOutController.text = widget.session.cashOut.toString();
    _durationController.text = widget.session.duration.toString();
    _notesController.text = widget.session.notes ?? '';
    // 初始化日期和时间
    _selectedDate = widget.session.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.session.date);
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑记录'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('日期和时间'),
              subtitle: Text(
                DateFormat('yyyy-MM-dd HH:mm').format(DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                )),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
            const Divider(),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final updatedSession = Session(
                      id: widget.session.id,
                      date: DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      ),
                      location: _locationController.text,
                      buyIn: double.parse(_buyInController.text),
                      cashOut: double.parse(_cashOutController.text),
                      duration: int.parse(_durationController.text),
                      notes: _notesController.text,
                    );

                    await _databaseService.updateSession(updatedSession);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('更新成功')),
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('更新失败: $e')),
                      );
                    }
                  }
                }
              },
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