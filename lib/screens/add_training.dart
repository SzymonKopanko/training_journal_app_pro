import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../models/exercise.dart';
import '../models/training.dart';
import '../services/exercise_service.dart';
import '../services/journal_database.dart';
import '../services/training_service.dart';
import '../models/exercise_training_relation.dart';

class AddTrainingScreen extends StatefulWidget {
  const AddTrainingScreen({super.key});

  @override
  _AddTrainingScreenState createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  List<Exercise> selectedExercises = [];
  TextEditingController trainingNameController = TextEditingController();
  TextEditingController searchBarController = TextEditingController();
  List<String> takenTrainingNames = [];
  List<Exercise> exercises = [];
  List<Exercise> allExercises = [];
  List<Exercise> filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    final loadedExercises = await ExerciseService(instance).readAllExercises();
    final loadedTrainings = await TrainingService(instance).readAllTrainings();
    List<String> loadedTakenTrainingNames = [];
    if(loadedTrainings != null){
      for(Training training in loadedTrainings){
        loadedTakenTrainingNames.add(training.name);
      }
    }
    if (loadedExercises != null) {
      setState(() {
        allExercises = loadedExercises;
        exercises = loadedExercises;
        filteredExercises = loadedExercises;
        if(loadedTrainings != null){
          takenTrainingNames = loadedTakenTrainingNames;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingsAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screen,
            child: TextField(
              controller: trainingNameController,
              decoration: InputDecoration(labelText: l10n.trainingNameLabel),
            ),
          ),
          Expanded(
              child: _buildSelectedExercisesList(),
          ),
            Padding(
              padding: AppSpacing.screen,
              child: TextFormField(
                controller: searchBarController,
                decoration: InputDecoration(
                  labelText: l10n.exercisesSearch,
                  suffixIcon: const Icon(Icons.search),
                ),
                onChanged: (query) {
                  _applyFilter();
                },
              ),
            ),
          if (allExercises.isNotEmpty)
            Expanded(
              child: filteredExercises.isEmpty
                  ? Center(
                      child: Text(l10n.exercisesNoMatch),
                    )
                  : _buildAvailableExercisesList(),
            ),
          if (selectedExercises.isNotEmpty)
            ElevatedButton(
              onPressed: _saveTraining,
              child: Text(l10n.trainingsSave),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedExercisesList() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(l10n.selectedExercises)),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Exercise movedExercise =
                    selectedExercises.removeAt(oldIndex);
                selectedExercises.insert(newIndex, movedExercise);
              });
            },
            children: List.generate(
              selectedExercises.length,
              (index) {
                final exercise = selectedExercises[index];
                return Card(
                  key: ValueKey(exercise.id),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(exercise.name),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              selectedExercises.remove(exercise);
                              exercises.add(exercise);
                              _applyFilter();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableExercisesList() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(l10n.availableExercises)),
        Expanded(
            child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredExercises.length,
          itemBuilder: (context, index) {
            final exercise = filteredExercises[index];
            return Card(
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(exercise.name),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          selectedExercises.add(exercise);
                          exercises.remove(exercise);
                          _applyFilter();
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  void _applyFilter() {
    setState(() {
      exercises.sort((a, b) => a.name.compareTo(b.name));
      if (searchBarController.text.isNotEmpty) {
        filteredExercises = exercises
            .where((exercise) => exercise.name
                .toLowerCase()
                .contains(searchBarController.text.toLowerCase()))
            .toList();
      } else {
        filteredExercises = exercises;
      }
    });
  }

  void _saveTraining() async {
    final l10n = AppLocalizations.of(context);
    final instance = JournalDatabase.instance;
    if (selectedExercises.isNotEmpty) {
      final trainingName = trainingNameController.text.trim();
      if (trainingName.isNotEmpty) {
        if(!takenTrainingNames.contains(trainingName)){
          final newTraining = Training(name: trainingName);
          final createdTraining =
          await TrainingService(instance).createTraining(newTraining);
          for (int index = 0; index < selectedExercises.length; index++) {
            final exerciseId = selectedExercises[index].id;
            await TrainingService(instance).createExerciseTrainingRelation(
              ExerciseTrainingRelation(
                exerciseId: exerciseId!,
                trainingId: createdTraining.id!,
                placement: index,
              ),
            );
          }
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.trainingsNameTaken)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.trainingsNameEmpty)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingsSelectAtLeastOne)),
      );
    }
  }
}
