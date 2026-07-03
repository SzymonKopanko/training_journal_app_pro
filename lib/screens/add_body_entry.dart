import 'package:flutter/material.dart';
import 'package:training_journal_app/models/body_entry.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/constants/app_constants.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../l10n/app_localizations.dart';

class AddBodyEntryScreen extends StatefulWidget {
  const AddBodyEntryScreen({super.key});

  @override
  _AddBodyEntryScreenState createState() => _AddBodyEntryScreenState();
}

class _AddBodyEntryScreenState extends State<AddBodyEntryScreen> {
  final TextEditingController _mainWeightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final BodyEntryService _bodyEntryService = BodyEntryService(JournalDatabase.instance);

  // This function handles the logic of saving the new body entry to the database
  Future<void> _saveBodyEntry() async {
    final double weight = double.tryParse(_mainWeightController.text) ?? 0.0;

    if (weight > 0) {
      final newBodyEntry = BodyEntry(
        weight: weight,
        dateTime: _selectedDate,
      );

      await _bodyEntryService.createBodyEntry(newBodyEntry);

      Navigator.pop(context); // Go back to the previous screen after saving
    } else {
      final l10n = AppLocalizations.of(context);
      _showErrorDialog(l10n.invalidInputTitle, l10n.provideValidWeight);
    }
  }

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

  // This function is used to select a date for the body entry
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  // This function is used to select a time for the body entry
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
        title: Text(l10n.bodyEntriesAdd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _mainWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.weightKgLabel),
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
                  "${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}",
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
              child: Text(l10n.bodyEntriesAdd),
            ),
          ],
        ),
      ),
    );
  }
}
