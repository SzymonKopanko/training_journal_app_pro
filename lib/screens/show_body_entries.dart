import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/constants/app_constants.dart';
import 'package:training_journal_app/models/body_entry.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

import 'add_body_entry.dart';
import 'body_entry_chart.dart';
import 'edit_body_entry.dart';

class ShowBodyEntriesScreen extends StatefulWidget {
  const ShowBodyEntriesScreen({super.key});

  @override
  _ShowBodyEntriesScreenState createState() => _ShowBodyEntriesScreenState();
}

class _ShowBodyEntriesScreenState extends State<ShowBodyEntriesScreen> {
  final BodyEntryService _bodyEntryService = BodyEntryService(JournalDatabase.instance);
  late Future<List<BodyEntry>?> _bodyEntriesFuture;

  @override
  void initState() {
    super.initState();
    _loadBodyEntries();
  }

  void _loadBodyEntries() {
    setState(() {
      _bodyEntriesFuture = _bodyEntryService.readAllBodyEntries();
    });
  }

  void _deleteBodyEntry(int id) async {
    await _bodyEntryService.deleteBodyEntry(id);
    _loadBodyEntries(); // Refresh the list after deleting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Entries'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<BodyEntry>?>(
              future: _bodyEntriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading body entries.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No body entries found.'));
                }

                final bodyEntries = snapshot.data!;
                return ListView.builder(
                  itemCount: bodyEntries.length,
                  itemBuilder: (context, index) {
                    final bodyEntry = bodyEntries[index];
                    final formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm').format(bodyEntry.dateTime);
                    return Card(
                      margin: const EdgeInsets.all(AppSizing.padding2),
                      child: ListTile(
                        title: Text('${bodyEntry.weight} kg'),
                        subtitle: Text('Date: $formattedDate'),
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
                                ).then((_) =>
                                    _loadBodyEntries()); // Reload after edit
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Entry'),
                                    content: const Text(
                                        'Are you sure you want to delete this entry?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteBodyEntry(bodyEntry.id!);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Delete'),
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
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizing.padding2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBodyEntryScreen(),
                      ),
                    ).then((_) =>
                        _loadBodyEntries()); // Reload the list after adding
                  },
                  child: const Text('Add New Entry'),
                ),
                const SizedBox(
                  width: AppSizing.padding2,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BodyEntryChartScreen(),
                      ),
                    ).then((_) =>
                        _loadBodyEntries()); // Reload the list after adding
                  },
                  child: const Text('Chart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
