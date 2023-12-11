// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/entry.dart';
// import '../models/set.dart';
// import '../services/journal_database.dart';
// import '../services/entry_service.dart';
// import '../services/exercise_service.dart';
// import '../services/set_service.dart';
// import '../models/exercise.dart';
// import 'edit_entry.dart';
//
// class ShowEntries extends StatefulWidget {
//   const ShowEntries({super.key});
//
//   @override
//   _ShowEntriesState createState() => _ShowEntriesState();
// }
//
// class _ShowEntriesState extends State<ShowEntries> {
//   List<Entry> _allEntries = [];
//   List<List<Set>> _allSets = [];
//   List<Exercise> _allExercises = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final instance = JournalDatabase.instance;
//     final entries = await EntryService(instance).readAllEntries();
//     final exercises = await ExerciseService(instance).readAllExercises();
//     if (entries != null && exercises != null) {
//       setState(() {
//         _allEntries = entries;
//         _allExercises = exercises;
//         _allSets = List.generate(entries.length, (index) => <Set>[]);
//         _loadSetsForEntries();
//       });
//     }
//   }
//
//   Future<void> _loadSetsForEntries() async {
//     final instance = JournalDatabase.instance;
//     for (int i = 0; i < _allEntries.length; i++) {
//       final entry = _allEntries[i];
//       final sets = await SetService(instance).readAllSetsByEntry(entry);
//       setState(() {
//         _allSets[i] = sets;
//       });
//     }
//   }
//
//   String _getExerciseName(int exerciseId) {
//     final exercise =
//         _allExercises.firstWhere((exercise) => exercise.id == exerciseId);
//     return exercise.name;
//   }
//
//   Future<void> _deleteEntry(BuildContext context, int index) async {
//     final entryToDelete = _allEntries[index];
//     debugPrint('\n\nEntry is gonna be DELETED');
//     debugPrint(entryToDelete.toString());
//     await EntryService(JournalDatabase.instance).deleteEntry(entryToDelete.id!);
//     final deletedSets = await SetService(JournalDatabase.instance)
//         .readAllSetsByEntryDebug(entryToDelete);
//     if (deletedSets != null) {
//       debugPrint('Kurwaaaa CASCADE NIE DZIAŁA nie usunęło serii z wpisu');
//       for (final set in deletedSets) {
//         await SetService(JournalDatabase.instance).deleteSet(set.id!);
//       }
//     }
//     await ExerciseService(JournalDatabase.instance)
//         .updateExerciseOneRM(entryToDelete.exerciseId);
//     await _loadData();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Entry deleted successfully'),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('History'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             if (_allEntries.isEmpty)
//               const Center(
//                 child: Text(
//                   'Add some entries to see\n'
//                   'some data here.',
//                   style: TextStyle(color: Colors.black54),
//                 ),
//               )
//             else
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _allEntries.length,
//                   itemBuilder: (context, index) {
//                     final entry = _allEntries[index];
//                     final sets = _allSets[index];
//                     return Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               _getExerciseName(entry.exerciseId),
//                               style: const TextStyle(
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.date)}',
//                             ),
//                             SizedBox(
//                               width: double.infinity,
//                               child: DataTable(
//                                 headingRowHeight: 30.0,
//                                 dataRowMaxHeight: 25.0,
//                                 dataRowMinHeight: 20.0,
//                                 horizontalMargin: 6.0,
//                                 columnSpacing: 2.0,
//                                 columns: const [
//                                   DataColumn(label: Text('Sets')),
//                                   DataColumn(label: Text('Reps')),
//                                   DataColumn(label: Text('Weight')),
//                                   DataColumn(label: Text('RIR')),
//                                   DataColumn(label: Text('1RM')),
//                                 ],
//                                 rows: [
//                                   for (int i = 0; i < sets.length; i++)
//                                     DataRow(
//                                       cells: [
//                                         DataCell(
//                                           RichText(
//                                             text: TextSpan(
//                                               text: (i + 1).toString(),
//                                               style:
//                                                   DefaultTextStyle.of(context)
//                                                       .style,
//                                               children: const <TextSpan>[
//                                                 TextSpan(
//                                                   text: '.',
//                                                   style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(sets[i].reps.toString()),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             sets[i].weight.toStringAsFixed(2),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             sets[i].rir == -1
//                                                 ? '?'
//                                                 : sets[i].rir.toString(),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             sets[i].oneRM.toStringAsFixed(2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: () async {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => EditEntryScreen(
//                                             entryId: _allEntries[index].id!,
//                                           ),
//                                         ),
//                                       ).then((_) => _loadData());
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.black,
//                                     ),
//                                     child: const Text('Edit Entry'),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16.0),
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       _deleteEntry(context, index);
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                       Theme.of(context).brightness !=
//                                                   Brightness.light
//                                               ? const Color.fromARGB(
//                                                   100, 70, 40, 46)
//                                               : const Color.fromARGB(
//                                                   255, 252, 234, 234),
//                                     ),
//                                     child: Text('Delete Entry',
//                                       style: TextStyle(
//                                         color: Theme.of(context).brightness != Brightness.light
//                                             ? const Color.fromARGB(255, 255, 146, 146)
//                                             : const Color.fromARGB(255, 183, 0, 0),
//                                       ),),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
