import 'package:flutter/material.dart';
import 'package:training_journal_app/models/exercise.dart';
import 'package:training_journal_app/services/body_part_service.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import '../constants/app_constants.dart';
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
    final selected = await BodyPartService(instance).readAllBodyPartsByExercise(widget.chosenExercise) ?? [];
    final available = await BodyPartService(instance).readAllBodyParts() ?? [];
    available.removeWhere((part) => selected.any((selectedPart) => selectedPart.id == part.id));
    setState(() {
      _selectedBodyParts = selected;
      _availableBodyParts = available;
    });
  }

  Future<void> _updateExerciseToDatabase() async {
    // Walidacja: sprawdzenie, czy nazwa ćwiczenia nie jest pusta
    if (nameController.text.isEmpty) {
      _showErrorDialog('Please enter an exercise name.');
      return;
    }
    final instance = JournalDatabase.instance;
    final exerciseService = ExerciseService(instance);

    final exercise = Exercise(
      id: widget.chosenExercise.id,
      name: nameController.text,
      date: widget.chosenExercise.date,
      weight: widget.chosenExercise.weight,
      reps: widget.chosenExercise.reps,
      oneRM: widget.chosenExercise.oneRM,
      notes: notesController.text,
      restTime: _selectedRestTime?.inSeconds ?? 0,  // Zaktualizowany czas przerwy
      bodyweightPercentage: _selectedBodyweightPercentage ?? 0,  // Zaktualizowany procent masy ciała
    );

    await ExerciseService(instance).updateExercise(exercise);

    // Dodaj relacje między ćwiczeniem a wybranymi partiami ciała
    final bodyPartService = BodyPartService(instance);
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
    int selectedMinutes = _selectedRestTime!.inMinutes.remainder(60);
    int selectedSeconds = _selectedRestTime!.inSeconds.remainder(60);

    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Rest Time',
                textAlign: TextAlign.center,),
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
                      Text('Minutes: $selectedMinutes',
                          style: const TextStyle(fontSize: AppSizing.fontSize2),
                        textAlign: TextAlign.center,),
                      Slider(
                        value: selectedMinutes.toDouble(),
                        min: 0,
                        max: 15,
                        divisions: 15,
                        label: '$selectedMinutes minutes',
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
                      Text('Seconds: $selectedSeconds',
                          style: const TextStyle(fontSize: AppSizing.fontSize2),
                        textAlign: TextAlign.center,),
                      Slider(
                        value: selectedSeconds.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        label: '$selectedSeconds seconds',
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      Duration(minutes: selectedMinutes, seconds: selectedSeconds),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<int?> _showBodyweightPercentageDialog(BuildContext context) async {
    int selectedPercentage = _selectedBodyweightPercentage ?? 0;

    return await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Bodyweight Percentage'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedPercentage);
                  },
                  child: const Text('OK'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit \'${widget.chosenExercise.name}\' Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text('Default Rest Time:'),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () {
                    _showTimePickerDialog(context).then((duration) {
                      if (duration != null) {
                        setState(() {
                          _selectedRestTime = duration;
                          _restTimeDisplay = _formatDuration(_selectedRestTime!);
                        });
                      }
                    });
                  },
                  child: Text(
                    style: const TextStyle(fontSize: AppSizing.fontSize3,
                      fontFamily: 'DSEG7',),
                    _restTimeDisplay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            Row(
              children: [
                Text('Bodyweight Lifted:'),
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
                    style: const TextStyle(fontSize: AppSizing.fontSize3,
                      fontFamily: 'DSEG7',),
                    _bodyweightDisplay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            const Text('Selected Body Parts:'),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedBodyParts.length,
                itemBuilder: (context, index) {
                  final bodyPart = _selectedBodyParts[index];
                  return ListTile(
                    title: Text(bodyPart.name),
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
            const Text('Available Body Parts:'),
            Expanded(
              child: ListView.builder(
                itemCount: _availableBodyParts.length,
                itemBuilder: (context, index) {
                  final bodyPart = _availableBodyParts[index];
                  return ListTile(
                    title: Text(bodyPart.name),
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
              child: const Text('Edit Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
