import 'package:flutter/material.dart';
import 'package:training_journal_app/models/body_entry.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/constants/app_constants.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../l10n/app_localizations.dart';

class EditBodyEntryScreen extends StatefulWidget {
  final BodyEntry bodyEntry;

  const EditBodyEntryScreen({Key? key, required this.bodyEntry}) : super(key: key);

  @override
  _EditBodyEntryScreenState createState() => _EditBodyEntryScreenState();
}

class _EditBodyEntryScreenState extends State<EditBodyEntryScreen> {
  final TextEditingController _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final BodyEntryService _bodyEntryService = BodyEntryService(JournalDatabase.instance);

  @override
  void initState() {
    super.initState();
    _loadBodyEntryData();
  }

  // Load existing body entry data to edit
  void _loadBodyEntryData() {
    _weightController.text = widget.bodyEntry.weight.toString();
    _selectedDate = widget.bodyEntry.dateTime;
  }

  // Save the updated body entry to the database
  Future<void> _saveBodyEntry() async {
    final double weight = double.tryParse(_weightController.text) ?? 0.0;

    if (weight > 0) {
      final updatedBodyEntry = BodyEntry(
        id: widget.bodyEntry.id,
        weight: weight,
        dateTime: _selectedDate,
      );

      await _bodyEntryService.updateBodyEntry(updatedBodyEntry);

      Navigator.pop(context); // Go back to the previous screen after saving
    } else {
      final l10n = AppLocalizations.of(context);
      _showErrorDialog(l10n.invalidInputTitle, l10n.provideValidWeight);
    }
  }

  // Show error dialog
  void _showErrorDialog(String title, String content) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.commonOk),
            ),
          ],
        );
      },
    );
  }

  // Show date picker to select a new date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  // Show time picker to select a new time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bodyEntryEditTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.mainWeightKgLabel),
            ),
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text(l10n.dateLabel),
                const SizedBox(width: AppSizing.padding1),
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: AppSizing.fontSize2),
                ),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(l10n.selectDate),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text(l10n.timeLabel),
                const SizedBox(width: AppSizing.padding1),
                Text(
                  "${_selectedDate.toLocal().hour.toString().padLeft(2, '0')}:${_selectedDate.toLocal().minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: AppSizing.fontSize2),
                ),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text(l10n.selectTime),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            ElevatedButton(
              onPressed: _saveBodyEntry,
              child: Text(l10n.bodyEntrySave),
            ),
          ],
        ),
      ),
    );
  }
}
