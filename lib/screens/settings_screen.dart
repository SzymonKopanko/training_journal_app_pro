import 'package:flutter/material.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../services/body_part_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Add Starter Exercises'),
            onTap: () {
              _addStarterExercises(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            onTap: () {
              _changeLanguage(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Change Measurement System'),
            onTap: () {
              _changeMeasurementSystem(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Change Colors'),
            onTap: () {
              _changeColors(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete All Data'),
            onTap: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addStarterExercises(BuildContext context) async {
    await BodyPartService(JournalDatabase.instance).createStarterExercisesAndBodyPartsWithRelationsWithSomeEdits();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Starter Exercises'),
          content: const Text('Starter exercises have been added.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja do wyświetlenia okna dialogowego z potwierdzeniem usunięcia wszystkich danych
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text('This action will delete all entries and exercises. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij okno dialogowe bez akcji
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllData(context); // Usunięcie danych
                Navigator.of(context).pop(); // Zamknięcie okna dialogowego
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja do usunięcia wszystkich danych
  void _deleteAllData(BuildContext context) async {
    final database = JournalDatabase.instance;
    await database.deleteDB();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All data has been deleted.'),
    ));
  }

  void _changeLanguage(BuildContext context) {
    // Tu otwórz ekran do zmiany języka
  }

  void _changeMeasurementSystem(BuildContext context) {
    // Tu otwórz ekran do zmiany systemu miar
  }

  void _changeColors(BuildContext context) {
    // Tu otwórz ekran do zmiany kolorów aplikacji
  }
}
