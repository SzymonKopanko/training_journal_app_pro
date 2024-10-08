import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../constants/app_constants.dart';
import '../models/entry.dart';
import '../models/set.dart';
import '../models/exercise.dart';
import '../services/set_service.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';

class AddSpecifiedEntryScreen extends StatefulWidget {
  final Exercise chosenExercise;

  const AddSpecifiedEntryScreen({super.key, required this.chosenExercise});

  @override
  _AddSpecifiedEntryScreenState createState() =>
      _AddSpecifiedEntryScreenState();
}

class _AddSpecifiedEntryScreenState extends State<AddSpecifiedEntryScreen> {
  final TextEditingController _mainWeightController = TextEditingController();
  final List<TextEditingController> _weightsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _repsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _rirControllers = [TextEditingController()];
  final _scrollController = ScrollController();
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

  Duration? _previousDuration;
  Duration? _selectedDuration;
  Timer? _timer;
  String _timerDisplay = '00:00';
  bool _isTimerRunning = false;
  double bodyweight = 0.0;
  int bodyweightPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() async {
    final instance = JournalDatabase.instance;
    final bodyEntry = await BodyEntryService(instance).readLatestBodyEntry();
    bodyweight = bodyEntry!.weight;
    bodyweightPercentage = widget.chosenExercise.bodyweightPercentage;
    _selectedDuration = Duration(seconds: widget.chosenExercise.restTime);
    _timerDisplay = _formatDuration(_selectedDuration!);
    _previousDuration = _selectedDuration;
    _lastEntries = await EntryService(instance)
            .readLastEntriesByExercise(widget.chosenExercise) ?? [];
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
    if (_lastEntries.length > 1) {
      numberOfLastEntry = (numberOfLastEntry + 1) % _lastEntries.length;
      final instance = JournalDatabase.instance;
      _lastEntryMainWeight = _lastEntries[numberOfLastEntry].mainWeight;
      _lastEntryDateTime = _lastEntries[numberOfLastEntry].date;
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
    int mainWeightState = _weightControllerState(_mainWeightController.text);
    if (mainWeightState == 2) {
      _showValidationError(context, 'Invalid main weight value.');
      return false;
    }
    if (mainWeightState == 3) {
      _showValidationError(context, 'Too big main weight value.');
      return false;
    }
    for (int index = 0; index < _repsControllers.length; index++) {
      int repsState = _repControllerState(_repsControllers[index].text);
      int weightState = _weightControllerState(_weightsControllers[index].text);
      int rirState = _repControllerState(_rirControllers[index].text);

      if (repsState == 2) {
        _showValidationError(
            context, 'Invalid reps value in set ${index + 1}).');
        return false;
      }
      if (repsState == 3) {
        _showValidationError(
            context, 'Too many reps value in set ${index + 1}.');
        return false;
      }
      if (repsState == 0 && index >= _lastEntryRepetitions.length) {
        _showValidationError(
            context,
            'Empty reps controller and no historical '
            'set available at set ${index + 1} in chosen historical entry.');
        return false;
      }

      if (weightState == 2) {
        _showValidationError(
            context, 'Invalid weight value in set ${index + 1}.');
        return false;
      }
      if (weightState == 3) {
        _showValidationError(
            context, 'Too big weight value in set ${index + 1}.');
        return false;
      }
      if ((weightState == 0 && mainWeightState == 0)) {
        _showValidationError(context,
            'Both main weight value and weight value in set ${index + 1} are empty.');
        return false;
      }

      if (rirState == 2) {
        _showValidationError(context, 'Invalid RIR value in set ${index + 1}.');
        return false;
      }
      if (rirState == 3) {
        _showValidationError(context, 'Too big RIR value in set ${index + 1}.');
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
      locale: const Locale('en', 'GB'),
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

  void _saveEntryWithSets() async {
    final instance = JournalDatabase.instance;
    Exercise exercise = widget.chosenExercise;
    final newEntry = Entry(
        date: _selectedDateTime!,
        exerciseId: exercise.id!,
        mainWeight: _mainWeightController.text.isNotEmpty
            ? double.parse(_mainWeightController.text)
            : double.parse(_weightsControllers[0].text),
        bodyweight: bodyweight);
    await EntryService(instance).createEntry(newEntry).then((newEntry) async {
      await _saveSets(newEntry.id!, exercise.id!, instance);
      Navigator.pop(context);
    });
  }

  Future<void> _saveSets(int entryId, int exerciseId, instance) async {
    for (int i = 0; i < _weightsControllers.length; i++) {
      double weight = _weightsControllers[i].text.isNotEmpty
          ? double.parse(_weightsControllers[i].text)
          : double.parse(_mainWeightController.text);
      int reps = _repsControllers[i].text.isNotEmpty
          ? int.parse(_repsControllers[i].text)
          : _lastEntryRepetitions[i];
      int rir = _rirControllers[i].text.isNotEmpty
          ? int.parse(_rirControllers[i].text)
          : -1;
      double oneRM = SetService(instance).calculateOneRM(weight, bodyweight * bodyweightPercentage / 100, reps);
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
    int selectedMinutes = _selectedDuration!.inMinutes.remainder(60);
    int selectedSeconds = _selectedDuration!.inSeconds.remainder(60);


    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selectedMinutes.toString().padLeft(2, '0')}:${selectedSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: AppSizing.fontSize2),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text('Minutes: $selectedMinutes',
                          style: const TextStyle(fontSize: AppSizing.fontSize2)),
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
                          style: const TextStyle(fontSize: AppSizing.fontSize2)),
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
                    Navigator.of(context)
                        .pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(Duration(
                        minutes: selectedMinutes, seconds: selectedSeconds));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Timer ended!')));
    setState(() {
      _selectedDuration = _previousDuration;
      _timerDisplay = _formatDuration(_previousDuration!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add \'${widget.chosenExercise.name}\' Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chosenExercise.notes.isNotEmpty)
              Text(
                'Notes: ${widget.chosenExercise.notes}',
                style: const TextStyle(
                  fontSize: AppSizing.fontSize2,
                  fontWeight: FontWeight.bold,
                ),
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
                          : 'Weight';
                      weightsHintText = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Default weight',
                    hintText: 'Enter default weight',
                    helperText: (_lastEntryMainWeight > 0.0)
                        ? 'Past: $_lastEntryMainWeight'
                        : null,
                  ),
                )),
                const SizedBox(width: AppSizing.padding2),
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
                const SizedBox(width: AppSizing.padding2),
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
                      child: Text(style: const TextStyle(fontSize: AppSizing.fontSize3,
                        fontFamily: 'DSEG7',),
                          _timerDisplay),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding2),
            const Center(
                child: Row(children: [
              SizedBox(width: AppSizing.boxSize1),
              Expanded(child: Text("Reps")),
              SizedBox(width: AppSizing.boxSize2),
              Expanded(child: Text("Weight")),
              SizedBox(width: AppSizing.boxSize3),
              Expanded(child: Text("RIR")),
              SizedBox(width: AppSizing.boxSize4)
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
                        ? 'Past: ${_lastEntryRepetitions[index]}'
                        : null;

                    final weightsHelperText = (_lastEntryWeights.isNotEmpty &&
                            index < _lastEntryWeights.length)
                        ? 'Past: ${_lastEntryWeights[index]}'
                        : null;

                    final rirHelperText = (_lastEntryRIRs.isNotEmpty &&
                            index < _lastEntryRIRs.length)
                        ? (_lastEntryRIRs[index] > -1
                            ? 'Past: ${_lastEntryRIRs[index]}'
                            : '?')
                        : null;

                    final repsHintText = (_lastEntryRepetitions.isNotEmpty &&
                            index < _lastEntryRepetitions.length)
                        ? '${_lastEntryRepetitions[index]}'
                        : 'Reps';

                    return Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(fontSize: AppSizing.fontSize2),
                        ),
                        if (index < 9)
                          const SizedBox(width: AppSizing.padding2),
                        if (index >= 9)
                          const SizedBox(width: AppSizing.padding6),
                        Expanded(
                          child: TextFormField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //labelText: 'Reps ${index + 1}',
                              hintText: repsHintText,
                              helperText: repsHelperText,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizing.padding2),
                        Expanded(
                          child: TextFormField(
                            controller: weightsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //labelText: 'Weight ${index + 1}',
                              hintText: weightsHintText,
                              helperText: weightsHelperText,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizing.padding2),
                        Expanded(
                          child: TextFormField(
                            controller: rirController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //labelText: 'RIR ${index + 1}',
                              hintText: 'RIR',
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
            const SizedBox(height: AppSizing.padding2),
            Visibility(
              visible: _lastEntries.isNotEmpty,
              child: Center(
                child: _lastEntries.isNotEmpty
                    ? Text(
                        'Hint Date: ${DateFormat('EEEE, dd.MM.yyyy, HH:mm').format(_lastEntryDateTime!)}')
                    : null,
              ),
            ),
            Visibility(
              visible: _lastEntries.isNotEmpty,
              child: const SizedBox(height: AppSizing.padding4),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_repsControllers.isEmpty) {
                      _showValidationError(context,
                          'Add some sets, what are you trying to save?');
                    } else {
                      _handleSaveButtonPressed(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSizing.padding7),
                  ),
                  child: const Text('Save'),
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
                      child: Text(
                          'Change Past Entry Hint (${numberOfLastEntry + 1}.)')),
                ),
                IconButton(
                  onPressed: () {
                    if (_repsControllers.length > 99) {
                      _showValidationError(
                          context,
                          'Way too many sets, please finish this workout or'
                          ' stop playing with the app.');
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
