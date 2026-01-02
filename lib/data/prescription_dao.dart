import 'dart:convert';
import '../models/prescription.dart';
import '../services/database_helper.dart';

class PrescriptionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Prescription prescription) async {
    final db = await _dbHelper.database;
    final map = prescription.toMap();
    // Convert medications list to JSON string for storage
    map['medications'] = jsonEncode(
      prescription.medications.map((m) => m.toMap()).toList(),
    );
    return await db.insert('prescriptions', map);
  }

  Future<int> update(Prescription prescription) async {
    final db = await _dbHelper.database;
    final map = prescription.toMap();
    map['medications'] = jsonEncode(
      prescription.medications.map((m) => m.toMap()).toList(),
    );
    return await db.update(
      'prescriptions',
      map,
      where: 'id = ?',
      whereArgs: [prescription.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('prescriptions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Prescription?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromDbMap(maps.first);
  }

  Future<List<Prescription>> getByVisitId(String visitId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prescriptions',
      where: 'visitId = ?',
      whereArgs: [visitId],
      orderBy: 'prescriptionDate DESC',
    );

    return maps.map((map) => _fromDbMap(map)).toList();
  }

  Future<List<Prescription>> getByPatientId(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prescriptions',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'prescriptionDate DESC',
    );

    return maps.map((map) => _fromDbMap(map)).toList();
  }

  Prescription _fromDbMap(Map<String, dynamic> map) {
    final medicationsJson = map['medications'] as String?;
    List<Medication> medications = [];

    if (medicationsJson != null && medicationsJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(medicationsJson);
      medications = decoded
          .map((m) => Medication.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    return Prescription(
      id: map['id'] as String,
      visitId: map['visitId'] as String,
      patientId: map['patientId'] as String,
      prescriptionDate: DateTime.parse(map['prescriptionDate'] as String),
      medications: medications,
      additionalNotes: map['additionalNotes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
