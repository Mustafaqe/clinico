import '../models/patient.dart';
import '../services/database_helper.dart';

class PatientDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.insert('patients', patient.toMap());
  }

  Future<int> update(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.update(
      'patients',
      patient.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  Future<Patient?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  Future<List<Patient>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      orderBy: 'fullName ASC',
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<List<Patient>> search(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'fullName LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'fullName ASC',
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<List<Patient>> getRecent({int limit = 10}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      orderBy: 'updatedAt DESC',
      limit: limit,
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM patients');
    return result.first['count'] as int;
  }
}
