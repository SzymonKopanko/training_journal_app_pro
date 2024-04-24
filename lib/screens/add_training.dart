import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Training'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: trainingNameController,
              decoration: const InputDecoration(labelText: 'Training Name'),
            ),
          ),
          Expanded(
              child: _buildSelectedExercisesList(),
          ),
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
          if (allExercises.isNotEmpty)
            Expanded(
              child: filteredExercises.isEmpty
                  ? const Center(
                      child: Text('No matching exercises found.'),
                    )
                  : _buildAvailableExercisesList(),
            ),
          if (selectedExercises.isNotEmpty)
            ElevatedButton(
              onPressed: _saveTraining,
              child: const Text('Save Training'),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Selected Exercises:')),
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
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? const Color.fromARGB(255, 228, 245, 224)
                      : const Color.fromARGB(255, 27, 44, 23),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Available Exercises:')),
        Expanded(
            child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredExercises.length,
          itemBuilder: (context, index) {
            final exercise = filteredExercises[index];
            return Card(
              color: MediaQuery.platformBrightnessOf(super.context) ==
                      Brightness.light
                  ? const Color.fromARGB(255, 228, 245, 224)
                  : const Color.fromARGB(255, 27, 44, 23),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
            const SnackBar(content: Text('This training name is already taken.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Training name cannot be empty.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one exercise for the training.')),
      );
    }
  }
}
