import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../models/entry.dart';
import '../models/set.dart';
import '../services/set_service.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';

class EditEntryScreen extends StatefulWidget {
  final int entryId;

  const EditEntryScreen({Key? key, required this.entryId})
      : super(key: key);

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {

  final List<TextEditingController> _weightsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _repsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _rirControllers = [TextEditingController()];
  final _scrollController = ScrollController();
  List<Set> _sets = [];
  Entry? _entry;
  DateTime _selectedDateTime = DateTime(2000);
  String exerciseName = '';
  int exerciseId = -1;
  double entryMainWeight = -1.0;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    final entry = await EntryService(instance).readEntryById(widget.entryId);
    final exercise = await ExerciseService(instance).readExerciseById(entry.exerciseId);
    final sets = await SetService(instance).readAllSetsByEntry(entry);
    setState(() {
      _entry = entry;
      exerciseName = exercise.name;
      exerciseId = exercise.id!;
      _selectedDateTime = entry.date;
      entryMainWeight = entry.mainWeight;
      _sets = sets;
      for (int i = 1; i < sets.length; i++) {
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
      if (repsState == 0 && index >= _sets.length) {
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
      if ((weightState == 0 && index >= _sets.length)) {
        _showValidationError(context,
            'Both last and current weight values in set ${index + 1} are empty.');
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
    _selectedDateTime = _entry!.date;
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            hintColor: Colors.green,
          ),
          child: child!,
        );
      },
    );
    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

        _updateEntryWithSets();
      }
    }
  }

  void _updateEntryWithSets() async {
    final instance = JournalDatabase.instance;
    final updatedEntry = Entry(
        id: widget.entryId,
        date: _selectedDateTime,
        exerciseId: exerciseId,
        mainWeight: entryMainWeight);
    await EntryService(instance).updateEntry(updatedEntry).then((updatedEntry) {
      _updateSets(instance);
      Navigator.pop(context);
    });
  }

  Future<void> _updateSets(instance) async {
    for (int i = 0; i < _weightsControllers.length; i++) {
      double weight = _weightsControllers[i].text.isNotEmpty
          ? double.parse(_weightsControllers[i].text)
          : _sets[i].weight;
      int reps = _repsControllers[i].text.isNotEmpty
          ? int.parse(_repsControllers[i].text)
          : _sets[i].reps;
      int rir = _rirControllers[i].text.isNotEmpty
          ? int.parse(_rirControllers[i].text)
          : _sets[i].rir;
      double oneRM = SetService(instance).calculateOneRM(weight, reps);
      Set set = Set(
        id: _sets[i].id,
        entryId: _sets[i].entryId,
        exerciseId: _sets[i].exerciseId,
        weight: weight,
        reps: reps,
        rir: rir,
        oneRM: oneRM,
      );
      await SetService(instance).updateSet(set);
    }
    await ExerciseService(instance).updateExerciseOneRM(exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Edit \'$exerciseName\' Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
             child: Text(
                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)}',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 20.0),
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

                    final repsHelperText = (index < _sets.length)
                        ? 'Past: ${_sets[index].reps}'
                        : null;

                    final weightsHelperText = (index < _sets.length)
                        ? 'Past: ${_sets[index].weight}'
                        : null;

                    final rirHelperText = (index < _sets.length)
                        ? (_sets[index].rir > -1
                            ? 'Past: ${_sets[index].rir}'
                            : '?')
                        : null;

                    final repsHintText = (index < _sets.length)
                        ? '${_sets[index].reps}'
                        : 'Reps';

                    final weightsHintText = (index < _sets.length)
                        ? '${_sets[index].weight}'
                        : 'Weight';

                    final rirHintText = (index < _sets.length)
                        ? (_sets[index].rir > -1 ? '${_sets[index].rir}' : '?')
                        : 'RIR';

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
                        Expanded(
                          child: TextFormField(
                            controller: rirController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //labelText: 'RIR ${index + 1}',
                              hintText: rirHintText,
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
                      _showValidationError(
                        context,
                        'Add some sets, what are you trying to save?',
                      );
                    } else{
                      _handleSaveButtonPressed(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Update'),
                ),
                IconButton(
                  onPressed: () {
                    if (_repsControllers.length > 99) {
                      _showValidationError(
                        context,
                        'Way too many sets, please finish this workout or'
                        ' stop playing with the app.',
                      );
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
