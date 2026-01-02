import '../models/visit.dart';
import '../services/database_helper.dart';

class VisitDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Visit visit) async {
    final db = await _dbHelper.database;
    return await db.insert('visits', visit.toMap());
  }

  Future<int> update(Visit visit) async {
    final db = await _dbHelper.database;
    return await db.update(
      'visits',
      visit.toMap(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<Visit?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'visits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Visit.fromMap(maps.first);
  }

  Future<List<Visit>> getByPatientId(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'visits',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'visitDate DESC',
    );

    return maps.map((map) => Visit.fromMap(map)).toList();
  }

  Future<List<Visit>> getRecent({int limit = 10}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'visits',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return maps.map((map) => Visit.fromMap(map)).toList();
  }

  Future<int> getCountByPatientId(String patientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM visits WHERE patientId = ?',
      [patientId],
    );
    return result.first['count'] as int;
  }
}
