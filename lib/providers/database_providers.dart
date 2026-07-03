import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/body_entry_service.dart';
import '../services/body_part_service.dart';
import '../services/data_backup_service.dart';
import '../services/entry_service.dart';
import '../services/exercise_service.dart';
import '../services/journal_database.dart';
import '../services/set_service.dart';
import '../services/training_service.dart';

final journalDatabaseProvider = Provider<JournalDatabase>(
  (ref) => JournalDatabase.instance,
);

final exerciseServiceProvider = Provider<ExerciseService>(
  (ref) => ExerciseService(ref.watch(journalDatabaseProvider)),
);

final trainingServiceProvider = Provider<TrainingService>(
  (ref) => TrainingService(ref.watch(journalDatabaseProvider)),
);

final entryServiceProvider = Provider<EntryService>(
  (ref) => EntryService(ref.watch(journalDatabaseProvider)),
);

final setServiceProvider = Provider<SetService>(
  (ref) => SetService(ref.watch(journalDatabaseProvider)),
);

final bodyPartServiceProvider = Provider<BodyPartService>(
  (ref) => BodyPartService(ref.watch(journalDatabaseProvider)),
);

final bodyEntryServiceProvider = Provider<BodyEntryService>(
  (ref) => BodyEntryService(ref.watch(journalDatabaseProvider)),
);

final dataBackupServiceProvider = Provider<DataBackupService>(
  (ref) => DataBackupService(ref.watch(journalDatabaseProvider)),
);
