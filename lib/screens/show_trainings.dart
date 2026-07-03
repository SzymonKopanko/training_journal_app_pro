import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/training_with_exercises.dart';
import '../providers/trainings_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bar_add_action.dart';
import '../widgets/app_card_action_row.dart';
import '../widgets/app_card_icon_button.dart';
import '../widgets/app_list_card.dart';
import '../widgets/app_search_field.dart';
import 'add_entry.dart';
import 'add_training.dart';
import 'edit_training.dart';

class ShowTrainingsScreen extends ConsumerStatefulWidget {
  const ShowTrainingsScreen({super.key});

  @override
  ConsumerState<ShowTrainingsScreen> createState() =>
      _ShowTrainingsScreenState();
}

class _ShowTrainingsScreenState extends ConsumerState<ShowTrainingsScreen> {
  final TextEditingController searchBarController = TextEditingController();

  List<TrainingWithExercises> _filterTrainings(
    List<TrainingWithExercises> trainings,
  ) {
    final query = searchBarController.text.toLowerCase();
    if (query.isEmpty) return trainings;
    return trainings
        .where((item) => item.training.name.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _refresh() => ref.read(trainingsProvider.notifier).refresh();

  void _openAddTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTrainingScreen()),
    ).then((_) => _refresh());
  }

  PreferredSizeWidget _appBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.trainingsTitle),
      actions: [
        AppBarAddAction(
          tooltip: l10n.trainingsAdd,
          onPressed: _openAddTraining,
        ),
      ],
    );
  }

  Future<void> _deleteTraining(TrainingWithExercises item) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trainingsDeleteTitle),
        content: Text(l10n.trainingsDeleteBody(item.training.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(trainingsProvider.notifier)
                  .deleteTraining(item.training.id!);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.trainingsDeleteConfirm),
          ),
        ],
      ),
    );
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
    final trainingsAsync = ref.watch(trainingsProvider);

    return trainingsAsync.when(
      loading: () => Scaffold(
        appBar: _appBar(l10n),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _appBar(l10n),
        body: Center(child: Text(l10n.bodyEntriesLoadError)),
      ),
      data: (data) {
        final trainingsWithExercises = data.trainings;
        final exerciseBodyPartsMap = data.bodyPartsByExerciseId;
        final noExercises = data.noExercises;
        final filteredTrainings = _filterTrainings(trainingsWithExercises);

        if (noExercises) {
          return Scaffold(
            appBar: _appBar(l10n),
            body: Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  l10n.trainingsNoExercises,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (trainingsWithExercises.isEmpty) {
          return Scaffold(
            appBar: _appBar(l10n),
            body: Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  l10n.trainingsEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _appBar(l10n),
          body: Column(
            children: [
              Padding(
                padding: AppSpacing.screen,
                child: AppSearchField(
                  controller: searchBarController,
                  labelText: l10n.trainingsSearch,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: filteredTrainings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: AppSpacing.screen,
                          child: Text(
                            l10n.trainingsNoMatch,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: AppSpacing.screen,
                        itemCount: filteredTrainings.length,
                        itemBuilder: (context, index) {
                          final item = filteredTrainings[index];
                          return AppListCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.training.name,
                                  style: textTheme.titleLarge,
                                ),
                                AppSpacing.gapSm,
                                ...item.exercises.map((exercise) {
                                  final bodyParts =
                                      exerciseBodyPartsMap[exercise.id!] ??
                                          [];
                                  final partsText = bodyParts.isNotEmpty
                                      ? bodyParts
                                          .map((bp) => localizedBodyPart(
                                              context, bp))
                                          .join(', ')
                                      : l10n.trainingsNoBodyPartsAssigned;
                                  return Text(
                                    l10n.trainingExerciseWithParts(
                                        exercise.name, partsText),
                                    style: textTheme.bodyMedium,
                                  );
                                }),
                                AppSpacing.gapMd,
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEntryScreen(
                                            chosenTrainingWithExercises:
                                                item,
                                          ),
                                        ),
                                      ).then((_) => _refresh());
                                    },
                                    icon: const Icon(Icons.fitness_center),
                                    label: Text(l10n.trainingsAddEntries),
                                  ),
                                ),
                                AppSpacing.gapSm,
                                AppCardActionRow(
                                  children: [
                                    AppCardIconButton(
                                      icon: Icons.delete,
                                      tooltip: l10n.commonDelete,
                                      destructive: true,
                                      onPressed: () =>
                                          _deleteTraining(item),
                                    ),
                                    AppCardIconButton(
                                      icon: Icons.edit,
                                      tooltip: l10n.commonEdit,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditTrainingScreen(
                                              chosenTrainingWithExercises:
                                                  item,
                                            ),
                                          ),
                                        ).then((_) => _refresh());
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
