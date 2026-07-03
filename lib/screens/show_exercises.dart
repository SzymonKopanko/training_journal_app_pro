import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/models/exercise.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../providers/exercises_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bar_add_action.dart';
import '../widgets/app_card_action_row.dart';
import '../widgets/app_card_icon_button.dart';
import '../widgets/app_list_card.dart';
import '../widgets/app_search_field.dart';
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

  PreferredSizeWidget _appBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.exercisesTitle),
      actions: [
        AppBarAddAction(
          tooltip: l10n.exercisesAdd,
          onPressed: _openAddExercise,
        ),
      ],
    );
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exercisesDeleteTitle),
        content: Text(l10n.exercisesDeleteBody(exercise.name)),
        actions: [
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
      ),
    );
  }

  String _formatRestTime(int seconds) {
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
    final textTheme = Theme.of(context).textTheme;
    final exercisesAsync = ref.watch(exercisesProvider);

    return exercisesAsync.when(
      loading: () => Scaffold(
        appBar: _appBar(l10n),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _appBar(l10n),
        body: Center(child: Text(l10n.bodyEntriesLoadError)),
      ),
      data: (data) {
        final exercises = data.exercises;
        final exerciseBodyPartsMap = data.bodyPartsByExerciseId;
        final filteredExercises =
            _filterExercises(exercises, exerciseBodyPartsMap);

        return Scaffold(
          appBar: _appBar(l10n),
          body: Column(
            children: [
              if (exercises.isNotEmpty)
                Padding(
                  padding: AppSpacing.screen,
                  child: AppSearchField(
                    controller: searchBarController,
                    labelText: l10n.exercisesSearch,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              if (exercises.isNotEmpty)
                Expanded(
                  child: filteredExercises.isEmpty
                      ? Center(child: Text(l10n.exercisesNoMatch))
                      : ListView.builder(
                          padding: AppSpacing.screen,
                          itemCount: filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = filteredExercises[index];
                            final bodyParts =
                                exerciseBodyPartsMap[exercise.id] ?? [];
                            return AppListCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: textTheme.titleMedium,
                                  ),
                                  AppSpacing.gapSm,
                                  if (exercise.oneRM != 0)
                                    Text(
                                      l10n.exercisesOneRepMax(
                                        exercise.oneRM.toStringAsFixed(2),
                                        exercise.weight.toStringAsFixed(2),
                                        exercise.reps,
                                      ),
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (exercise.oneRM != 0)
                                    Text(
                                      l10n.exercisesDateTime(
                                        DateFormat('dd.MM.yyyy, HH:mm')
                                            .format(exercise.date),
                                      ),
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (bodyParts.isNotEmpty)
                                    Text(
                                      l10n.exercisesBodyParts(
                                        bodyParts
                                            .map((bp) => localizedBodyPart(
                                                context, bp))
                                            .join(', '),
                                      ),
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (exercise.notes.isNotEmpty)
                                    Text(
                                      l10n.labelNotes(exercise.notes),
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (exercise.restTime != 0)
                                    Text(
                                      l10n.exercisesDefaultRestTime(
                                          _formatRestTime(exercise.restTime)),
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (exercise.bodyweightPercentage != 0)
                                    Text(
                                      l10n.exercisesBodyweightLifted(
                                          exercise.bodyweightPercentage),
                                      style: textTheme.bodyMedium,
                                    ),
                                  AppSpacing.gapMd,
                                  AppCardActionRow(
                                    children: [
                                      AppCardIconButton(
                                        icon: Icons.add,
                                        tooltip: l10n.tooltipAddEntry,
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
                                      ),
                                      AppCardIconButton(
                                        icon: Icons.library_books_outlined,
                                        tooltip: l10n.tooltipShowEntries,
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
                                      ),
                                      AppCardIconButton(
                                        icon: Icons.edit,
                                        tooltip: l10n.commonEdit,
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
                                      ),
                                      AppCardIconButton(
                                        icon: Icons.delete,
                                        tooltip: l10n.commonDelete,
                                        destructive: true,
                                        onPressed: () =>
                                            _deleteExercise(exercise),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
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
