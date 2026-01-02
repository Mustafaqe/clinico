import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _occupationController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _drugAllergyController;
  late final TextEditingController _parentalRelationshipController;
  late final TextEditingController _pastMedicalHistoryController;
  late final TextEditingController _pastSurgicalHistoryController;
  late final TextEditingController _pastFamilyHistoryController;

  String? _maritalStatus;
  String? _bloodGroup;
  bool _smoking = false;
  bool _alcoholism = false;

  bool get _isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;

    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _occupationController = TextEditingController(text: p?.occupation ?? '');
    _weightController = TextEditingController(
      text: p?.weight?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: p?.height?.toString() ?? '',
    );
    _drugAllergyController = TextEditingController(text: p?.drugAllergy ?? '');
    _parentalRelationshipController = TextEditingController(
      text: p?.parentalRelationship ?? '',
    );
    _pastMedicalHistoryController = TextEditingController(
      text: p?.pastMedicalHistory ?? '',
    );
    _pastSurgicalHistoryController = TextEditingController(
      text: p?.pastSurgicalHistory ?? '',
    );
    _pastFamilyHistoryController = TextEditingController(
      text: p?.pastFamilyHistory ?? '',
    );

    _maritalStatus = p?.maritalStatus;
    _bloodGroup = p?.bloodGroup;
    _smoking = p?.smoking ?? false;
    _alcoholism = p?.alcoholism ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _drugAllergyController.dispose();
    _parentalRelationshipController.dispose();
    _pastMedicalHistoryController.dispose();
    _pastSurgicalHistoryController.dispose();
    _pastFamilyHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Patient' : 'New Patient'),
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
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person_outline),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _maritalStatus,
                      decoration: const InputDecoration(
                        labelText: 'Marital Status',
                        prefixIcon: Icon(Icons.favorite_border),
                      ),
                      items: Patient.maritalStatusOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _maritalStatus = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parentalRelationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Parental Relationship',
                        prefixIcon: Icon(Icons.family_restroom),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'Occupation',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Physical Information Section
              _buildSectionHeader(
                'Physical Information',
                Icons.monitor_weight_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group',
                        prefixIcon: Icon(Icons.bloodtype),
                      ),
                      items: Patient.bloodGroupOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _bloodGroup = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _drugAllergyController,
                decoration: const InputDecoration(
                  labelText: 'Drug Allergies',
                  prefixIcon: Icon(Icons.warning_amber),
                  hintText: 'List any known drug allergies...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSwitchTile(
                      'Smoking',
                      _smoking,
                      (value) => setState(() => _smoking = value),
                      Icons.smoking_rooms,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSwitchTile(
                      'Alcoholism',
                      _alcoholism,
                      (value) => setState(() => _alcoholism = value),
                      Icons.local_bar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Medical History Section
              _buildSectionHeader('Medical History', Icons.history),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pastMedicalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Past Medical History (P.M.H)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pastSurgicalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Past Surgical History (P.S.H)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pastFamilyHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Past Family History (P.F.H)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
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
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Update Patient' : 'Add Patient'),
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

  Widget _buildSwitchTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? AppTheme.warningOrange.withOpacity(0.5)
              : Colors.grey.shade800,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppTheme.warningOrange : Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.warningOrange,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<PatientProvider>();

      if (_isEditing) {
        final updatedPatient = widget.patient!.copyWith(
          fullName: _fullNameController.text,
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          occupation: _occupationController.text.isNotEmpty
              ? _occupationController.text
              : null,
          maritalStatus: _maritalStatus,
          parentalRelationship: _parentalRelationshipController.text.isNotEmpty
              ? _parentalRelationshipController.text
              : null,
          bloodGroup: _bloodGroup,
          weight: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          height: _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)
              : null,
          drugAllergy: _drugAllergyController.text.isNotEmpty
              ? _drugAllergyController.text
              : null,
          smoking: _smoking,
          alcoholism: _alcoholism,
          pastMedicalHistory: _pastMedicalHistoryController.text.isNotEmpty
              ? _pastMedicalHistoryController.text
              : null,
          pastSurgicalHistory: _pastSurgicalHistoryController.text.isNotEmpty
              ? _pastSurgicalHistoryController.text
              : null,
          pastFamilyHistory: _pastFamilyHistoryController.text.isNotEmpty
              ? _pastFamilyHistoryController.text
              : null,
          updatedAt: DateTime.now(),
        );

        await provider.updatePatient(updatedPatient);
        if (mounted) {
          Navigator.pop(context, updatedPatient);
        }
      } else {
        final newPatient = await provider.addPatient(
          fullName: _fullNameController.text,
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          occupation: _occupationController.text.isNotEmpty
              ? _occupationController.text
              : null,
          maritalStatus: _maritalStatus,
          parentalRelationship: _parentalRelationshipController.text.isNotEmpty
              ? _parentalRelationshipController.text
              : null,
          bloodGroup: _bloodGroup,
          weight: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          height: _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)
              : null,
          drugAllergy: _drugAllergyController.text.isNotEmpty
              ? _drugAllergyController.text
              : null,
          smoking: _smoking,
          alcoholism: _alcoholism,
          pastMedicalHistory: _pastMedicalHistoryController.text.isNotEmpty
              ? _pastMedicalHistoryController.text
              : null,
          pastSurgicalHistory: _pastSurgicalHistoryController.text.isNotEmpty
              ? _pastSurgicalHistoryController.text
              : null,
          pastFamilyHistory: _pastFamilyHistoryController.text.isNotEmpty
              ? _pastFamilyHistoryController.text
              : null,
        );

        if (mounted) {
          Navigator.pop(context, newPatient);
        }
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
        title: const Text('Delete Patient'),
        content: Text(
          'Are you sure you want to delete "${widget.patient!.fullName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<PatientProvider>().deletePatient(
                widget.patient!.id,
              );
              if (mounted) {
                Navigator.pop(context);
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
