import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/constants/app_constants.dart';

import '../l10n/app_localizations.dart';
import '../providers/body_entries_provider.dart';
import 'add_body_entry.dart';
import 'body_entry_chart.dart';
import 'edit_body_entry.dart';

class ShowBodyEntriesScreen extends ConsumerStatefulWidget {
  const ShowBodyEntriesScreen({super.key});

  @override
  ConsumerState<ShowBodyEntriesScreen> createState() =>
      _ShowBodyEntriesScreenState();
}

class _ShowBodyEntriesScreenState extends ConsumerState<ShowBodyEntriesScreen> {
  Future<void> _refresh() =>
      ref.read(bodyEntriesProvider.notifier).refresh();

  void _openAddBodyEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBodyEntryScreen()),
    ).then((_) => _refresh());
  }

  void _openChart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BodyEntryChartScreen()),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bodyEntriesAsync = ref.watch(bodyEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bodyEntriesTitle),
        actions: [
          IconButton(
            onPressed: _openChart,
            icon: const Icon(Icons.show_chart),
            tooltip: l10n.chartWord,
          ),
          IconButton(
            onPressed: _openAddBodyEntry,
            icon: const Icon(Icons.add),
            tooltip: l10n.bodyEntriesAddNew,
          ),
        ],
      ),
      body: bodyEntriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.bodyEntriesLoadError)),
        data: (bodyEntries) {
          if (bodyEntries.isEmpty) {
            return Center(child: Text(l10n.bodyEntriesEmpty));
          }
          return ListView.builder(
            itemCount: bodyEntries.length,
            itemBuilder: (context, index) {
              final bodyEntry = bodyEntries[index];
              final formattedDate =
                  DateFormat('yyyy-MM-dd HH:mm').format(bodyEntry.dateTime);
              return Card(
                margin: const EdgeInsets.all(AppSizing.padding2),
                child: ListTile(
                  title: Text(l10n.weightKg(bodyEntry.weight.toString())),
                  subtitle: Text(l10n.labelDate(formattedDate)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBodyEntryScreen(
                                bodyEntry: bodyEntry,
                              ),
                            ),
                          ).then((_) => _refresh());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.bodyEntryDeleteTitle),
                              content: Text(l10n.bodyEntryDeleteBody),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(l10n.commonCancel),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await ref
                                        .read(bodyEntriesProvider.notifier)
                                        .deleteBodyEntry(bodyEntry.id!);
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text(l10n.commonDelete),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
