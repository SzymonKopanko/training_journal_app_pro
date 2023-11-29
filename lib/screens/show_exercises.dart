import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/screens/chart_screen.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/exercise_service.dart';

class ShowExercises extends StatefulWidget {
  const ShowExercises({Key? key}) : super(key: key);

  @override
  _ShowExercisesState createState() => _ShowExercisesState();
}

class _ShowExercisesState extends State<ShowExercises> {
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final instance = JournalDatabase.instance;
    final loadedExercises = await ExerciseService(instance).readAllExercises();
    if(loadedExercises != null){
      setState(() {
        exercises = loadedExercises;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body:  exercises.isEmpty
          ? const Center(
              child: Text('No exercises available. Add some entries.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
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
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'One Rep Max: ${exercise.oneRM.toStringAsFixed(2)} kg'),
                          Text(
                              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(exercise.date)}'),
                          Row(
                            children: [
                              // ElevatedButton(
                              //   onPressed: () {
                              //     if (index >= 0 && index < exercises!.length) {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               ExerciseChartScreen(
                              //                   exercise:
                              //                       exercises![index]),
                              //         ),
                              //       );
                              //     }
                              //   },
                              //   child: const Text('Show Chart'),
                              // ),
                              const SizedBox(width: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  _deleteExercise(context, index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
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
    );
  }
}
