import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        final patients = patientProvider.searchQuery.isNotEmpty
            ? patientProvider.searchResults
            : patientProvider.patients;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Patients',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${patients.length} patients',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Search
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  patientProvider.clearSearch();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        patientProvider.searchPatients(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPatient(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Patient'),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.cardDarkElevated),
              child: Row(
                children: [
                  const SizedBox(width: 56), // Avatar space
                  _buildTableHeader('Name', 'name', flex: 2),
                  _buildTableHeader('Phone', 'phone', flex: 1),
                  _buildTableHeader('Blood Group', 'bloodGroup', flex: 1),
                  _buildTableHeader('Occupation', 'occupation', flex: 1),
                  const SizedBox(width: 100), // Actions
                ],
              ),
            ),

            // Patient List
            Expanded(
              child: patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : patients.isEmpty
                  ? _buildEmptyState(patientProvider.searchQuery.isNotEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        return _buildPatientRow(patients[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableHeader(String label, String field, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_sortBy == field) {
              _sortAscending = !_sortAscending;
            } else {
              _sortBy = field;
              _sortAscending = true;
            }
          });
        },
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            if (_sortBy == field)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: AppTheme.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientRow(Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewPatient(patient),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                child: Text(
                  patient.fullName.isNotEmpty
                      ? patient.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (patient.maritalStatus != null)
                      Text(
                        patient.maritalStatus!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),

              // Phone
              Expanded(
                child: Text(
                  patient.phone ?? '-',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),

              // Blood Group
              Expanded(
                child: patient.bloodGroup != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          patient.bloodGroup!,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Text('-', style: TextStyle(color: Colors.grey.shade500)),
              ),

              // Occupation
              Expanded(
                child: Text(
                  patient.occupation ?? '-',
                  style: TextStyle(color: Colors.grey.shade400),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Actions
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => _editPatient(patient),
                      iconSize: 20,
                      color: Colors.grey.shade400,
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'View Details',
                      onPressed: () => _viewPatient(patient),
                      iconSize: 20,
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No patients found' : 'No patients yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Add your first patient to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPatient(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Patient'),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientFormScreen()),
    ).then((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  void _editPatient(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(patient: patient),
      ),
    ).then((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  void _viewPatient(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    ).then((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }
}
