import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../theme/app_spacing.dart';
import '../l10n/app_localizations.dart';
import '../models/entry.dart';
import '../models/set.dart';
import '../models/exercise.dart';
import '../models/training_with_exercises.dart';
import '../services/set_service.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';

class AddEntryScreen extends StatefulWidget {
  final TrainingWithExercises chosenTrainingWithExercises;

  const AddEntryScreen({super.key, required this.chosenTrainingWithExercises});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _mainWeightController = TextEditingController();
  final List<TextEditingController> _weightsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _repsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _rirControllers = [TextEditingController()];
  final _scrollController = ScrollController();
  Exercise? selectedExercise;
  int numberOfLastEntry = 0;
  List<Entry> _lastEntries = [];
  double _lastEntryMainWeight = 0;
  List<int> _lastEntryRepetitions = [];
  List<double> _lastEntryWeights = [];
  List<int> _lastEntryRIRs = [];
  DateTime? _lastEntryDateTime;
  DateTime? _selectedDateTime;
  String weightsHintText = 'Weight';
  String exerciseNotes = '';

  Duration? _selectedDuration;
  Duration? _previousDuration;
  Timer? _timer;
  String _timerDisplay = '00:00';
  bool _isTimerRunning = false;
  double bodyweight = 0.0;
  int bodyweightPercentage = 0;

  @override
  void initState() {
    super.initState();
    _setFirstExercise();
    _initializeControllers();
  }

  Future<void> _updateExerciseList() async {
    setState(() {
      widget.chosenTrainingWithExercises.exercises.remove(selectedExercise);
    });
  }


  Future<void> _setFirstExercise() async {
    setState(() {
      selectedExercise = widget.chosenTrainingWithExercises.exercises[0];
    });
  }

  void _initializeControllers() async {
    final instance = JournalDatabase.instance;
    final bodyEntry = await BodyEntryService(instance).readLatestBodyEntry();
    if(bodyEntry != null){
      bodyweight = bodyEntry.weight;
    }
    bodyweightPercentage = selectedExercise!.bodyweightPercentage;
    _selectedDuration = Duration(seconds: selectedExercise!.restTime);
    _timerDisplay = _formatDuration(_selectedDuration!);
    _previousDuration = _selectedDuration;
    numberOfLastEntry = 0;
    weightsHintText = 'Weight';
    _lastEntries = [];
    _lastEntryMainWeight = 0;
    _lastEntryRepetitions = [];
    _lastEntryWeights = [];
    _lastEntryRIRs = [];
    _repsControllers.clear();
    _weightsControllers.clear();
    _rirControllers.clear();
    _repsControllers.add(TextEditingController());
    _weightsControllers.add(TextEditingController());
    _rirControllers.add(TextEditingController());
    exerciseNotes = selectedExercise!.notes;
    _lastEntries = await EntryService(instance)
            .readLastEntriesByExercise(selectedExercise!) ?? [];
    if (_lastEntries.isNotEmpty) {
      _lastEntryMainWeight = _lastEntries[0].mainWeight;
      _lastEntryDateTime = _lastEntries[0].date;
      _mainWeightController.text = _lastEntries[0].mainWeight.toString();
      weightsHintText = _mainWeightController.text;
      _lastEntryRepetitions = await SetService(instance)
          .readListOfRepsFromSetsByEntry(_lastEntries[0]);
      _lastEntryWeights = await SetService(instance)
          .readListOfWeightsFromSetsByEntry(_lastEntries[0]);
      _lastEntryRIRs = await SetService(instance)
          .readListOfRIRsFromSetsByEntry(_lastEntries[0]);
      setState(() {
        for (int i = 1; i < _lastEntryRepetitions.length; i++) {
          _repsControllers.add(TextEditingController());
          _weightsControllers.add(TextEditingController());
          _rirControllers.add(TextEditingController());
        }
      });
    }
  }

  void _updateControllersForLastEntryChange() async {
    numberOfLastEntry = (numberOfLastEntry + 1) % _lastEntries.length;
    final instance = JournalDatabase.instance;
    _lastEntryMainWeight = _lastEntries[numberOfLastEntry].mainWeight;
    _mainWeightController.text = _lastEntries[numberOfLastEntry].mainWeight.toString();
    weightsHintText = _mainWeightController.text;
    _lastEntryRepetitions = await SetService(instance)
        .readListOfRepsFromSetsByEntry(_lastEntries[numberOfLastEntry]);
    _lastEntryWeights = await SetService(instance)
        .readListOfWeightsFromSetsByEntry(_lastEntries[numberOfLastEntry]);
    _lastEntryRIRs = await SetService(instance)
        .readListOfRIRsFromSetsByEntry(_lastEntries[numberOfLastEntry]);

    setState(() {
      for (int i = _repsControllers.length;
          i < _lastEntryRepetitions.length;
          i++) {
        _repsControllers.add(TextEditingController());
        _weightsControllers.add(TextEditingController());
        _rirControllers.add(TextEditingController());
      }
    });
  }

  int _weightControllerState(String controller) {
    if (controller.isEmpty) {
      return 0;
    }
    final double weight = double.tryParse(controller) ?? -10000.0;
    if (weight < -bodyweight) {
      return 2;
    }
    if (weight >= 10000) {
      return 3;
    }
    return 1;
  }

  int _repControllerState(String controller) {
    if (controller.isEmpty) {
      return 0;
    }
    final int state = int.tryParse(controller) ?? -1;
    if (state < 0) {
      return 2;
    }
    if (state >= 10000) {
      return 3;
    }
    return 1;
  }

  bool _areValueControllersValid() {
    final l10n = AppLocalizations.of(context);
    int mainWeightState = _weightControllerState(_mainWeightController.text);
    if (mainWeightState == 2) {
      _showValidationError(context, l10n.valInvalidMainWeight);
      return false;
    }
    if (mainWeightState == 3) {
      _showValidationError(context, l10n.valTooBigMainWeight);
      return false;
    }
    for (int index = 0; index < _repsControllers.length; index++) {
      int repsState = _repControllerState(_repsControllers[index].text);
      int weightState = _weightControllerState(_weightsControllers[index].text);
      int rirState = _repControllerState(_rirControllers[index].text);

      if (repsState == 2) {
        _showValidationError(context, l10n.valInvalidReps(index + 1));
        return false;
      }
      if (repsState == 3) {
        _showValidationError(context, l10n.valTooManyReps(index + 1));
        return false;
      }
      if (repsState == 0 && index >= _lastEntryRepetitions.length) {
        _showValidationError(context, l10n.valEmptyReps(index + 1));
        return false;
      }

      if (weightState == 2) {
        _showValidationError(context, l10n.valInvalidWeight(index + 1));
        return false;
      }
      if (weightState == 3) {
        _showValidationError(context, l10n.valTooBigWeight(index + 1));
        return false;
      }
      if ((weightState == 0 && mainWeightState == 0)) {
        _showValidationError(context, l10n.valBothWeightsEmpty(index + 1));
        return false;
      }

      if (rirState == 2) {
        _showValidationError(context, l10n.valInvalidRir(index + 1));
        return false;
      }
      if (rirState == 3) {
        _showValidationError(context, l10n.valTooBigRir(index + 1));
        return false;
      }
    }
    return true;
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSaveButtonPressed(BuildContext context) {
    if (_areValueControllersValid()) {
      _showDateTimeDialog(context);
    }
  }

  void _showDateTimeDialog(BuildContext context) async {
    _selectedDateTime = DateTime.now();
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });

        _saveEntryWithSets();
      }
    }
  }

  Future<void> _saveEntryWithSets() async {
    final instance = JournalDatabase.instance;
    final newEntry = Entry(
        date: _selectedDateTime!,
        exerciseId: selectedExercise!.id!,
        mainWeight: double.tryParse(_mainWeightController.text) as double,
        bodyweight: bodyweight);
    await EntryService(instance).createEntry(newEntry).then((newEntry) async {
      await _saveSets(newEntry.id!, selectedExercise!.id!, instance);
    });
    if (widget.chosenTrainingWithExercises.exercises.length == 1) {
      Navigator.pop(context);
    } else {
      await _updateExerciseList();
      await _setFirstExercise();
      _initializeControllers();
    }
  }

  Future<void> _saveSets(int entryId, int exerciseId, instance) async {
    int i = 0;
    for (i = 0; i < _weightsControllers.length; i++) {
      double weight = _weightsControllers[i].text.isNotEmpty
          ? double.parse(_weightsControllers[i].text)
          : double.parse(_mainWeightController.text);
      int reps = _repsControllers[i].text.isNotEmpty
          ? int.parse(_repsControllers[i].text)
          : _lastEntryRepetitions[i];
      int rir = _rirControllers[i].text.isNotEmpty
          ? int.parse(_rirControllers[i].text)
          : -1;
      double oneRM = SetService(instance).calculateOneRM(weight, bodyweight*bodyweightPercentage/100, reps);
      Set set = Set(
        entryId: entryId,
        exerciseId: exerciseId,
        weight: weight,
        reps: reps,
        rir: rir,
        oneRM: oneRM,
      );
      await SetService(instance).createSet(set);
    }
    await ExerciseService(instance).updateExerciseOneRM(exerciseId);
  }

  Future<Duration?> _showTimePickerDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    int selectedMinutes = _selectedDuration!.inMinutes.remainder(60);
    int selectedSeconds = _selectedDuration!.inSeconds.remainder(60);

    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.selectTimeTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selectedMinutes.toString().padLeft(2, '0')}:${selectedSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(l10n.restMinutes(selectedMinutes),
                          style: const TextStyle(fontSize: 20)),
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
                      Text(l10n.restSeconds(selectedSeconds),
                          style: const TextStyle(fontSize: 20)),
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
                    Navigator.of(context)
                        .pop();
                  },
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(Duration(
                        minutes: selectedMinutes, seconds: selectedSeconds));
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

  void _startTimer() {
    if (_selectedDuration == null || _selectedDuration!.inSeconds == 0) return;

    setState(() {
      _previousDuration = _selectedDuration;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_selectedDuration!.inSeconds > 0) {
          _selectedDuration =
              Duration(seconds: _selectedDuration!.inSeconds - 1);
          _timerDisplay = _formatDuration(_selectedDuration!);
        } else {
          _stopTimer();
          _playAlarm();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _playAlarm() async {
    final audioPlayer = AudioPlayer();
    await audioPlayer.setAsset('assets/rest.wav');
    audioPlayer.play();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).timerEnded)));
    setState(() {
      _selectedDuration = _previousDuration;
      _timerDisplay = _formatDuration(_previousDuration!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.entryAddEntriesTitle(
            widget.chosenTrainingWithExercises.training.name)),
      ),
      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(exerciseNotes.isNotEmpty)
              Text(l10n.labelNotes(exerciseNotes),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
            DropdownButtonFormField<String>(
              value: widget.chosenTrainingWithExercises.exercises[0].name,
              onChanged: (value) async {
                selectedExercise =
                await ExerciseService(JournalDatabase.instance)
                    .readExerciseByName(value!);
                setState(() {
                  _initializeControllers();
                });
              },
              items: [
                ...widget.chosenTrainingWithExercises.exercises.map((exercise) {
                  return DropdownMenuItem<String>(
                    value: exercise.name,
                    child: Text(exercise.name),
                  );
                }),
              ],
              decoration: InputDecoration(labelText: l10n.selectExerciseLabel),
            ),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                      controller: _mainWeightController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          value = (_mainWeightController.text.isNotEmpty)
                              ? _mainWeightController.text
                              : l10n.weightWord;
                          weightsHintText = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: l10n.defaultWeightLabel,
                        hintText: l10n.enterWeightHint,
                        helperText: (_lastEntryMainWeight > 0.0)
                            ? l10n.pastValue(_lastEntryMainWeight.toString())
                            : null,
                      ),
                    )),
                AppSpacing.gapMd,
                ElevatedButton(
                  onPressed: () {
                    if (_isTimerRunning) {
                      _stopTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  child: Icon(
                    _isTimerRunning ? Icons.pause : Icons.play_arrow,  // Pauza i play
                  ),
                ),
                AppSpacing.gapMd,
                // Timer Button
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _stopTimer();
                        _showTimePickerDialog(context).then((duration) {
                          if (duration != null) {
                            setState(() {
                              _selectedDuration = duration;
                              _timerDisplay =
                                  _formatDuration(_selectedDuration!);
                            });
                          }
                        });
                      },
                      child: Text(style: const TextStyle(fontSize: 18,
                        fontFamily: 'DSEG7'),
                          _timerDisplay),
                    )
                  ],
                ),
              ],
            ),
            AppSpacing.gapMd,
            Center(
                child: Row(children: [
                  SizedBox(width: AppSpacing.setColNumber),
                  Expanded(child: Text(l10n.repsWord)),
                  SizedBox(width: AppSpacing.setColReps),
                  Expanded(child: Text(l10n.weightWord)),
                  SizedBox(width: AppSpacing.setColWeight),
                  Expanded(child: Text(l10n.rirWord)),
                  SizedBox(width: AppSpacing.setColRir)
            ])),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _repsControllers.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    final repsController = _repsControllers[index];
                    final weightsController = _weightsControllers[index];
                    final rirController = _rirControllers[index];

                    final repsHelperText = (_lastEntryRepetitions.isNotEmpty &&
                            index < _lastEntryRepetitions.length)
                        ? l10n.pastValue('${_lastEntryRepetitions[index]}')
                        : null;

                    final weightsHelperText = (_lastEntryWeights.isNotEmpty &&
                            index < _lastEntryWeights.length)
                        ? l10n.pastValue('${_lastEntryWeights[index]}')
                        : null;

                    final rirHelperText = (_lastEntryRIRs.isNotEmpty &&
                            index < _lastEntryRIRs.length)
                        ? (_lastEntryRIRs[index] > -1
                            ? l10n.pastValue('${_lastEntryRIRs[index]}')
                            : '?')
                        : null;

                    final repsHintText = (_lastEntryRepetitions.isNotEmpty &&
                            index < _lastEntryRepetitions.length)
                        ? '${_lastEntryRepetitions[index]}'
                        : l10n.repsWord;

                    return Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(fontSize: 20),
                        ),
                        if (index < 9) AppSpacing.gapMd,
                        if (index >= 9) SizedBox(width: AppSpacing.xs + 1),
                        Expanded(
                          child: TextFormField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: repsHintText,
                              helperText: repsHelperText,
                            ),
                          ),
                        ),
                        AppSpacing.gapMd,
                        Expanded(
                          child: TextFormField(
                            controller: weightsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: weightsHintText,
                              helperText: weightsHelperText,
                            ),
                          ),
                        ),
                        AppSpacing.gapMd,
                        Expanded(
                          child: TextFormField(
                            controller: rirController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: l10n.rirWord,
                              helperText: rirHelperText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _repsControllers.removeAt(index);
                              _weightsControllers.removeAt(index);
                              _rirControllers.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            AppSpacing.gapMd,
            Visibility(
              visible: _lastEntries.isNotEmpty,
              child: Center(
                child: _lastEntries.isNotEmpty
                    ? Text(l10n.hintDate(DateFormat('EEEE, dd.MM.yyyy, HH:mm')
                        .format(_lastEntryDateTime!)))
                    : null,
              ),
            ),
            Visibility(
              visible: _lastEntries.isNotEmpty,
              child: AppSpacing.gapSm,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_repsControllers.isEmpty) {
                      _showValidationError(context, l10n.valNoSets);
                    } else {
                      _handleSaveButtonPressed(context);
                    }
                  },
                  child: Text(l10n.commonSave),
                ),
                Visibility(
                  visible: _lastEntries.isNotEmpty,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_lastEntries.isNotEmpty) {
                            _updateControllersForLastEntryChange();
                          }
                        });
                      },
                      child: Text(l10n.changePastHint(numberOfLastEntry + 1))
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_repsControllers.length > 99) {
                      _showValidationError(context, l10n.valTooManySets);
                    } else {
                      setState(() {
                        _repsControllers.add(TextEditingController());
                        _weightsControllers.add(TextEditingController());
                        _rirControllers.add(TextEditingController());
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainWeightController.dispose();
    for (final controller in _weightsControllers) {
      controller.dispose();
    }
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    for (final controller in _rirControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
