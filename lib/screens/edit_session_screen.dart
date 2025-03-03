import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditSessionScreen extends StatefulWidget {
  final Session? session;

  const EditSessionScreen({super.key, this.session});

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
    _locationController.text = widget.session?.location ?? '';
    _buyInController.text = widget.session?.buyIn.toString() ?? '';
    _cashOutController.text = widget.session?.cashOut.toString() ?? '';
    _durationController.text = widget.session?.duration.toString() ?? '';
    _notesController.text = widget.session?.notes ?? '';
    // 初始化日期和时间
    _selectedDate = widget.session?.date ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.session?.date ?? DateTime.now());
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSession),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(l10n.date),
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
              decoration: InputDecoration(labelText: l10n.location),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterLocation;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _buyInController,
              decoration: InputDecoration(labelText: l10n.buyIn),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterValidNumber;
                }
                if (double.tryParse(value) == null) {
                  return l10n.enterValidNumber;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _cashOutController,
              decoration: InputDecoration(labelText: l10n.cashOut),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterValidNumber;
                }
                if (double.tryParse(value) == null) {
                  return l10n.enterValidNumber;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: '${l10n.duration} (${l10n.minutes})',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterDuration;
                }
                if (int.tryParse(value) == null) {
                  return l10n.enterValidInteger;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notes),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final session = Session(
                      id: widget.session?.id,
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

                    if (widget.session == null) {
                      // 新建记录
                      await _databaseService.insertSession(session);
                    } else {
                      // 更新记录
                      await _databaseService.updateSession(session);
                    }
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.updateSuccess)),
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.updateError}: $e')),
                      );
                    }
                  }
                }
              },
              child: Text(l10n.save),
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