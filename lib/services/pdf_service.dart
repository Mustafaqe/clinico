import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/visit.dart';

class PdfService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> printPrescription({
    required Patient patient,
    required Visit visit,
    required Prescription prescription,
    String? clinicName,
    String? doctorName,
  }) async {
    final pdf = await _generatePrescriptionPdf(
      patient: patient,
      visit: visit,
      prescription: prescription,
      clinicName: clinicName,
      doctorName: doctorName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> sharePrescription({
    required Patient patient,
    required Visit visit,
    required Prescription prescription,
    String? clinicName,
    String? doctorName,
  }) async {
    final pdf = await _generatePrescriptionPdf(
      patient: patient,
      visit: visit,
      prescription: prescription,
      clinicName: clinicName,
      doctorName: doctorName,
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'prescription_${patient.fullName}_${_dateFormat.format(prescription.prescriptionDate)}.pdf',
    );
  }

  Future<pw.Document> _generatePrescriptionPdf({
    required Patient patient,
    required Visit visit,
    required Prescription prescription,
    String? clinicName,
    String? doctorName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(clinicName, doctorName),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),

              // Patient Info
              _buildPatientInfo(patient),
              pw.SizedBox(height: 15),

              // Visit Info
              _buildVisitInfo(visit),
              pw.SizedBox(height: 20),

              // Prescription Header
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PRESCRIPTION',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'Date: ${_dateFormat.format(prescription.prescriptionDate)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Medications
              _buildMedicationsList(prescription.medications),
              pw.SizedBox(height: 20),

              // Notes
              if (prescription.additionalNotes != null &&
                  prescription.additionalNotes!.isNotEmpty)
                _buildNotes(prescription.additionalNotes!),

              pw.Spacer(),

              // Footer
              _buildFooter(doctorName),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(String? clinicName, String? doctorName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          clinicName ?? 'Medical Clinic',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        if (doctorName != null)
          pw.Text(
            'Dr. $doctorName',
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
      ],
    );
  }

  pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _infoRow('Name', patient.fullName)),
              pw.Expanded(child: _infoRow('Phone', patient.phone ?? 'N/A')),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: _infoRow('Blood Group', patient.bloodGroup ?? 'N/A'),
              ),
              pw.Expanded(
                child: _infoRow(
                  'Allergies',
                  patient.drugAllergy ?? 'None reported',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildVisitInfo(Visit visit) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Clinical Notes',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          if (visit.chiefComplaint != null)
            _infoRow('Chief Complaint', visit.chiefComplaint!),
          if (visit.differentialDiagnosis != null) ...[
            pw.SizedBox(height: 4),
            _infoRow('Diagnosis', visit.differentialDiagnosis!),
          ],
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (visit.bloodPressure != null)
                pw.Expanded(child: _infoRow('BP', visit.bloodPressure!)),
              if (visit.pulseRate != null)
                pw.Expanded(child: _infoRow('Pulse', '${visit.pulseRate} bpm')),
              if (visit.spO2 != null)
                pw.Expanded(child: _infoRow('SpO2', '${visit.spO2}%')),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationsList(List<Medication> medications) {
    if (medications.isEmpty) {
      return pw.Text(
        'No medications prescribed.',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _tableCell('#', isHeader: true),
            _tableCell('Medication', isHeader: true),
            _tableCell('Dosage', isHeader: true),
            _tableCell('Frequency', isHeader: true),
            _tableCell('Duration', isHeader: true),
          ],
        ),
        // Data rows
        ...medications.asMap().entries.map((entry) {
          final idx = entry.key;
          final med = entry.value;
          return pw.TableRow(
            children: [
              _tableCell('${idx + 1}'),
              _tableCell(med.name),
              _tableCell(med.dosage ?? '-'),
              _tableCell(med.frequency ?? '-'),
              _tableCell(med.duration ?? '-'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColors.yellow200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Additional Notes',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String? doctorName) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 150,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  doctorName != null
                      ? 'Dr. $doctorName'
                      : 'Doctor\'s Signature',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
