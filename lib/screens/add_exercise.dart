import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../constants/app_constants.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> _addExerciseToDatabase() async {
    final instance = JournalDatabase.instance;
    final exerciseService = ExerciseService(instance);

    final exercise = Exercise(
      name: nameController.text,
      date: DateTime.now(),
      weight: 0.0,
      reps: 0,
      oneRM: 0.0,
      notes: notesController.text,
    );

    await exerciseService.createExercise(exercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),

            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: AppSizing.padding2),
            ElevatedButton(
              onPressed: _addExerciseToDatabase,
              child: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
