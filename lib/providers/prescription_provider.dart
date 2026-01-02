import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/prescription_dao.dart';
import '../models/prescription.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionDao _prescriptionDao = PrescriptionDao();
  final Uuid _uuid = const Uuid();

  List<Prescription> _prescriptions = [];
  Prescription? _selectedPrescription;
  bool _isLoading = false;
  String? _currentPatientId;

  List<Prescription> get prescriptions => _prescriptions;
  Prescription? get selectedPrescription => _selectedPrescription;
  bool get isLoading => _isLoading;
  String? get currentPatientId => _currentPatientId;

  Future<void> loadPrescriptionsForPatient(String patientId) async {
    _isLoading = true;
    _currentPatientId = patientId;
    notifyListeners();

    try {
      _prescriptions = await _prescriptionDao.getByPatientId(patientId);
    } catch (e) {
      debugPrint('Error loading prescriptions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPrescriptionsForVisit(String visitId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _prescriptions = await _prescriptionDao.getByVisitId(visitId);
    } catch (e) {
      debugPrint('Error loading prescriptions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearPrescriptions() {
    _prescriptions = [];
    _currentPatientId = null;
    notifyListeners();
  }

  Future<void> selectPrescription(String id) async {
    try {
      _selectedPrescription = await _prescriptionDao.getById(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting prescription: $e');
    }
  }

  void clearSelectedPrescription() {
    _selectedPrescription = null;
    notifyListeners();
  }

  Future<Prescription?> addPrescription({
    required String visitId,
    required String patientId,
    DateTime? prescriptionDate,
    List<Medication> medications = const [],
    String? additionalNotes,
  }) async {
    try {
      final prescription = Prescription(
        id: _uuid.v4(),
        visitId: visitId,
        patientId: patientId,
        prescriptionDate: prescriptionDate,
        medications: medications,
        additionalNotes: additionalNotes,
      );

      await _prescriptionDao.insert(prescription);

      if (_currentPatientId == patientId) {
        await loadPrescriptionsForPatient(patientId);
      }

      return prescription;
    } catch (e) {
      debugPrint('Error adding prescription: $e');
      return null;
    }
  }

  Future<bool> updatePrescription(Prescription prescription) async {
    try {
      await _prescriptionDao.update(prescription);

      if (_currentPatientId == prescription.patientId) {
        await loadPrescriptionsForPatient(prescription.patientId);
      }

      if (_selectedPrescription?.id == prescription.id) {
        _selectedPrescription = prescription;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating prescription: $e');
      return false;
    }
  }

  Future<bool> deletePrescription(String id) async {
    try {
      final prescription = await _prescriptionDao.getById(id);
      await _prescriptionDao.delete(id);

      if (_selectedPrescription?.id == id) {
        _selectedPrescription = null;
      }

      if (prescription != null && _currentPatientId == prescription.patientId) {
        await loadPrescriptionsForPatient(prescription.patientId);
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting prescription: $e');
      return false;
    }
  }
}
