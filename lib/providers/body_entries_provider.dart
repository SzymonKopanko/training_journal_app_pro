import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_entry.dart';
import 'database_providers.dart';

class BodyEntriesNotifier extends AsyncNotifier<List<BodyEntry>> {
  @override
  Future<List<BodyEntry>> build() => _load();

  Future<List<BodyEntry>> _load() async {
    final entries =
        await ref.read(bodyEntryServiceProvider).readAllBodyEntries();
    return entries ?? [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> deleteBodyEntry(int id) async {
    await ref.read(bodyEntryServiceProvider).deleteBodyEntry(id);
    await refresh();
  }
}

final bodyEntriesProvider =
    AsyncNotifierProvider<BodyEntriesNotifier, List<BodyEntry>>(
  BodyEntriesNotifier.new,
);
