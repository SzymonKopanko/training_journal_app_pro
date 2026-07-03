import 'dart:async';

import 'package:flutter/material.dart';
import 'package:training_journal_app/models/body_part.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/body_part_service.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../theme/app_spacing.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/exercise_body_part_relation.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  Duration _selectedRestTime = const Duration(minutes: 0, seconds: 0);
  String _restTimeDisplay = '00:00';
  int _selectedBodyweightPercentage = 0;
  String _bodyweightDisplay = '0%';
  List<BodyPart> _availableBodyParts = [];
  List<BodyPart> _selectedBodyParts = [];

  @override
  void initState() {
    super.initState();
    _fetchBodyParts();
  }

  Future<void> _fetchBodyParts() async {
    final instance = JournalDatabase.instance;
    final bodyPartService = BodyPartService(instance);

    // Pobierz wszystkie dostępne partie ciała
    var allBodyParts = await bodyPartService.readAllBodyParts();
    if (allBodyParts == null) {
      await bodyPartService.createAllBodyParts();
      allBodyParts = await bodyPartService.readAllBodyParts();
    }
    setState(() {
      _availableBodyParts = allBodyParts ?? [];
    });
  }

  Future<void> _addExerciseToDatabase() async {
    if (nameController.text.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context).exercisesNameRequired);
      return;
    }

    final instance = JournalDatabase.instance;
    final exerciseService = ExerciseService(instance);

    final exercise = Exercise(
      name: nameController.text,
      date: DateTime.now(),
      weight: 0.0,
      reps: 0,
      oneRM: 0.0,
      notes: notesController.text,
      restTime: _selectedRestTime.inSeconds,
      bodyweightPercentage: _selectedBodyweightPercentage,
    );

    final createdExercise = await exerciseService.createExercise(exercise);

    // Dodaj relacje między ćwiczeniem a wybranymi partiami ciała
    final bodyPartService = BodyPartService(instance);
    for (var bodyPart in _selectedBodyParts) {
      final relation = ExerciseBodyPartRelation(
        exerciseId: createdExercise.id!,
        bodyPartId: bodyPart.id!,
      );
      await bodyPartService.createExerciseBodyPartRelation(relation);
    }

    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.commonError),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.commonOk),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Duration?> _showTimePickerDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    int selectedMinutes = _selectedRestTime.inMinutes.remainder(60);
    int selectedSeconds = _selectedRestTime.inSeconds.remainder(60);

    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.restTimeTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selectedMinutes.toString().padLeft(2, '0')}:${selectedSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        l10n.restMinutes(selectedMinutes),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: selectedMinutes.toDouble(),
                        min: 0,
                        max: 15,
                        divisions: 15,
                        label: l10n.restMinutesLabel(selectedMinutes),
                        onChanged: (double value) {
                          setState(() {
                            selectedMinutes = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        l10n.restSeconds(selectedSeconds),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: selectedSeconds.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        label: l10n.restSecondsLabel(selectedSeconds),
                        onChanged: (double value) {
                          setState(() {
                            selectedSeconds = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      Duration(
                          minutes: selectedMinutes, seconds: selectedSeconds),
                    );
                  },
                  child: Text(l10n.commonOk),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<int?> _showBodyweightPercentageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    int selectedPercentage = _selectedBodyweightPercentage;

    return await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.bodyweightPctTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedPercentage%',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: selectedPercentage.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$selectedPercentage%',
                    onChanged: (double value) {
                      setState(() {
                        selectedPercentage = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedPercentage);
                  },
                  child: Text(l10n.commonOk),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exercisesAdd),
      ),
      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.exerciseNameLabel),
            ),
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(labelText: l10n.notesLabel),
            ),
            AppSpacing.gapMd,
            Row(
              children: [
                Text(l10n.defaultRestTimeLabel),
                AppSpacing.gapMd,
                ElevatedButton(
                  onPressed: () {
                    _showTimePickerDialog(context).then((duration) {
                      if (duration != null) {
                        setState(() {
                          _selectedRestTime = duration;
                          _restTimeDisplay = _formatDuration(_selectedRestTime);
                        });
                      }
                    });
                  },
                  child: Text(
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'DSEG7',
                    ),
                    _restTimeDisplay,
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            Row(
              children: [
                Text(l10n.bodyweightLiftedLabel),
                AppSpacing.gapMd,
                ElevatedButton(
                  onPressed: () {
                    _showBodyweightPercentageDialog(context).then((percentage) {
                      if (percentage != null) {
                        setState(() {
                          _selectedBodyweightPercentage = percentage;
                          _bodyweightDisplay = '$percentage%';
                        });
                      }
                    });
                  },
                  child: Text(
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'DSEG7',
                    ),
                    _bodyweightDisplay,
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            Text(l10n.selectedBodyParts),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedBodyParts.length,
                itemBuilder: (context, index) {
                  final bodyPart = _selectedBodyParts[index];
                  return ListTile(
                    title: Text(localizedBodyPart(context, bodyPart.name)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _selectedBodyParts.remove(bodyPart);
                          _availableBodyParts.add(bodyPart);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            AppSpacing.gapMd,
            Text(l10n.availableBodyParts),
            Expanded(
              child: ListView.builder(
                itemCount: _availableBodyParts.length,
                itemBuilder: (context, index) {
                  final bodyPart = _availableBodyParts[index];
                  return ListTile(
                    title: Text(localizedBodyPart(context, bodyPart.name)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _availableBodyParts.remove(bodyPart);
                          _selectedBodyParts.add(bodyPart);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            AppSpacing.gapMd,
            ElevatedButton(
              onPressed: _addExerciseToDatabase,
              child: Text(l10n.exercisesAdd),
            ),
          ],
        ),
      ),
    );
  }
}
