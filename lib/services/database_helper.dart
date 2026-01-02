import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Future<void> initializeFfi() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'clinico.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Patients table
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        maritalStatus TEXT,
        parentalRelationship TEXT,
        occupation TEXT,
        bloodGroup TEXT,
        weight REAL,
        height REAL,
        drugAllergy TEXT,
        smoking INTEGER DEFAULT 0,
        alcoholism INTEGER DEFAULT 0,
        phone TEXT,
        address TEXT,
        pastMedicalHistory TEXT,
        pastSurgicalHistory TEXT,
        pastFamilyHistory TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Visits table
    await db.execute('''
      CREATE TABLE visits (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        visitDate TEXT NOT NULL,
        chiefComplaint TEXT,
        signsAndSymptoms TEXT,
        differentialDiagnosis TEXT,
        bloodPressure TEXT,
        pulseRate INTEGER,
        spO2 INTEGER,
        investigation TEXT,
        recommendation TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Prescriptions table
    await db.execute('''
      CREATE TABLE prescriptions (
        id TEXT PRIMARY KEY,
        visitId TEXT NOT NULL,
        patientId TEXT NOT NULL,
        prescriptionDate TEXT NOT NULL,
        medications TEXT,
        additionalNotes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (visitId) REFERENCES visits (id) ON DELETE CASCADE,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
      'CREATE INDEX idx_patients_fullName ON patients (fullName)',
    );
    await db.execute('CREATE INDEX idx_visits_patientId ON visits (patientId)');
    await db.execute(
      'CREATE INDEX idx_prescriptions_patientId ON prescriptions (patientId)',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
