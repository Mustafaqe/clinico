import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/visit_dao.dart';
import '../models/visit.dart';

class VisitProvider extends ChangeNotifier {
  final VisitDao _visitDao = VisitDao();
  final Uuid _uuid = const Uuid();

  List<Visit> _visits = [];
  Visit? _selectedVisit;
  bool _isLoading = false;
  String? _currentPatientId;

  List<Visit> get visits => _visits;
  Visit? get selectedVisit => _selectedVisit;
  bool get isLoading => _isLoading;
  String? get currentPatientId => _currentPatientId;

  Future<void> loadVisitsForPatient(String patientId) async {
    _isLoading = true;
    _currentPatientId = patientId;
    notifyListeners();

    try {
      _visits = await _visitDao.getByPatientId(patientId);
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearVisits() {
    _visits = [];
    _currentPatientId = null;
    notifyListeners();
  }

  Future<void> selectVisit(String id) async {
    try {
      _selectedVisit = await _visitDao.getById(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting visit: $e');
    }
  }

  void clearSelectedVisit() {
    _selectedVisit = null;
    notifyListeners();
  }

  Future<Visit?> addVisit({
    required String patientId,
    DateTime? visitDate,
    String? chiefComplaint,
    String? signsAndSymptoms,
    String? differentialDiagnosis,
    String? bloodPressure,
    int? pulseRate,
    int? spO2,
    String? investigation,
    String? recommendation,
    String? notes,
  }) async {
    try {
      final visit = Visit(
        id: _uuid.v4(),
        patientId: patientId,
        visitDate: visitDate,
        chiefComplaint: chiefComplaint,
        signsAndSymptoms: signsAndSymptoms,
        differentialDiagnosis: differentialDiagnosis,
        bloodPressure: bloodPressure,
        pulseRate: pulseRate,
        spO2: spO2,
        investigation: investigation,
        recommendation: recommendation,
        notes: notes,
      );

      await _visitDao.insert(visit);

      if (_currentPatientId == patientId) {
        await loadVisitsForPatient(patientId);
      }

      return visit;
    } catch (e) {
      debugPrint('Error adding visit: $e');
      return null;
    }
  }

  Future<bool> updateVisit(Visit visit) async {
    try {
      await _visitDao.update(visit);

      if (_currentPatientId == visit.patientId) {
        await loadVisitsForPatient(visit.patientId);
      }

      if (_selectedVisit?.id == visit.id) {
        _selectedVisit = visit;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating visit: $e');
      return false;
    }
  }

  Future<bool> deleteVisit(String id) async {
    try {
      final visit = await _visitDao.getById(id);
      await _visitDao.delete(id);

      if (_selectedVisit?.id == id) {
        _selectedVisit = null;
      }

      if (visit != null && _currentPatientId == visit.patientId) {
        await loadVisitsForPatient(visit.patientId);
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting visit: $e');
      return false;
    }
  }

  Future<int> getVisitCount(String patientId) async {
    try {
      return await _visitDao.getCountByPatientId(patientId);
    } catch (e) {
      debugPrint('Error getting visit count: $e');
      return 0;
    }
  }

  Future<Visit?> getVisitById(String id) async {
    try {
      return await _visitDao.getById(id);
    } catch (e) {
      debugPrint('Error getting visit: $e');
      return null;
    }
  }
}
