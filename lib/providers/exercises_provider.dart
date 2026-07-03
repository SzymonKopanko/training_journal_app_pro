import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import 'database_providers.dart';

class ExercisesState {
  final List<Exercise> exercises;
  final Map<int, List<String>> bodyPartsByExerciseId;

  const ExercisesState({
    this.exercises = const [],
    this.bodyPartsByExerciseId = const {},
  });
}

class ExercisesNotifier extends AsyncNotifier<ExercisesState> {
  @override
  Future<ExercisesState> build() => _load();

  Future<ExercisesState> _load() async {
    final exerciseService = ref.read(exerciseServiceProvider);
    final bodyPartService = ref.read(bodyPartServiceProvider);
    final loaded = await exerciseService.readAllExercises() ?? [];
    final bodyPartsMap = <int, List<String>>{};

    for (final exercise in loaded) {
      final bodyParts =
          await bodyPartService.readAllBodyPartsByExercise(exercise);
      if (bodyParts != null) {
        bodyPartsMap[exercise.id!] = bodyParts.map((bp) => bp.name).toList();
      }
    }

    return ExercisesState(
      exercises: loaded,
      bodyPartsByExerciseId: bodyPartsMap,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> deleteExercise(int id) async {
    await ref.read(exerciseServiceProvider).deleteExercise(id);
    await refresh();
  }
}

final exercisesProvider =
    AsyncNotifierProvider<ExercisesNotifier, ExercisesState>(
  ExercisesNotifier.new,
);
