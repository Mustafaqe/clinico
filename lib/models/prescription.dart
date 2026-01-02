class Prescription {
  final String id;
  final String visitId;
  final String patientId;
  final DateTime prescriptionDate;
  final List<Medication> medications;
  final String? additionalNotes;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.visitId,
    required this.patientId,
    DateTime? prescriptionDate,
    this.medications = const [],
    this.additionalNotes,
    DateTime? createdAt,
  }) : prescriptionDate = prescriptionDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitId': visitId,
      'patientId': patientId,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      'medications': medications.map((m) => m.toMap()).toList(),
      'additionalNotes': additionalNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] as String,
      visitId: map['visitId'] as String,
      patientId: map['patientId'] as String,
      prescriptionDate: DateTime.parse(map['prescriptionDate'] as String),
      medications:
          (map['medications'] as List<dynamic>?)
              ?.map((m) => Medication.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      additionalNotes: map['additionalNotes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Prescription copyWith({
    String? id,
    String? visitId,
    String? patientId,
    DateTime? prescriptionDate,
    List<Medication>? medications,
    String? additionalNotes,
    DateTime? createdAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      patientId: patientId ?? this.patientId,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      medications: medications ?? this.medications,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Medication {
  final String name;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? instructions;

  Medication({
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'] as String,
      dosage: map['dosage'] as String?,
      frequency: map['frequency'] as String?,
      duration: map['duration'] as String?,
      instructions: map['instructions'] as String?,
    );
  }

  Medication copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return Medication(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  static const List<String> frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 4 hours',
    'Every 6 hours',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Before meals',
    'After meals',
    'At bedtime',
  ];

  static const List<String> durationOptions = [
    '3 days',
    '5 days',
    '7 days',
    '10 days',
    '14 days',
    '21 days',
    '1 month',
    '2 months',
    '3 months',
    'Ongoing',
  ];
}
