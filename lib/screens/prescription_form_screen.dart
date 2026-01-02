import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/prescription.dart';
import '../providers/prescription_provider.dart';
import '../providers/visit_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class PrescriptionFormScreen extends StatefulWidget {
  final Patient patient;
  final Visit? visit;
  final Prescription? prescription;
  final bool isViewing;

  const PrescriptionFormScreen({
    super.key,
    required this.patient,
    this.visit,
    this.prescription,
    this.isViewing = false,
  });

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PdfService _pdfService = PdfService();
  bool _isLoading = false;
  bool _isPrinting = false;

  late final TextEditingController _notesController;
  late List<Medication> _medications;
  late DateTime _prescriptionDate;
  Visit? _selectedVisit;

  bool get _isEditing => widget.prescription != null;

  @override
  void initState() {
    super.initState();
    final p = widget.prescription;

    _prescriptionDate = p?.prescriptionDate ?? DateTime.now();
    _notesController = TextEditingController(text: p?.additionalNotes ?? '');
    _medications = p?.medications.toList() ?? [];
    _selectedVisit = widget.visit;

    // Load visits if we need to select one
    if (widget.visit == null && widget.prescription == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VisitProvider>().loadVisitsForPatient(widget.patient.id);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isViewing
              ? 'Prescription'
              : _isEditing
              ? 'Edit Prescription'
              : 'New Prescription',
        ),
        actions: [
          if (widget.isViewing || _isEditing)
            IconButton(
              onPressed: _isPrinting ? null : _printPrescription,
              icon: _isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print),
              tooltip: 'Print Prescription',
            ),
          if (widget.isViewing || _isEditing)
            IconButton(
              onPressed: _sharePrescription,
              icon: const Icon(Icons.share),
              tooltip: 'Share Prescription',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
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
                            backgroundColor: AppTheme.primaryBlue.withOpacity(
                              0.3,
                            ),
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
                                Row(
                                  children: [
                                    if (widget.patient.phone != null)
                                      Text(
                                        widget.patient.phone!,
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (widget.patient.bloodGroup != null) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          widget.patient.bloodGroup!,
                                          style: const TextStyle(
                                            color: AppTheme.errorRed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(_prescriptionDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!widget.isViewing)
                                TextButton(
                                  onPressed: _selectDate,
                                  child: const Text('Change Date'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visit Selection (only for new prescriptions without visit)
                    if (widget.visit == null && !widget.isViewing)
                      Consumer<VisitProvider>(
                        builder: (context, visitProvider, _) {
                          if (visitProvider.visits.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.warningOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.warningOrange.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber,
                                    color: AppTheme.warningOrange,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'No visits found. Please create a visit first.',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                'Select Visit',
                                Icons.calendar_today,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<Visit>(
                                value: _selectedVisit,
                                decoration: const InputDecoration(
                                  labelText: 'Visit',
                                  prefixIcon: Icon(Icons.event),
                                ),
                                items: visitProvider.visits.map((visit) {
                                  return DropdownMenuItem(
                                    value: visit,
                                    child: Text(
                                      '${DateFormat('dd/MM/yyyy').format(visit.visitDate)} - ${visit.chiefComplaint ?? 'No complaint'}',
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedVisit = value);
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a visit';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),

                    // Medications Section
                    _buildSectionHeader('Medications', Icons.medication),
                    const SizedBox(height: 16),

                    if (_medications.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDarkElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 48,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No medications added',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            if (!widget.isViewing) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _addMedication,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Medication'),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...List.generate(_medications.length, (index) {
                            return _buildMedicationCard(
                              _medications[index],
                              index,
                            );
                          }),
                          if (!widget.isViewing)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: OutlinedButton.icon(
                                onPressed: _addMedication,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Medication'),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Additional Notes Section
                    _buildSectionHeader('Additional Notes', Icons.note_alt),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Instructions for the patient...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      readOnly: widget.isViewing,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            if (!widget.isViewing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  border: Border(top: BorderSide(color: Colors.grey.shade800)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEditing ? 'Update' : 'Save Prescription'),
                    ),
                  ],
                ),
              ),
          ],
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
            color: AppTheme.accentTeal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentTeal, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Medication medication, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentTeal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (medication.dosage != null)
                        _buildChip(Icons.medication, medication.dosage!),
                      if (medication.frequency != null)
                        _buildChip(Icons.schedule, medication.frequency!),
                      if (medication.duration != null)
                        _buildChip(Icons.timelapse, medication.duration!),
                    ],
                  ),
                  if (medication.instructions != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      medication.instructions!,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!widget.isViewing) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editMedication(index),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _removeMedication(index),
                tooltip: 'Remove',
                color: AppTheme.errorRed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _prescriptionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _prescriptionDate = picked);
    }
  }

  void _addMedication() {
    _showMedicationDialog();
  }

  void _editMedication(int index) {
    _showMedicationDialog(medication: _medications[index], index: index);
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _showMedicationDialog({Medication? medication, int? index}) {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final dosageController = TextEditingController(
      text: medication?.dosage ?? '',
    );
    final instructionsController = TextEditingController(
      text: medication?.instructions ?? '',
    );
    String? frequency = medication?.frequency;
    String? duration = medication?.duration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            medication == null ? 'Add Medication' : 'Edit Medication',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name *',
                    prefixIcon: Icon(Icons.medication),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    hintText: 'e.g., 500mg, 10ml',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  items: Medication.frequencyOptions
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (value) => setDialogState(() => frequency = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: duration,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    prefixIcon: Icon(Icons.timelapse),
                  ),
                  items: Medication.durationOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) => setDialogState(() => duration = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions',
                    hintText: 'e.g., Take with food',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medication name is required'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                final newMedication = Medication(
                  name: nameController.text,
                  dosage: dosageController.text.isNotEmpty
                      ? dosageController.text
                      : null,
                  frequency: frequency,
                  duration: duration,
                  instructions: instructionsController.text.isNotEmpty
                      ? instructionsController.text
                      : null,
                );

                setState(() {
                  if (index != null) {
                    _medications[index] = newMedication;
                  } else {
                    _medications.add(newMedication);
                  }
                });

                Navigator.pop(context);
              },
              child: Text(medication == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVisit == null &&
        widget.visit == null &&
        widget.prescription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a visit'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one medication'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<PrescriptionProvider>();
      final visitId =
          widget.visit?.id ??
          _selectedVisit?.id ??
          widget.prescription!.visitId;

      if (_isEditing) {
        final updated = widget.prescription!.copyWith(
          prescriptionDate: _prescriptionDate,
          medications: _medications,
          additionalNotes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );
        await provider.updatePrescription(updated);
      } else {
        await provider.addPrescription(
          visitId: visitId,
          patientId: widget.patient.id,
          prescriptionDate: _prescriptionDate,
          medications: _medications,
          additionalNotes: _notesController.text.isNotEmpty
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

  Future<void> _printPrescription() async {
    final prescription = widget.prescription;
    if (prescription == null) return;

    setState(() => _isPrinting = true);

    try {
      // Get visit data
      Visit? visit = widget.visit;
      if (visit == null) {
        visit = await context.read<VisitProvider>().getVisitById(
          prescription.visitId,
        );
      }

      await _pdfService.printPrescription(
        patient: widget.patient,
        visit: visit ?? Visit(id: '', patientId: widget.patient.id),
        prescription: prescription,
        clinicName: 'Medical Clinic',
        doctorName: 'Doctor',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _sharePrescription() async {
    final prescription = widget.prescription;
    if (prescription == null) return;

    try {
      Visit? visit = widget.visit;
      if (visit == null) {
        visit = await context.read<VisitProvider>().getVisitById(
          prescription.visitId,
        );
      }

      await _pdfService.sharePrescription(
        patient: widget.patient,
        visit: visit ?? Visit(id: '', patientId: widget.patient.id),
        prescription: prescription,
        clinicName: 'Medical Clinic',
        doctorName: 'Doctor',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
