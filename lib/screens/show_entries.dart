import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../models/set.dart';
import '../services/journal_database.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';
import '../services/set_service.dart';
import '../models/exercise.dart';
import 'edit_entry.dart';

class ShowEntries extends StatefulWidget {
  const ShowEntries({Key? key}) : super(key: key);

  @override
  _ShowEntriesState createState() => _ShowEntriesState();
}

class _ShowEntriesState extends State<ShowEntries> {
  List<Entry> _allEntries = [];
  List<Entry> _allFilteredEntries = [];
  List<String> _exerciseNames = [];
  String? _selectedExerciseName;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadExerciseNames();
  }

  Future<void> _loadEntries() async {
    final instance = JournalDatabase.instance;
    final entries = await EntryService(instance).readAllEntries();
    if (entries != null) {
      setState(() {
        _allEntries = entries;
      });
    }
  }

  Future<void> _loadExerciseNames() async {
    final instance = JournalDatabase.instance;
    final exerciseList = await ExerciseService(instance).readAllExercises();
    if (exerciseList != null) {
      setState(() {
        _exerciseNames = exerciseList.map((exercise) => exercise.name).toList();
      });
    }
  }

  Future<void> _loadEntriesByExercise(String exerciseName) async {
    final instance = JournalDatabase.instance;
    final exercise =
        await ExerciseService(instance).readExerciseByName(exerciseName);
    final entries =
        await EntryService(instance).readAllEntriesByExercise(exercise);
    if (entries != null) {
      setState(() {
        _allFilteredEntries = entries;
        _allEntries = entries;
      });
    } else {
      setState(() {
        _allFilteredEntries = [];
      });
    }
  }

  Future<List<Set>> _loadSetsForEntry(Entry entry) async {
    final instance = JournalDatabase.instance;
    return await SetService(instance).readAllSetsByEntry(entry);
  }

  void _deleteEntry(BuildContext context, int index) async {
    final entryToDelete = _allEntries[index];
    await EntryService(JournalDatabase.instance).deleteEntry(entryToDelete.id!);
    _loadEntries();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry deleted successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_allEntries.isEmpty)
              const Center(
                child: Text(
                  'Add some entries to see\n'
                  'some data here.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedExerciseName,
                onChanged: (value) {
                  setState(() {
                    _selectedExerciseName = value;
                    if (value != null) {
                      _loadEntriesByExercise(value);
                    } else {
                      _loadEntries();
                    }
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Exercises'),
                  ),
                  ..._exerciseNames.map((exerciseName) {
                    return DropdownMenuItem<String>(
                      value: exerciseName,
                      child: Text(exerciseName),
                    );
                  }),
                ],
                decoration: const InputDecoration(labelText: 'Select Exercise'),
              ),
            if (_selectedExerciseName != null && _allFilteredEntries.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Center(
                    child: Text(
                      'Add entries for that exercise'
                      ' to see some data.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _allEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _allEntries[index];
                    return FutureBuilder<List<Set>>(
                      future: _loadSetsForEntry(entry),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final sets = snapshot.data ?? [];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<Exercise>(
                                    future: ExerciseService(
                                            JournalDatabase.instance)
                                        .readExerciseById(entry.exerciseId),
                                    builder: (context, exerciseSnapshot) {
                                      if (exerciseSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (exerciseSnapshot.hasError) {
                                        return Text(
                                            'Error: ${exerciseSnapshot.error}');
                                      } else {
                                        final exercise = exerciseSnapshot.data;
                                        return Text(
                                          exercise?.name ?? 'Unknown Exercise',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.date)}',
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DataTable(
                                      headingRowHeight: 30.0,
                                      dataRowMaxHeight: 25.0,
                                      dataRowMinHeight: 20.0,
                                      horizontalMargin: 6.0,
                                      columnSpacing: 2.0,
                                      columns: const [
                                        DataColumn(label: Text('Sets')),
                                        DataColumn(label: Text('Reps')),
                                        DataColumn(label: Text('Weight')),
                                        DataColumn(label: Text('RIR')),
                                        DataColumn(label: Text('1RM')),
                                      ],
                                      rows: [
                                        for (int i = 0; i < sets.length; i++)
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                RichText(
                                                  text: TextSpan(
                                                    text: (i + 1).toString(),
                                                    style: DefaultTextStyle.of(
                                                            context)
                                                        .style,
                                                    children: const <TextSpan>[
                                                      TextSpan(
                                                        text: '.',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text(
                                                  sets[i].reps.toString())),
                                              DataCell(Text(sets[i]
                                                  .weight
                                                  .toStringAsFixed(2))),
                                              DataCell(
                                                Text(sets[i].rir == -1
                                                    ? '?'
                                                    : sets[i].rir.toString()),
                                              ),
                                              DataCell(Text(sets[i]
                                                  .oneRM
                                                  .toStringAsFixed(2))),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditEntryScreen(
                                                          entryId:
                                                              _allEntries[index]
                                                                  .id!)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          child: const Text('Edit Entry'),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _deleteEntry(context,
                                                index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete Entry'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
