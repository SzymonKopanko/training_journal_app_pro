import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../models/training_with_exercises.dart';
import 'database_providers.dart';

class TrainingsState {
  final List<TrainingWithExercises> trainings;
  final Map<int, List<String>> bodyPartsByExerciseId;
  final bool noExercises;

  const TrainingsState({
    this.trainings = const [],
    this.bodyPartsByExerciseId = const {},
    this.noExercises = false,
  });
}

class TrainingsNotifier extends AsyncNotifier<TrainingsState> {
  @override
  Future<TrainingsState> build() => _load();

  Future<TrainingsState> _load() async {
    final trainingService = ref.read(trainingServiceProvider);
    final exerciseService = ref.read(exerciseServiceProvider);
    final bodyPartService = ref.read(bodyPartServiceProvider);

    final loadedTrainings = await trainingService.readAllTrainings();
    final allExercises = <Exercise>[];
    final trainingsWithExercises = <TrainingWithExercises>[];
    var noExercises = false;

    if (loadedTrainings != null) {
      for (final training in loadedTrainings) {
        final trainingExercises =
            await exerciseService.readAllExercisesByTraining(training);
        if (trainingExercises == null) continue;
        trainingsWithExercises
            .add(TrainingWithExercises(training, trainingExercises));
        for (final exercise in trainingExercises) {
          if (!allExercises.contains(exercise)) {
            allExercises.add(exercise);
          }
        }
      }
    } else {
      final exercises = await exerciseService.readAllExercises();
      noExercises = exercises == null;
    }

    final bodyPartsMap = <int, List<String>>{};
    for (final exercise in allExercises) {
      final bodyParts =
          await bodyPartService.readAllBodyPartsByExercise(exercise);
      if (bodyParts != null) {
        bodyPartsMap[exercise.id!] = bodyParts.map((bp) => bp.name).toList();
      }
    }

    return TrainingsState(
      trainings: trainingsWithExercises,
      bodyPartsByExerciseId: bodyPartsMap,
      noExercises: noExercises,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> deleteTraining(int id) async {
    await ref.read(trainingServiceProvider).deleteTraining(id);
    await refresh();
  }
}

final trainingsProvider =
    AsyncNotifierProvider<TrainingsNotifier, TrainingsState>(
  TrainingsNotifier.new,
);
