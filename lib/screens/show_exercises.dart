import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/entry_service.dart';
//import 'package:training_journal_app/screens/chart_screen.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/exercise_service.dart';

import '../services/set_service.dart';
import 'add_exercise.dart';
import 'add_specified_entry.dart';
import 'edit_exercise.dart';
import 'show_specified_entries.dart';

class ShowExercises extends StatefulWidget {
  const ShowExercises({super.key});

  @override
  _ShowExercisesState createState() => _ShowExercisesState();
}

class _ShowExercisesState extends State<ShowExercises> {
  List<Exercise> exercises = [];
  List<Exercise> filteredExercises = [];
  TextEditingController searchBarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final instance = JournalDatabase.instance;
    final loadedExercises = await ExerciseService(instance).readAllExercises();
    if (loadedExercises != null) {
      setState(() {
        exercises = loadedExercises;
        filteredExercises = loadedExercises;
      });
    }
  }

  Future<void> _deleteExercise(BuildContext context, int index) async {
    final exerciseToDelete = filteredExercises[index];
    final exerciseDeletedName = exerciseToDelete.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise?'),
          content:  Text(
              'This action will delete all entries for this exercise($exerciseDeletedName) with it.'
                  ' Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final instance = JournalDatabase.instance;
                ExerciseService exerciseService = ExerciseService(instance);
                final exerciseToDelete = filteredExercises[index];
                await exerciseService.deleteExercise(exerciseToDelete.id!);
                await _loadExercises();
                _applyFilter();
                Navigator.of(context).pop();
              },
              child: const Text('Delete Exercise'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter() {
    if(exercises.isNotEmpty){
      setState(() {
        if (searchBarController.text.isNotEmpty) {
          filteredExercises = exercises
              .where((exercise) =>
              exercise.name.toLowerCase().contains(searchBarController.text.toLowerCase()))
              .toList();
        } else {
          filteredExercises = exercises;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Column(
        children: [
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: searchBarController,
                decoration: const InputDecoration(
                  labelText: 'Search Exercises',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  _applyFilter();
                },
              ),
            ),
          if (exercises.isNotEmpty)
            Expanded(
              child: filteredExercises.isEmpty
                  ? const Center(
                child: Text('No matching exercises found.'),
              )
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'One Rep Max: ${exercise.oneRM.toStringAsFixed(2)} kg (${exercise.weight.toStringAsFixed(2)} kg'
                                  ' x ${exercise.reps} reps)',
                            ),
                            Text(
                              'Date and time: ${DateFormat('dd.MM.yyyy, HH:mm').format(exercise.date)}',
                            ),
                            if(exercise.notes.isNotEmpty)
                              Text('Notes: ${exercise.notes}'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                         AddSpecifiedEntryScreen(chosenExercise: exercise),
                                      ),
                                    ).then((_) {
                                      _loadExercises();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MediaQuery.platformBrightnessOf(super.context) == Brightness.light ? const Color.fromARGB(
                                        255, 228, 245, 224)
                                        : const Color.fromARGB(
                                        255, 27, 44, 23),
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Add Entry'),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShowSpecifiedEntries(chosenExercise: exercise),
                                      ),
                                    ).then((_) {
                                      _loadExercises();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MediaQuery.platformBrightnessOf(super.context) == Brightness.light ? const Color.fromARGB(
                                        255, 228, 245, 224)
                                        : const Color.fromARGB(
                                        255, 27, 44, 23),
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Show History'),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _deleteExercise(context, index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    MediaQuery.platformBrightnessOf(super.context) !=
                                        Brightness.light
                                        ? const Color.fromARGB(
                                        100, 70, 40, 46)
                                        : const Color.fromARGB(
                                        255, 252, 234, 234),
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: Text('Delete',
                                    style: TextStyle(
                                      color: MediaQuery.platformBrightnessOf(super.context) != Brightness.light
                                          ? const Color.fromARGB(255, 255, 146, 146)
                                          : const Color.fromARGB(255, 183, 0, 0),
                                    ),),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditExerciseScreen(
                                          chosenExercise: exercise,
                                        ),
                                      ),
                                    ).then((_) {
                                      _loadExercises();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MediaQuery.platformBrightnessOf(super.context) == Brightness.light ? const Color.fromARGB(
                                        255, 228, 245, 224)
                                        : const Color.fromARGB(
                                        255, 27, 44, 23),
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (exercises.isEmpty)
            const Expanded(
              child:  Center(
                child: Text('No exercises found, add some.'),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
              );
              await _loadExercises();
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 50),
            ),
            child: const Text(
              'Add Exercise',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }


}
