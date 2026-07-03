import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../services/entry_service.dart';
import '../services/journal_database.dart';
import '../services/set_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bar_add_action.dart';
import '../widgets/app_card_action_row.dart';
import '../widgets/app_card_icon_button.dart';
import '../widgets/app_list_card.dart';
import 'add_specified_entry.dart';
import 'chart_screen.dart';
import 'edit_entry.dart';

class ShowSpecifiedEntries extends StatefulWidget {
  final Exercise chosenExercise;

  const ShowSpecifiedEntries({super.key, required this.chosenExercise});

  @override
  State<ShowSpecifiedEntries> createState() => _ShowSpecifiedEntriesState();
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

  void _deleteEntry(int index) async {
    final l10n = AppLocalizations.of(context);
    final entryToDelete = _allEntries[index];
    await EntryService(JournalDatabase.instance).deleteEntry(entryToDelete.id!);
    if (!mounted) return;
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.entryDeleted)),
    );
  }

  void _openAddEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSpecifiedEntryScreen(
          chosenExercise: widget.chosenExercise,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _openChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseChartScreen(exercise: widget.chosenExercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.entriesHistoryTitle(widget.chosenExercise.name)),
        actions: [
          if (_allEntries.isNotEmpty)
            IconButton(
              onPressed: _openChart,
              icon: const Icon(Icons.show_chart),
              tooltip: l10n.showChart,
            ),
          AppBarAddAction(
            tooltip: l10n.tooltipAddEntry,
            onPressed: _openAddEntry,
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          children: [
            if (_allEntries.isEmpty)
              Expanded(child: Center(child: Text(l10n.entriesEmpty)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _allEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _allEntries[index];
                    final sets = _allSets[index];
                    return AppListCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd.MM.yyyy, HH:mm')
                                .format(entry.date),
                            style: textTheme.titleMedium,
                          ),
                          AppSpacing.gapSm,
                          SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              headingRowHeight: AppSpacing.dtHeadingRowH,
                              dataRowMaxHeight: AppSpacing.dtDataRowMaxH,
                              dataRowMinHeight: AppSpacing.dtDataRowMinH,
                              horizontalMargin: AppSpacing.dtHorizontalMargin,
                              columnSpacing: AppSpacing.dtColumnSpacing,
                              columns: [
                                DataColumn(label: Text(l10n.setsWord)),
                                DataColumn(label: Text(l10n.repsWord)),
                                DataColumn(label: Text(l10n.weightWord)),
                                DataColumn(label: Text(l10n.rirWord)),
                                DataColumn(label: Text(l10n.oneRmWord)),
                              ],
                              rows: [
                                for (int i = 0; i < sets.length; i++)
                                  DataRow(
                                    cells: [
                                      DataCell(Text('${i + 1}.')),
                                      DataCell(Text(sets[i].reps.toString())),
                                      DataCell(Text(
                                          sets[i].weight.toStringAsFixed(2))),
                                      DataCell(Text(
                                        sets[i].rir == -1
                                            ? '?'
                                            : sets[i].rir.toString(),
                                      )),
                                      DataCell(Text(
                                          sets[i].oneRM.toStringAsFixed(2))),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          AppSpacing.gapSm,
                          AppCardActionRow(
                            children: [
                              AppCardIconButton(
                                icon: Icons.edit,
                                tooltip: l10n.tooltipEditEntry,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEntryScreen(
                                        entryId: _allEntries[index].id!,
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                },
                              ),
                              AppCardIconButton(
                                icon: Icons.delete,
                                tooltip: l10n.tooltipDeleteEntry,
                                destructive: true,
                                onPressed: () => _deleteEntry(index),
                              ),
                            ],
                          ),
                        ],
                      ),
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
