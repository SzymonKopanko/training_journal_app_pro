import 'package:flutter/material.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../models/entry.dart';
import '../models/set.dart';
import '../models/exercise.dart';
import '../services/set_service.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({Key? key}) : super(key: key);

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _mainWeightController = TextEditingController();
  final List<TextEditingController> _weightsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _repsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _rirControllers = [TextEditingController()];
  final _scrollController = ScrollController();
  List<String> exerciseNames = [];
  String? selectedExerciseName;
  int numberOfLastEntry = 0;
  List<Entry> _lastEntries = [];
  double _lastEntryMainWeight = 0;
  List<int> _lastEntryRepetitions = [];
  List<double> _lastEntryWeights = [];
  List<int> _lastEntryRIRs = [];
  DateTime? _selectedDateTime;
  String weightsHintText = 'Weight';

  @override
  void initState() {
    super.initState();
    _loadExerciseNames();
    _initializeControllers();
  }

  Future<void> _loadExerciseNames() async {
    final instance = JournalDatabase.instance;
    final exerciseList = await ExerciseService(instance).readAllExercises();
    if (exerciseList != null) {
      setState(() {
        exerciseNames = exerciseList.map((exercise) => exercise.name).toList();
      });
    }
  }

  void _initializeControllers() async {
    final instance = JournalDatabase.instance;
    numberOfLastEntry = 0;
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
    if (selectedExerciseName != null) {
      _lastEntries = await EntryService(instance).readLastEntriesByExercise(
              await ExerciseService(instance)
                  .readExerciseByName(selectedExerciseName!)) ??
          [];
      if (_lastEntries.isNotEmpty) {
        _lastEntryMainWeight = _lastEntries[numberOfLastEntry].mainWeight;
        _mainWeightController.text = '';
        _lastEntryRepetitions = await SetService(instance)
            .readListOfRepsFromSetsByEntry(_lastEntries[numberOfLastEntry]);
        _lastEntryWeights = await SetService(instance)
            .readListOfWeightsFromSetsByEntry(_lastEntries[numberOfLastEntry]);
        _lastEntryRIRs = await SetService(instance)
            .readListOfRIRsFromSetsByEntry(_lastEntries[numberOfLastEntry]);
        setState(() {
          for (int i = 1; i < _lastEntryRepetitions.length; i++) {
            _repsControllers.add(TextEditingController());
            _weightsControllers.add(TextEditingController());
            _rirControllers.add(TextEditingController());
          }
        });
      }
    }
  }

  void _updateControllersForLastEntryChange() async {
    numberOfLastEntry = (numberOfLastEntry + 1) % _lastEntries.length;
    final instance = JournalDatabase.instance;
    _lastEntryMainWeight = _lastEntries[numberOfLastEntry].mainWeight;
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
    final double weight = double.tryParse(controller) ?? -1.0;
    if (weight < 0) {
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

  bool _canSaveEntry() {
    if (selectedExerciseName == null && _exerciseNameController.text.isEmpty) {
      _showValidationError(
          context,
          'You have to choose a name for the exercise, or choose from'
          ' the list of already created exercises, if you have any.');
      return false;
    }
    if (_exerciseNameController.text.length > 25) {
      _showValidationError(
          context,
          'Your exercise name is too long, please think of something'
          ' shorter, max length is 25 characters.');
      return false;
    }
    if (_exerciseNameController.text == 'New Exercise') {
      _showValidationError(
          context,
          'Please enter a reasonable name for the exercise'
          '(hint: not \'New Exercise\').');
      return false;
    }
    if (!_areValueControllersValid()) {
      return false;
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
    if (_canSaveEntry()) {
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
          ),
          child: child!,
        );
      },
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
    if (selectedExerciseName != null) {
      Exercise exercise = await ExerciseService(instance)
          .readExerciseByName(selectedExerciseName!);
      final newEntry = Entry(
          date: _selectedDateTime!,
          exerciseId: exercise.id!,
          mainWeight: double.tryParse(_mainWeightController.text) as double);
      await EntryService(instance).createEntry(newEntry).then((newEntry) {
        _saveSets(newEntry.id!, exercise.id!, instance);
        Navigator.pop(context);
      });
    } else {
      final exerciseName = _exerciseNameController.text;
      Exercise newExercise = Exercise(
          name: exerciseName,
          date: _selectedDateTime!,
          weight: -1.0,
          reps: -1,
          oneRM: -1);
      await ExerciseService(instance)
          .createExercise(newExercise)
          .then((newExercise) async {
        final newEntry = Entry(
            date: _selectedDateTime!,
            exerciseId: newExercise.id!,
            mainWeight: _mainWeightController.text.isNotEmpty
                ? double.parse(_mainWeightController.text)
                : double.parse(_weightsControllers[0].text));

        await EntryService(instance).createEntry(newEntry).then((newEntry) {
          _saveSets(newEntry.id!, newExercise.id!, instance);
          Navigator.pop(context);
        });
      });
    }
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
      double oneRM = SetService(instance).calculateOneRM(weight, reps);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exerciseNames.isEmpty)
              const Center(
                child: Text(
                  'Add some entries to choose from\n'
                  'previously performed exercises.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: selectedExerciseName,
                onChanged: (value) {
                  setState(() {
                    selectedExerciseName = value;
                    _exerciseNameController.text = value ?? '';
                    _initializeControllers();
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('New Exercise'),
                  ),
                  ...exerciseNames.map((exerciseName) {
                    return DropdownMenuItem<String>(
                      value: exerciseName,
                      child: Text(exerciseName),
                    );
                  }),
                ],
                decoration:
                    const InputDecoration(labelText: 'Select Exercise Name'),
              ),
            if (selectedExerciseName == null)
              TextFormField(
                controller: _exerciseNameController,
                decoration: const InputDecoration(
                  //labelText: 'Exercise Name',
                  hintText: 'Enter name',
                ),
              ),
            TextFormField(
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
                //labelText: 'Default weight',
                hintText: 'Enter main weight',
                helperText:
                    (selectedExerciseName != null && _lastEntryMainWeight > 0.0)
                        ? 'Past: $_lastEntryMainWeight'
                        : null,
              ),
            ),
            const SizedBox(height: 16.0),
            const Center(
                child: Row(
                    children: [
                      SizedBox(width: 60.0),
                      Expanded(child: Text("Reps")),
                      SizedBox(width: 35.0),
                      Expanded(child: Text("Weight")),
                      SizedBox(width: 55.0),
                      Expanded(child: Text("RIR")),
                      SizedBox(width: 50.0)
                    ])
            ),
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

                    final repsHelperText = (selectedExerciseName != null &&
                            _lastEntryRepetitions.isNotEmpty &&
                            index < _lastEntryRepetitions.length)
                        ? 'Past: ${_lastEntryRepetitions[index]}'
                        : null;

                    final weightsHelperText = (selectedExerciseName != null &&
                            _lastEntryWeights.isNotEmpty &&
                            index < _lastEntryWeights.length)
                        ? 'Past: ${_lastEntryWeights[index]}'
                        : null;

                    final rirHelperText = (selectedExerciseName != null &&
                            _lastEntryRIRs.isNotEmpty &&
                            index < _lastEntryRIRs.length)
                        ? (_lastEntryRIRs[index] > -1
                            ? 'Past: ${_lastEntryRIRs[index]}'
                            : '?')
                        : null;

                    final repsHintText = (selectedExerciseName != null &&
                            _lastEntryRepetitions.isNotEmpty &&
                            index < _lastEntryRepetitions.length)
                        ? '${_lastEntryRepetitions[index]}'
                        : 'Reps';

                    return Row(
                      children: [
                        Text('${index + 1}.',
                            style: const TextStyle(
                              fontSize: 20.0
                            ),
                        ),
                        if(index < 9)
                            const SizedBox(width: 16.0),
                        if(index >= 9)
                          const SizedBox(width: 5.0),
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
                        const SizedBox(width: 16.0),
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
                        const SizedBox(width: 20.0),
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
            const SizedBox(height: 16.0),
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
                    backgroundColor: Colors.green,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: _lastEntryRepetitions.isNotEmpty
                        ? Text(
                            'Change Past Entry (${numberOfLastEntry + 1})')
                        : null,
                  ),
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
    _exerciseNameController.dispose();
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
