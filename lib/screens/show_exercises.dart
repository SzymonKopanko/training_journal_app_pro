import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/models/exercise.dart';

import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../providers/exercises_provider.dart';
import 'add_exercise.dart';
import 'add_specified_entry.dart';
import 'edit_exercise.dart';
import 'show_specified_entries.dart';

class ShowExercises extends ConsumerStatefulWidget {
  const ShowExercises({super.key});

  @override
  ConsumerState<ShowExercises> createState() => _ShowExercisesState();
}

class _ShowExercisesState extends ConsumerState<ShowExercises> {
  final TextEditingController searchBarController = TextEditingController();

  List<Exercise> _filterExercises(
    List<Exercise> exercises,
    Map<int, List<String>> bodyPartsMap,
  ) {
    final query = searchBarController.text.toLowerCase();
    if (query.isEmpty) return exercises;
    return exercises.where((exercise) {
      final matchesName = exercise.name.toLowerCase().contains(query);
      final matchesBodyParts = (bodyPartsMap[exercise.id] ?? [])
          .any((bodyPart) => bodyPart.toLowerCase().contains(query));
      return matchesName || matchesBodyParts;
    }).toList();
  }

  Future<void> _refresh() => ref.read(exercisesProvider.notifier).refresh();

  void _openAddExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
    ).then((_) => _refresh());
  }

  PreferredSizeWidget _exercisesAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.exercisesTitle),
      actions: [
        IconButton(
          onPressed: _openAddExercise,
          icon: const Icon(Icons.add),
          tooltip: l10n.exercisesAdd,
        ),
      ],
    );
  }

  Future<void> _deleteExercise(
    BuildContext context,
    Exercise exercise,
  ) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.exercisesDeleteTitle),
          content: Text(l10n.exercisesDeleteBody(exercise.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(exercisesProvider.notifier)
                    .deleteExercise(exercise.id!);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.exercisesDeleteConfirm),
            ),
          ],
        );
      },
    );
  }

  String formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercisesAsync = ref.watch(exercisesProvider);

    return exercisesAsync.when(
      loading: () => Scaffold(
        appBar: _exercisesAppBar(l10n),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _exercisesAppBar(l10n),
        body: Center(child: Text(l10n.bodyEntriesLoadError)),
      ),
      data: (data) {
        final exercises = data.exercises;
        final exerciseBodyPartsMap = data.bodyPartsByExerciseId;
        final filteredExercises =
            _filterExercises(exercises, exerciseBodyPartsMap);

        return Scaffold(
          appBar: _exercisesAppBar(l10n),
          body: Column(
            children: [
              if (exercises.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSizing.padding2),
                  child: TextFormField(
                    controller: searchBarController,
                    decoration: InputDecoration(
                      labelText: l10n.exercisesSearch,
                      suffixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              if (exercises.isNotEmpty)
                Expanded(
                  child: filteredExercises.isEmpty
                      ? Center(child: Text(l10n.exercisesNoMatch))
                      : Padding(
                          padding: const EdgeInsets.all(AppSizing.padding2),
                          child: ListView.builder(
                            itemCount: filteredExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = filteredExercises[index];
                              final bodyParts =
                                  exerciseBodyPartsMap[exercise.id] ?? [];
                              return Card(
                                margin:
                                    const EdgeInsets.all(AppSizing.padding4),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(AppSizing.padding2),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: AppSizing.fontSize3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: AppSizing.padding3),
                                      if (exercise.oneRM != 0)
                                        Text(
                                          l10n.exercisesOneRepMax(
                                            exercise.oneRM.toStringAsFixed(2),
                                            exercise.weight.toStringAsFixed(2),
                                            exercise.reps,
                                          ),
                                        ),
                                      if (exercise.oneRM != 0)
                                        Text(
                                          l10n.exercisesDateTime(
                                            DateFormat('dd.MM.yyyy, HH:mm')
                                                .format(exercise.date),
                                          ),
                                        ),
                                      if (bodyParts.isNotEmpty)
                                        Text(
                                          l10n.exercisesBodyParts(
                                            bodyParts
                                                .map((bp) => localizedBodyPart(
                                                    context, bp))
                                                .join(', '),
                                          ),
                                        ),
                                      if (exercise.notes.isNotEmpty)
                                        Text(l10n.labelNotes(exercise.notes)),
                                      if (exercise.restTime != 0)
                                        Text(l10n.exercisesDefaultRestTime(
                                            formatRestTime(exercise.restTime))),
                                      if (exercise.bodyweightPercentage != 0)
                                        Text(l10n.exercisesBodyweightLifted(
                                            exercise.bodyweightPercentage)),
                                      const SizedBox(width: AppSizing.padding2),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Tooltip(
                                            message: l10n.tooltipAddEntry,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddSpecifiedEntryScreen(
                                                      chosenExercise: exercise,
                                                    ),
                                                  ),
                                                ).then((_) => _refresh());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                                context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.brightButt
                                                    : AppColors.darkButt,
                                              ),
                                              child: const Icon(Icons.add),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSizing.padding2),
                                          Tooltip(
                                            message: l10n.tooltipShowEntries,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShowSpecifiedEntries(
                                                      chosenExercise: exercise,
                                                    ),
                                                  ),
                                                ).then((_) => _refresh());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                                context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.brightButt
                                                    : AppColors.darkButt,
                                              ),
                                              child: const Icon(
                                                  Icons.library_books_outlined),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSizing.padding2),
                                          Tooltip(
                                            message: l10n.commonEdit,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditExerciseScreen(
                                                      chosenExercise: exercise,
                                                    ),
                                                  ),
                                                ).then((_) => _refresh());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                                context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.brightButt
                                                    : AppColors.darkButt,
                                              ),
                                              child: const Icon(Icons.edit),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSizing.padding2),
                                          Tooltip(
                                            message: l10n.commonDelete,
                                            child: ElevatedButton(
                                              onPressed: () => _deleteExercise(
                                                  context, exercise),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                                context)
                                                            .brightness !=
                                                        Brightness.light
                                                    ? AppColors.darkErrButt
                                                    : AppColors.brightErrButt,
                                              ),
                                              child: Icon(
                                                Icons.delete,
                                                color: Theme.of(context)
                                                            .brightness !=
                                                        Brightness.light
                                                    ? AppColors.darkErrTxt
                                                    : AppColors.brightErrTxt,
                                              ),
                                            ),
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
                Expanded(child: Center(child: Text(l10n.exercisesEmpty))),
            ],
          ),
        );
      },
    );
  }
}
