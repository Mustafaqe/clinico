import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../providers/visit_provider.dart';
import '../theme/app_theme.dart';

class VisitFormScreen extends StatefulWidget {
  final Patient patient;
  final Visit? visit;

  const VisitFormScreen({super.key, required this.patient, this.visit});

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _chiefComplaintController;
  late final TextEditingController _signsAndSymptomsController;
  late final TextEditingController _differentialDiagnosisController;
  late final TextEditingController _bloodPressureController;
  late final TextEditingController _pulseRateController;
  late final TextEditingController _spO2Controller;
  late final TextEditingController _investigationController;
  late final TextEditingController _recommendationController;
  late final TextEditingController _notesController;

  late DateTime _visitDate;

  bool get _isEditing => widget.visit != null;

  @override
  void initState() {
    super.initState();
    final v = widget.visit;

    _visitDate = v?.visitDate ?? DateTime.now();
    _chiefComplaintController = TextEditingController(
      text: v?.chiefComplaint ?? '',
    );
    _signsAndSymptomsController = TextEditingController(
      text: v?.signsAndSymptoms ?? '',
    );
    _differentialDiagnosisController = TextEditingController(
      text: v?.differentialDiagnosis ?? '',
    );
    _bloodPressureController = TextEditingController(
      text: v?.bloodPressure ?? '',
    );
    _pulseRateController = TextEditingController(
      text: v?.pulseRate?.toString() ?? '',
    );
    _spO2Controller = TextEditingController(text: v?.spO2?.toString() ?? '');
    _investigationController = TextEditingController(
      text: v?.investigation ?? '',
    );
    _recommendationController = TextEditingController(
      text: v?.recommendation ?? '',
    );
    _notesController = TextEditingController(text: v?.notes ?? '');
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _signsAndSymptomsController.dispose();
    _differentialDiagnosisController.dispose();
    _bloodPressureController.dispose();
    _pulseRateController.dispose();
    _spO2Controller.dispose();
    _investigationController.dispose();
    _recommendationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Visit' : 'New Visit'),
        actions: [
          if (_isEditing)
            TextButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete, color: AppTheme.errorRed),
              label: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.accentCardDecoration,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.3),
                      child: Text(
                        widget.patient.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (widget.patient.bloodGroup != null)
                            Text(
                              'Blood Group: ${widget.patient.bloodGroup}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Date Picker
                    OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        '${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chief Complaint & Symptoms Section
              _buildSectionHeader(
                'Chief Complaint & Symptoms',
                Icons.description,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chiefComplaintController,
                decoration: const InputDecoration(
                  labelText: 'Chief Complaint (C.C)',
                  hintText: 'What brings the patient in today?',
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signsAndSymptomsController,
                decoration: const InputDecoration(
                  labelText: 'Signs & Symptoms (S&S)',
                  hintText: 'Observable signs and reported symptoms...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _differentialDiagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Differential Diagnosis (D.D)',
                  hintText: 'Possible diagnoses to consider...',
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Vital Signs Section
              _buildSectionHeader('Vital Signs', Icons.monitor_heart),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bloodPressureController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Pressure',
                        hintText: 'e.g., 120/80',
                        prefixIcon: Icon(Icons.favorite),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pulseRateController,
                      decoration: const InputDecoration(
                        labelText: 'Pulse Rate (bpm)',
                        prefixIcon: Icon(Icons.timeline),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _spO2Controller,
                      decoration: const InputDecoration(
                        labelText: 'SpO2 (%)',
                        prefixIcon: Icon(Icons.air),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Investigation & Recommendation Section
              _buildSectionHeader(
                'Investigation & Recommendation',
                Icons.science,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _investigationController,
                decoration: const InputDecoration(
                  labelText: 'Investigation',
                  hintText: 'Tests to order, imaging, lab work...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recommendationController,
                decoration: const InputDecoration(
                  labelText: 'Recommendation',
                  hintText: 'Treatment plan, follow-up instructions...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Notes Section
              _buildSectionHeader('Additional Notes', Icons.note_alt),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional observations or notes...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isEditing ? 'Update Visit' : 'Save Visit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<VisitProvider>();

      if (_isEditing) {
        final updatedVisit = widget.visit!.copyWith(
          visitDate: _visitDate,
          chiefComplaint: _chiefComplaintController.text.isNotEmpty
              ? _chiefComplaintController.text
              : null,
          signsAndSymptoms: _signsAndSymptomsController.text.isNotEmpty
              ? _signsAndSymptomsController.text
              : null,
          differentialDiagnosis:
              _differentialDiagnosisController.text.isNotEmpty
              ? _differentialDiagnosisController.text
              : null,
          bloodPressure: _bloodPressureController.text.isNotEmpty
              ? _bloodPressureController.text
              : null,
          pulseRate: _pulseRateController.text.isNotEmpty
              ? int.tryParse(_pulseRateController.text)
              : null,
          spO2: _spO2Controller.text.isNotEmpty
              ? int.tryParse(_spO2Controller.text)
              : null,
          investigation: _investigationController.text.isNotEmpty
              ? _investigationController.text
              : null,
          recommendation: _recommendationController.text.isNotEmpty
              ? _recommendationController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );

        await provider.updateVisit(updatedVisit);
      } else {
        await provider.addVisit(
          patientId: widget.patient.id,
          visitDate: _visitDate,
          chiefComplaint: _chiefComplaintController.text.isNotEmpty
              ? _chiefComplaintController.text
              : null,
          signsAndSymptoms: _signsAndSymptomsController.text.isNotEmpty
              ? _signsAndSymptomsController.text
              : null,
          differentialDiagnosis:
              _differentialDiagnosisController.text.isNotEmpty
              ? _differentialDiagnosisController.text
              : null,
          bloodPressure: _bloodPressureController.text.isNotEmpty
              ? _bloodPressureController.text
              : null,
          pulseRate: _pulseRateController.text.isNotEmpty
              ? int.tryParse(_pulseRateController.text)
              : null,
          spO2: _spO2Controller.text.isNotEmpty
              ? int.tryParse(_spO2Controller.text)
              : null,
          investigation: _investigationController.text.isNotEmpty
              ? _investigationController.text
              : null,
          recommendation: _recommendationController.text.isNotEmpty
              ? _recommendationController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Visit'),
        content: const Text(
          'Are you sure you want to delete this visit? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<VisitProvider>().deleteVisit(widget.visit!.id);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
