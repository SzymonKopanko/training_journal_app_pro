import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/exercise.dart';
import '../services/body_part_service.dart';
import '../services/exercise_service.dart';
import '../models/training.dart';
import '../models/training_with_exercises.dart';
import '../services/journal_database.dart';
import '../services/training_service.dart';
import 'add_entry.dart';
import 'add_training.dart';
import 'edit_training.dart';

class ShowTrainingsScreen extends StatefulWidget {
  const ShowTrainingsScreen({super.key});

  @override
  _ShowTrainingsScreenState createState() => _ShowTrainingsScreenState();
}

class _ShowTrainingsScreenState extends State<ShowTrainingsScreen> {
  List<TrainingWithExercises> trainingsWithExercises = [];
  List<TrainingWithExercises> filteredTrainingsWithExercises = [];
  TextEditingController searchBarController = TextEditingController();
  bool noExercises = false;
  List<Exercise> exercises = [];
  Map<int, List<String>> exerciseBodyPartsMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    final loadedTrainings = await TrainingService(instance).readAllTrainings();
    List<Exercise> allExercises = [];
    List<TrainingWithExercises> loadedTrainingsWithExercises = [];
    if (loadedTrainings != null) {
      for (Training training in loadedTrainings) {
        final trainingExercises = await ExerciseService(instance)
            .readAllExercisesByTraining(training);
        loadedTrainingsWithExercises
            .add(TrainingWithExercises(training, trainingExercises!));
        for(var exercise in trainingExercises){
          if(!allExercises.contains(exercise)){
            allExercises.add(exercise);
          }
        }
      }
    }

    else{
      final exercises = await ExerciseService(instance).readAllExercises();
      if(exercises == null){
        setState(() {
          noExercises = true;
        });
      }
    }
    exercises = allExercises;
    await _loadBodyPartsForExercises();
    setState(() {
      trainingsWithExercises = loadedTrainingsWithExercises;
      filteredTrainingsWithExercises = loadedTrainingsWithExercises;
    });
  }

  Future<void> _loadBodyPartsForExercises() async {
    final instance = JournalDatabase.instance;
    for (var exercise in exercises) {
      final bodyParts = await BodyPartService(instance).readAllBodyPartsByExercise(exercise);
      if (bodyParts != null) {
        setState(() {
          exerciseBodyPartsMap[exercise.id!] = bodyParts.map((bp) => bp.name).toList();
        });
      }
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
                _loadData();
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
                padding: const EdgeInsets.all(AppSizing.padding2),
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
                  padding: const EdgeInsets.all(AppSizing.padding2),
                  child: ListView.builder(
                    itemCount: filteredTrainingsWithExercises.length,
                    itemBuilder: (context, index) {
                      final trainingWithExercises = filteredTrainingsWithExercises[index];
                      return Card(
                        margin: const EdgeInsets.all(AppSizing.padding4),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizing.padding2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trainingWithExercises.training.name,
                                style: const TextStyle(
                                  fontSize: AppSizing.fontSize2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizing.padding4),
                              // Wyświetlanie ćwiczeń z ich partiami ciała
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: trainingWithExercises.exercises.map((exercise) {
                                  final bodyParts = exerciseBodyPartsMap[exercise.id!] ?? [];
                                  final bodyPartsText = bodyParts.isNotEmpty
                                      ? ' (${bodyParts.join(', ')})'
                                      : ' (No body parts assigned)';
                                  return Text(
                                      '${exercise.name}$bodyPartsText',
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: AppSizing.padding2),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEntryScreen(
                                          chosenTrainingWithExercises: trainingWithExercises,
                                        ),
                                      ),
                                    ).then((_) {
                                      _loadData();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MediaQuery.platformBrightnessOf(super.context) ==
                                        Brightness.light
                                        ? AppColors.brightButt
                                        : AppColors.darkButt,
                                    fixedSize: AppSizing.buttonSize4,
                                  ),
                                  child: const Text('Add Training Entries'),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteTraining(context, index);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MediaQuery.platformBrightnessOf(super.context) !=
                                          Brightness.light
                                          ? AppColors.darkErrButt
                                          : AppColors.brightErrButt,
                                      fixedSize: AppSizing.buttonSize3,
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: MediaQuery.platformBrightnessOf(super.context) !=
                                            Brightness.light
                                            ? AppColors.darkErrTxt
                                            : AppColors.brightErrTxt,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizing.padding2),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditTrainingScreen(
                                            chosenTrainingWithExercises: trainingWithExercises,
                                          ),
                                        ),
                                      ).then((_) {
                                        _loadData();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MediaQuery.platformBrightnessOf(super.context) ==
                                          Brightness.light
                                          ? AppColors.brightButt
                                          : AppColors.darkButt,
                                      fixedSize: AppSizing.buttonSize3,
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    ,
                  ),
                ),
              ),
            if (noExercises)
              const Expanded(
                child: Center(
                  child: Text('No exercises found, add some before creating trainings.'),
                ),
              ),
            if (!noExercises && trainingsWithExercises.isEmpty)
              const Expanded(
                child:  Center(
                  child: Text('No trainings found, add some.'),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTrainingScreen()),
                ).then((_) {
                  _loadData();
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: AppSizing.buttonSize1,
              ),
              child: const Text(
                'Add Training',
                style: TextStyle(
                  fontSize: AppSizing.fontSize4,
                ),
              ),
            ),
            const SizedBox(height: AppSizing.padding1),
          ],
        ),
      ),
    );
  }
}
