import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/training_with_exercises.dart';
import '../providers/trainings_provider.dart';
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
        .where((item) =>
            item.training.name.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _refresh() => ref.read(trainingsProvider.notifier).refresh();

  void _openAddTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTrainingScreen()),
    ).then((_) => _refresh());
  }

  PreferredSizeWidget _trainingsAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.trainingsTitle),
      actions: [
        IconButton(
          onPressed: _openAddTraining,
          icon: const Icon(Icons.add),
          tooltip: l10n.trainingsAdd,
        ),
      ],
    );
  }

  Future<void> _deleteTraining(
    BuildContext context,
    TrainingWithExercises trainingWithExercises,
  ) async {
    final l10n = AppLocalizations.of(context);
    final trainingDeletedName = trainingWithExercises.training.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.trainingsDeleteTitle),
          content: Text(l10n.trainingsDeleteBody(trainingDeletedName)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(trainingsProvider.notifier)
                    .deleteTraining(trainingWithExercises.training.id!);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.trainingsDeleteConfirm),
            ),
          ],
        );
      },
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
    final trainingsAsync = ref.watch(trainingsProvider);

    return trainingsAsync.when(
      loading: () => Scaffold(
        appBar: _trainingsAppBar(l10n),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _trainingsAppBar(l10n),
        body: Center(child: Text(l10n.bodyEntriesLoadError)),
      ),
      data: (data) {
        final trainingsWithExercises = data.trainings;
        final exerciseBodyPartsMap = data.bodyPartsByExerciseId;
        final noExercises = data.noExercises;
        final filteredTrainings =
            _filterTrainings(trainingsWithExercises);

        return Scaffold(
          appBar: _trainingsAppBar(l10n),
          body: Center(
            child: Column(
              children: [
                if (trainingsWithExercises.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSizing.padding2),
                    child: TextFormField(
                      controller: searchBarController,
                      decoration: InputDecoration(
                        labelText: l10n.trainingsSearch,
                        suffixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                if (trainingsWithExercises.isNotEmpty)
                  Expanded(
                    child: filteredTrainings.isEmpty
                        ? Center(child: Text(l10n.trainingsNoMatch))
                        : Padding(
                            padding: const EdgeInsets.all(AppSizing.padding2),
                            child: ListView.builder(
                              itemCount: filteredTrainings.length,
                              itemBuilder: (context, index) {
                                final trainingWithExercises =
                                    filteredTrainings[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.all(AppSizing.padding4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        AppSizing.padding2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trainingWithExercises.training.name,
                                          style: const TextStyle(
                                            fontSize: AppSizing.fontSize2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: AppSizing.padding4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: trainingWithExercises
                                              .exercises
                                              .map((exercise) {
                                            final bodyParts =
                                                exerciseBodyPartsMap[
                                                        exercise.id!] ??
                                                    [];
                                            final partsText = bodyParts
                                                    .isNotEmpty
                                                ? bodyParts
                                                    .map((bp) =>
                                                        localizedBodyPart(
                                                            context, bp))
                                                    .join(', ')
                                                : l10n
                                                    .trainingsNoBodyPartsAssigned;
                                            return Text(
                                              l10n.trainingExerciseWithParts(
                                                  exercise.name, partsText),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(
                                            height: AppSizing.padding2),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddEntryScreen(
                                                    chosenTrainingWithExercises:
                                                        trainingWithExercises,
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
                                              fixedSize: AppSizing.buttonSize4,
                                            ),
                                            child:
                                                Text(l10n.trainingsAddEntries),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => _deleteTraining(
                                                  context,
                                                  trainingWithExercises),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                                context)
                                                            .brightness !=
                                                        Brightness.light
                                                    ? AppColors.darkErrButt
                                                    : AppColors.brightErrButt,
                                                fixedSize:
                                                    AppSizing.buttonSize3,
                                              ),
                                              child: Text(
                                                l10n.commonDelete,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness !=
                                                          Brightness.light
                                                      ? AppColors.darkErrTxt
                                                      : AppColors.brightErrTxt,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSizing.padding2),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditTrainingScreen(
                                                      chosenTrainingWithExercises:
                                                          trainingWithExercises,
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
                                                fixedSize:
                                                    AppSizing.buttonSize3,
                                              ),
                                              child: Text(l10n.commonEdit),
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
                if (noExercises)
                  Expanded(
                    child: Center(child: Text(l10n.trainingsNoExercises)),
                  ),
                if (!noExercises && trainingsWithExercises.isEmpty)
                  Expanded(
                    child: Center(child: Text(l10n.trainingsEmpty)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
