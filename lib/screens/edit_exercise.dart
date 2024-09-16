import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../constants/app_constants.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise chosenExercise;

  const EditExerciseScreen({super.key, required this.chosenExercise});

  @override
  _EditExerciseScreenState createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData(){
    nameController.text = widget.chosenExercise.name;
    notesController.text = widget.chosenExercise.notes;
  }

  Future<void> _updateExerciseToDatabase() async {
    final instance = JournalDatabase.instance;
    final exerciseService = ExerciseService(instance);

    final exercise = Exercise(
      id: widget.chosenExercise.id,
      name: nameController.text,
      date: widget.chosenExercise.date,
      weight: widget.chosenExercise.weight,
      reps: widget.chosenExercise.reps,
      oneRM: widget.chosenExercise.oneRM,
      notes: notesController.text,
    );

    await exerciseService.updateExercise(exercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit \'${widget.chosenExercise.name}\' Exercise'),
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
              onPressed: _updateExerciseToDatabase,
              child: const Text('Edit Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
