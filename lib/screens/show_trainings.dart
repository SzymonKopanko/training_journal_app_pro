import 'package:flutter/material.dart';
import '../services/exercise_service.dart';
import '../models/exercise.dart';
import '../models/training.dart';
import '../models/training_with_exercises.dart';
import '../services/journal_database.dart';
import '../services/training_service.dart';
import 'add_entry.dart';
import 'add_training.dart';
import 'edit_training.dart';

class ShowTrainingsScreen extends StatefulWidget {
  const ShowTrainingsScreen({Key? key}) : super(key: key);

  @override
  _ShowTrainingsScreenState createState() => _ShowTrainingsScreenState();
}

class _ShowTrainingsScreenState extends State<ShowTrainingsScreen> {
  List<TrainingWithExercises> trainingsWithExercises = [];
  List<TrainingWithExercises> filteredTrainingsWithExercises = [];
  TextEditingController searchBarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    final loadedTrainings = await TrainingService(instance).readAllTrainings();
    List<TrainingWithExercises> loadedTrainingsWithExercises = [];
    if (loadedTrainings != null) {
      for (Training training in loadedTrainings) {
        final trainingExercises = await ExerciseService(instance)
            .readAllExercisesByTraining(training);
        loadedTrainingsWithExercises
            .add(TrainingWithExercises(training, trainingExercises!));
      }
      setState(() {
        trainingsWithExercises = loadedTrainingsWithExercises;
        filteredTrainingsWithExercises = loadedTrainingsWithExercises;
      });
    }
  }

  Future<void> _deleteTraining(BuildContext context, int index) async {
    final trainingToDelete = filteredTrainingsWithExercises[index].training;
    final trainingDeletedName = trainingToDelete.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Training?'),
          content:  Text(
              'This action will delete all entries for this training($trainingDeletedName) with it.'
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
                TrainingService trainingService = TrainingService(instance);
                await trainingService.deleteTraining(trainingToDelete.id!);
                await _loadData();
                _applyFilter();
                Navigator.of(context).pop();
              },
              child: const Text('Delete Training'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter() {
    if (trainingsWithExercises.isNotEmpty) {
      setState(() {
        if (searchBarController.text.isNotEmpty) {
          filteredTrainingsWithExercises = trainingsWithExercises
              .where((trainingWithExercises) => trainingWithExercises
                  .training.name
                  .toLowerCase()
                  .contains(searchBarController.text.toLowerCase()))
              .toList();
        } else {
          filteredTrainingsWithExercises = trainingsWithExercises;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainings'),
      ),
      body: Center(
        child: Column(
          children: [
            if (trainingsWithExercises.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: searchBarController,
                  decoration: const InputDecoration(
                    labelText: 'Search Trainings',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    _applyFilter();
                  },
                ),
              ),
            if (trainingsWithExercises.isNotEmpty)
              Expanded(
                child: filteredTrainingsWithExercises.isEmpty
                    ? const Center(
                        child: Text('No matching trainings found.'),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: filteredTrainingsWithExercises.length,
                          itemBuilder: (context, index) {
                            final trainingWithExercises =
                                filteredTrainingsWithExercises[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trainingWithExercises.training.name,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(trainingWithExercises.toString()),
                                    const SizedBox(height: 16.0),
                                    Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEntryScreen(chosenTrainingWithExercises: trainingWithExercises),
                                          ),
                                        ).then((_) {
                                          _loadData();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            MediaQuery.platformBrightnessOf(
                                                        super.context) ==
                                                    Brightness.light
                                                ? const Color.fromARGB(
                                                    255, 228, 245, 224)
                                                : const Color.fromARGB(
                                                    255, 27, 44, 23),
                                        fixedSize: const Size(280, 25),
                                      ),
                                      child: const Text('Add Training Entries'),
                                    )),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _deleteTraining(context, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                MediaQuery.platformBrightnessOf(
                                                            super.context) !=
                                                        Brightness.light
                                                    ? const Color.fromARGB(
                                                        100, 70, 40, 46)
                                                    : const Color.fromARGB(
                                                        255, 252, 234, 234),
                                            fixedSize: const Size(140, 25),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: MediaQuery
                                                          .platformBrightnessOf(
                                                              super.context) !=
                                                      Brightness.light
                                                  ? const Color.fromARGB(
                                                      255, 255, 146, 146)
                                                  : const Color.fromARGB(
                                                      255, 183, 0, 0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditTrainingScreen(
                                                  chosenTrainingWithExercises: trainingWithExercises,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                MediaQuery.platformBrightnessOf(
                                                            super.context) ==
                                                        Brightness.light
                                                    ? const Color.fromARGB(
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
                child: Center(
                  child: Text('No exercises found, add some.'),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTrainingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Add Training',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}