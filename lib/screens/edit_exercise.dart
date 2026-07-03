import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/body_part_service.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../models/body_part.dart';
import '../models/exercise_body_part_relation.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise chosenExercise;

  const EditExerciseScreen({super.key, required this.chosenExercise});

  @override
  _EditExerciseScreenState createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  Duration? _selectedRestTime;
  String _restTimeDisplay = '00:00';
  int? _selectedBodyweightPercentage;
  String _bodyweightDisplay = '0%';

  List<BodyPart> _availableBodyParts = [];
  List<BodyPart> _selectedBodyParts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    nameController.text = widget.chosenExercise.name;
    notesController.text = widget.chosenExercise.notes;
    _selectedRestTime = Duration(seconds: widget.chosenExercise.restTime);
    _restTimeDisplay = _formatDuration(_selectedRestTime!);
    _selectedBodyweightPercentage = widget.chosenExercise.bodyweightPercentage;
    _bodyweightDisplay = '${_selectedBodyweightPercentage ?? 0}%';
    final selected = await BodyPartService(instance)
            .readAllBodyPartsByExercise(widget.chosenExercise) ??
        [];
    final available = await BodyPartService(instance).readAllBodyParts() ?? [];
    available.removeWhere(
        (part) => selected.any((selectedPart) => selectedPart.id == part.id));
    setState(() {
      _selectedBodyParts = selected;
      _availableBodyParts = available;
    });
  }

  Future<void> _updateExerciseToDatabase() async {
    if (nameController.text.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context).exercisesNameRequired);
      return;
    }
    final instance = JournalDatabase.instance;

    final exercise = Exercise(
      id: widget.chosenExercise.id,
      name: nameController.text,
      date: widget.chosenExercise.date,
      weight: widget.chosenExercise.weight,
      reps: widget.chosenExercise.reps,
      oneRM: widget.chosenExercise.oneRM,
      notes: notesController.text,
      restTime:
          _selectedRestTime?.inSeconds ?? 0, // Zaktualizowany czas przerwy
      bodyweightPercentage: _selectedBodyweightPercentage ??
          0, // Zaktualizowany procent masy ciała
    );

    await ExerciseService(instance).updateExercise(exercise);
    // Dodaj relacje między ćwiczeniem a wybranymi partiami ciała
    final bodyPartService = BodyPartService(instance);
    await bodyPartService.deleteAllBodyPartExerciseRelationsByExercise(exercise);
    for (var bodyPart in _selectedBodyParts) {
      final relation = ExerciseBodyPartRelation(
        exerciseId: widget.chosenExercise.id!,
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
    int selectedMinutes = _selectedRestTime!.inMinutes.remainder(60);
    int selectedSeconds = _selectedRestTime!.inSeconds.remainder(60);

    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                l10n.restTimeTitle,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selectedMinutes.toString().padLeft(2, '0')}:${selectedSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: AppSizing.fontSize2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        l10n.restMinutes(selectedMinutes),
                        style: const TextStyle(fontSize: AppSizing.fontSize2),
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
                        style: const TextStyle(fontSize: AppSizing.fontSize2),
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
    int selectedPercentage = _selectedBodyweightPercentage ?? 0;

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
                    style: const TextStyle(fontSize: AppSizing.fontSize2),
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
        title: Text(l10n.exercisesEditTitle(widget.chosenExercise.name)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
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
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text(l10n.defaultRestTimeLabel),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () {
                    _showTimePickerDialog(context).then((duration) {
                      if (duration != null) {
                        setState(() {
                          _selectedRestTime = duration;
                          _restTimeDisplay =
                              _formatDuration(_selectedRestTime!);
                        });
                      }
                    });
                  },
                  child: Text(
                    style: const TextStyle(
                      fontSize: AppSizing.fontSize3,
                      fontFamily: 'DSEG7',
                    ),
                    _restTimeDisplay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text(l10n.bodyweightLiftedLabel),
                const SizedBox(width: AppSizing.padding2),
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
                      fontSize: AppSizing.fontSize3,
                      fontFamily: 'DSEG7',
                    ),
                    _bodyweightDisplay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
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
            const SizedBox(height: AppSizing.padding2),
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
            const SizedBox(height: AppSizing.padding2),
            ElevatedButton(
              onPressed: _updateExerciseToDatabase,
              child: Text(l10n.exercisesEdit),
            ),
          ],
        ),
      ),
    );
  }
}
