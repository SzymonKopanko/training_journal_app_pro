import '../models/body_entry.dart';
import '../services/journal_database.dart';

class BodyEntryService {
  final JournalDatabase _instance;
  BodyEntryService(this._instance);

  //CREATE
  Future<BodyEntry> createBodyEntry(BodyEntry bodyEntry) async {
    final db = await _instance.database;
    final id = await db.insert(body_entries, bodyEntry.toJson());
    return bodyEntry.copy(id: id);
  }

  //READ
  Future<List<BodyEntry>?> readAllBodyEntries() async {
    final db = await _instance.database;
    final result = await db.query(
      body_entries,
      orderBy: '${BodyEntryFields.dateTime} DESC',  // Sortuj po dacie malejąco
    );
    if(result.isNotEmpty){
      return result.map((json) => BodyEntry.fromJson(json)).toList();
    }
    else{
      return null;
    }
  }

  Future<BodyEntry> readBodyEntryById(int id) async {
    final db = await _instance.database;
    final result = await db.query(
      body_entries,
      columns: BodyEntryFields.values,
      where: '${BodyEntryFields.id} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return BodyEntry.fromJson(result.first);
    } else {
      throw Exception('BodyEntry with ID $id not found');
    }
  }

  // **NEW FUNCTION: READ LATEST ENTRY**
  Future<BodyEntry?> readLatestBodyEntry() async {
    final db = await _instance.database;
    final result = await db.query(
      body_entries,
      columns: BodyEntryFields.values,
      orderBy: '${BodyEntryFields.dateTime} DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return BodyEntry.fromJson(result.first);
    } else {
      return BodyEntry(dateTime: DateTime.now(), weight: 0.0);
    }
  }

  //UPDATE
  Future<int> updateBodyEntry(BodyEntry bodyEntry) async {
    final db = await _instance.database;
    return await db.update(
      body_entries,
      bodyEntry.toJson(),
      where: '${BodyEntryFields.id} = ?',
      whereArgs: [bodyEntry.id],
    );
  }

  //DELETE
  Future<int> deleteBodyEntry(int id) async {
    final db = await _instance.database;
    return await db.delete(
      body_entries,
      where: '${BodyEntryFields.id} = ?',
      whereArgs: [id],
    );
  }
}
