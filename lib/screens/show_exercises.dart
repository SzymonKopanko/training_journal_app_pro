import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
//import 'package:training_journal_app/screens/chart_screen.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/exercise_service.dart';

import 'add_entry.dart';

class ShowExercises extends StatefulWidget {
  const ShowExercises({Key? key}) : super(key: key);

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

  void _deleteExercise(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise?'),
          content: const Text(
              'This action will delete all entries for this exercise with it.'
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
                final exerciseToDelete = exercises[index];
                await exerciseService.deleteExercise(exerciseToDelete.id!);
                setState(() {
                  exercises.removeAt(index);
                  _applyFilter(); // Aktualizacja listy po usunięciu ćwiczenia
                });
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
                  _applyFilter(); // Aktualizacja listy po zmianie tekstu w wyszukiwarce
                },
              ),
            ),
          if (exercises.isNotEmpty) // Dodane warunkowe wyświetlanie listy ćwiczeń
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
                              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(exercise.date)}',
                            ),
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
                                        const AddEntryScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Add Entry'),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    // Obsługa nawigacji do ekranu wykresu
                                    // if (index >= 0 && index < exercises!.length) {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) => ExerciseChartScreen(
                                    //         exercise: exercises![index],
                                    //       ),
                                    //     ),
                                    //   );
                                    // }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Show Chart'),
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
                                    backgroundColor: Colors.red,
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Delete Exercise'),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    _deleteExercise(context, index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size(140, 25),
                                  ),
                                  child: const Text('Edit Exercise'),
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
          if (exercises.isEmpty) // Dodane warunkowe wyświetlanie komunikatu
            const Center(
              child: Text('No exercises found, add some.'),
            ),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AddExerciseScreen()),
              // );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 50),
            ),
            child: const Text(
              'Add Exercise',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }


}
