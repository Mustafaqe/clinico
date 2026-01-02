import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/patient_dao.dart';
import '../models/patient.dart';

class PatientProvider extends ChangeNotifier {
  final PatientDao _patientDao = PatientDao();
  final Uuid _uuid = const Uuid();

  List<Patient> _patients = [];
  List<Patient> _searchResults = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Patient> get patients => _patients;
  List<Patient> get searchResults => _searchResults;
  Patient? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _patientDao.getAll();
    } catch (e) {
      debugPrint('Error loading patients: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecentPatients({int limit = 10}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _patientDao.getRecent(limit: limit);
    } catch (e) {
      debugPrint('Error loading recent patients: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchPatients(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _patientDao.search(query);
    } catch (e) {
      debugPrint('Error searching patients: $e');
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> selectPatient(String id) async {
    try {
      _selectedPatient = await _patientDao.getById(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting patient: $e');
    }
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    notifyListeners();
  }

  Future<Patient?> addPatient({
    required String fullName,
    String? maritalStatus,
    String? parentalRelationship,
    String? occupation,
    String? bloodGroup,
    double? weight,
    double? height,
    String? drugAllergy,
    bool smoking = false,
    bool alcoholism = false,
    String? phone,
    String? address,
    String? pastMedicalHistory,
    String? pastSurgicalHistory,
    String? pastFamilyHistory,
  }) async {
    try {
      final patient = Patient(
        id: _uuid.v4(),
        fullName: fullName,
        maritalStatus: maritalStatus,
        parentalRelationship: parentalRelationship,
        occupation: occupation,
        bloodGroup: bloodGroup,
        weight: weight,
        height: height,
        drugAllergy: drugAllergy,
        smoking: smoking,
        alcoholism: alcoholism,
        phone: phone,
        address: address,
        pastMedicalHistory: pastMedicalHistory,
        pastSurgicalHistory: pastSurgicalHistory,
        pastFamilyHistory: pastFamilyHistory,
      );

      await _patientDao.insert(patient);
      await loadPatients();
      return patient;
    } catch (e) {
      debugPrint('Error adding patient: $e');
      return null;
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    try {
      await _patientDao.update(patient);
      await loadPatients();
      if (_selectedPatient?.id == patient.id) {
        _selectedPatient = patient;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating patient: $e');
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      await _patientDao.delete(id);
      if (_selectedPatient?.id == id) {
        _selectedPatient = null;
      }
      await loadPatients();
      return true;
    } catch (e) {
      debugPrint('Error deleting patient: $e');
      return false;
    }
  }

  Future<int> getPatientCount() async {
    try {
      return await _patientDao.getCount();
    } catch (e) {
      debugPrint('Error getting patient count: $e');
      return 0;
    }
  }
}
