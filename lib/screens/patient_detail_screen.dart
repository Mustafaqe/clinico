import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/prescription.dart';
import '../providers/visit_provider.dart';
import '../providers/prescription_provider.dart';
import '../theme/app_theme.dart';
import 'patient_form_screen.dart';
import 'visit_form_screen.dart';
import 'prescription_form_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Patient _patient;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().loadVisitsForPatient(_patient.id);
      context.read<PrescriptionProvider>().loadPrescriptionsForPatient(
        _patient.id,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.fullName),
        actions: [
          TextButton.icon(
            onPressed: _editPatient,
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Visits', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Prescriptions', icon: Icon(Icons.medication)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildVisitsTab(),
          _buildPrescriptionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.accentCardDecoration,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.3),
                  child: Text(
                    _patient.fullName.isNotEmpty
                        ? _patient.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_patient.phone != null) ...[
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(_patient.phone!),
                            const SizedBox(width: 16),
                          ],
                          if (_patient.bloodGroup != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _patient.bloodGroup!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information
          _buildSection(
            title: 'Personal Information',
            icon: Icons.person_outline,
            children: [
              _buildInfoRow('Marital Status', _patient.maritalStatus),
              _buildInfoRow(
                'Parental Relationship',
                _patient.parentalRelationship,
              ),
              _buildInfoRow('Occupation', _patient.occupation),
              _buildInfoRow('Address', _patient.address),
            ],
          ),
          const SizedBox(height: 16),

          // Physical Information
          _buildSection(
            title: 'Physical Information',
            icon: Icons.monitor_weight_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      'Weight',
                      _patient.weight != null ? '${_patient.weight} kg' : null,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      'Height',
                      _patient.height != null ? '${_patient.height} cm' : null,
                    ),
                  ),
                ],
              ),
              _buildInfoRow('Blood Group', _patient.bloodGroup),
              _buildInfoRow('Drug Allergies', _patient.drugAllergy),
              Row(
                children: [
                  Expanded(
                    child: _buildBooleanChip(
                      'Smoking',
                      _patient.smoking,
                      AppTheme.warningOrange,
                    ),
                  ),
                  Expanded(
                    child: _buildBooleanChip(
                      'Alcoholism',
                      _patient.alcoholism,
                      AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medical History
          _buildSection(
            title: 'Medical History',
            icon: Icons.history,
            children: [
              _buildExpandableText(
                'Past Medical History (PMH)',
                _patient.pastMedicalHistory,
              ),
              _buildExpandableText(
                'Past Surgical History (PSH)',
                _patient.pastSurgicalHistory,
              ),
              _buildExpandableText(
                'Past Family History (PFH)',
                _patient.pastFamilyHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkElevated,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: TextStyle(
                color: value != null ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanChip(String label, bool value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                color: value ? color : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ?? 'No information recorded',
              style: TextStyle(
                color: value != null ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return Consumer<VisitProvider>(
      builder: (context, visitProvider, _) {
        if (visitProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (visitProvider.visits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 64, color: Colors.grey.shade700),
                const SizedBox(height: 16),
                Text(
                  'No visits recorded',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addVisit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Visit'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: visitProvider.visits.length,
          itemBuilder: (context, index) {
            return _buildVisitCard(visitProvider.visits[index]);
          },
        );
      },
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showVisitDetails(visit),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _dateFormat.format(visit.visitDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editVisit(visit),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.medication_outlined, size: 20),
                        onPressed: () => _addPrescription(visit),
                        tooltip: 'Add Prescription',
                        color: AppTheme.accentTeal,
                      ),
                    ],
                  ),
                ],
              ),
              if (visit.chiefComplaint != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Chief Complaint',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(visit.chiefComplaint!),
              ],
              if (visit.differentialDiagnosis != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Dx: ${visit.differentialDiagnosis}',
                    style: const TextStyle(
                      color: AppTheme.accentTeal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Vitals
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (visit.bloodPressure != null)
                    _buildVitalChip(
                      Icons.favorite,
                      'BP: ${visit.bloodPressure}',
                    ),
                  if (visit.pulseRate != null)
                    _buildVitalChip(
                      Icons.timeline,
                      'Pulse: ${visit.pulseRate}',
                    ),
                  if (visit.spO2 != null)
                    _buildVitalChip(Icons.air, 'SpO2: ${visit.spO2}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return Consumer<PrescriptionProvider>(
      builder: (context, prescriptionProvider, _) {
        if (prescriptionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prescriptionProvider.prescriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey.shade700),
                const SizedBox(height: 16),
                Text(
                  'No prescriptions yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prescriptionProvider.prescriptions.length,
          itemBuilder: (context, index) {
            return _buildPrescriptionCard(
              prescriptionProvider.prescriptions[index],
            );
          },
        );
      },
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPrescriptionDetails(prescription),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medication,
                          size: 16,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _dateFormat.format(prescription.prescriptionDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${prescription.medications.length} medications',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (prescription.medications.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...prescription.medications
                    .take(3)
                    .map(
                      (med) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppTheme.accentTeal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${med.name}${med.dosage != null ? ' (${med.dosage})' : ''}',
                                style: TextStyle(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (prescription.medications.length > 3)
                  Text(
                    '+ ${prescription.medications.length - 3} more',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _editPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(patient: _patient),
      ),
    ).then((updatedPatient) {
      if (updatedPatient != null && updatedPatient is Patient) {
        setState(() => _patient = updatedPatient);
      }
    });
  }

  void _showActionMenu(BuildContext context) {
    _addVisit();
  }

  void _addVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormScreen(patient: _patient),
      ),
    ).then((_) {
      context.read<VisitProvider>().loadVisitsForPatient(_patient.id);
    });
  }

  void _editVisit(Visit visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormScreen(patient: _patient, visit: visit),
      ),
    ).then((_) {
      context.read<VisitProvider>().loadVisitsForPatient(_patient.id);
    });
  }

  void _addPrescription(Visit visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PrescriptionFormScreen(patient: _patient, visit: visit),
      ),
    ).then((_) {
      context.read<PrescriptionProvider>().loadPrescriptionsForPatient(
        _patient.id,
      );
    });
  }

  void _showVisitDetails(Visit visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Visit - ${_dateFormat.format(visit.visitDate)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (visit.chiefComplaint != null)
                _dialogInfoRow('Chief Complaint', visit.chiefComplaint!),
              if (visit.signsAndSymptoms != null)
                _dialogInfoRow('Signs & Symptoms', visit.signsAndSymptoms!),
              if (visit.differentialDiagnosis != null)
                _dialogInfoRow('Diagnosis', visit.differentialDiagnosis!),
              if (visit.bloodPressure != null)
                _dialogInfoRow('Blood Pressure', visit.bloodPressure!),
              if (visit.pulseRate != null)
                _dialogInfoRow('Pulse Rate', '${visit.pulseRate} bpm'),
              if (visit.spO2 != null) _dialogInfoRow('SpO2', '${visit.spO2}%'),
              if (visit.investigation != null)
                _dialogInfoRow('Investigation', visit.investigation!),
              if (visit.recommendation != null)
                _dialogInfoRow('Recommendation', visit.recommendation!),
              if (visit.notes != null) _dialogInfoRow('Notes', visit.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _addPrescription(visit);
            },
            icon: const Icon(Icons.medication),
            label: const Text('Add Prescription'),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  void _showPrescriptionDetails(Prescription prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionFormScreen(
          patient: _patient,
          prescription: prescription,
          isViewing: true,
        ),
      ),
    );
  }
}
