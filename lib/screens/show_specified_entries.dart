import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../services/entry_service.dart';
import '../services/journal_database.dart';
import '../services/set_service.dart';
import 'chart_screen.dart';
import 'edit_entry.dart';

class ShowSpecifiedEntries extends StatefulWidget {
  final Exercise chosenExercise;

  const ShowSpecifiedEntries({super.key, required this.chosenExercise});

  @override
  _ShowSpecifiedEntriesState createState() => _ShowSpecifiedEntriesState();
}

class _ShowSpecifiedEntriesState extends State<ShowSpecifiedEntries> {
  List<Entry> _allEntries = [];
  List<List<Set>> _allSets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final instance = JournalDatabase.instance;
    final entries = await EntryService(instance)
        .readAllEntriesByExercise(widget.chosenExercise);
    if (entries != null) {
      setState(() {
        _allEntries = entries;
        _allSets = List.generate(entries.length, (index) => <Set>[]);
        _loadSetsForEntries();
      });
    } else {
      setState(() {
        _allEntries = [];
        _allSets = [];
      });
    }
  }

  Future<void> _loadSetsForEntries() async {
    final instance = JournalDatabase.instance;
    for (int i = 0; i < _allEntries.length; i++) {
      final entry = _allEntries[i];
      final sets = await SetService(instance).readAllSetsByEntry(entry);
      setState(() {
        _allSets[i] = sets;
      });
    }
  }

  void _deleteEntry(BuildContext context, int index) async {
    final entryToDelete = _allEntries[index];
    await EntryService(JournalDatabase.instance).deleteEntry(entryToDelete.id!);
    _loadData();
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
        title: Text('\'${widget.chosenExercise.name}\' History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizing.padding2),
        child: Column(
          children: [
            if (_allEntries.isEmpty)
              const Expanded(
                  child: Center(
                child: Text(
                  'Add some entries to see '
                  'some data here.',
                ),
              ))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _allEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _allEntries[index];
                    final sets = _allSets[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizing.padding3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd.MM.yyyy, HH:mm')
                                  .format(entry.date),
                              style: const TextStyle(
                                  fontSize: AppSizing.fontSize3,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                headingRowHeight: AppSizing.headingRowH,
                                dataRowMaxHeight: AppSizing.dataRowMaxH,
                                dataRowMinHeight: AppSizing.dataRowMinH,
                                horizontalMargin: AppSizing.padding5,
                                columnSpacing: AppSizing.dataRowSpace,
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
                                              style:
                                                  DefaultTextStyle.of(context)
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
                                        DataCell(
                                          Text(sets[i].reps.toString()),
                                        ),
                                        DataCell(
                                          Text(
                                            sets[i].weight.toStringAsFixed(2),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            sets[i].rir == -1
                                                ? '?'
                                                : sets[i].rir.toString(),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            sets[i].oneRM.toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Tooltip(
                                    message: "Edit Entry",
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditEntryScreen(
                                              entryId: _allEntries[index].id!,
                                            ),
                                          ),
                                        ).then((_) {
                                          _loadData();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            MediaQuery.platformBrightnessOf(
                                                        super.context) ==
                                                    Brightness.light
                                                ? AppColors.brightButt
                                                : AppColors.darkButt,
                                      ),
                                      child: const Icon(Icons.edit),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizing.padding2),
                                Expanded(
                                  child: Tooltip(
                                    message: "Delete Entry",
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _deleteEntry(context, index);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).brightness !=
                                                    Brightness.light
                                                ? AppColors.darkErrButt
                                                : AppColors.brightErrButt,
                                      ),
                                      child: Icon(Icons.delete,
                                          color:
                                              MediaQuery.platformBrightnessOf(
                                                          super.context) !=
                                                      Brightness.light
                                                  ? AppColors.darkErrTxt
                                                  : AppColors.brightErrTxt),
                                    ),
                                  ),
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
            if (_allEntries.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExerciseChartScreen(
                            exercise: widget.chosenExercise)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: AppSizing.buttonSize1,
                ),
                child: const Text(
                  'Show Chart',
                  style: TextStyle(
                    fontSize: AppSizing.fontSize3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
