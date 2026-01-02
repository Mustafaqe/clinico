class Visit {
  final String id;
  final String patientId;
  final DateTime visitDate;
  final String? chiefComplaint;
  final String? signsAndSymptoms;
  final String? differentialDiagnosis;
  final String? bloodPressure;
  final int? pulseRate;
  final int? spO2;
  final String? investigation;
  final String? recommendation;
  final String? notes;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.patientId,
    DateTime? visitDate,
    this.chiefComplaint,
    this.signsAndSymptoms,
    this.differentialDiagnosis,
    this.bloodPressure,
    this.pulseRate,
    this.spO2,
    this.investigation,
    this.recommendation,
    this.notes,
    DateTime? createdAt,
  }) : visitDate = visitDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'visitDate': visitDate.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'signsAndSymptoms': signsAndSymptoms,
      'differentialDiagnosis': differentialDiagnosis,
      'bloodPressure': bloodPressure,
      'pulseRate': pulseRate,
      'spO2': spO2,
      'investigation': investigation,
      'recommendation': recommendation,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      visitDate: DateTime.parse(map['visitDate'] as String),
      chiefComplaint: map['chiefComplaint'] as String?,
      signsAndSymptoms: map['signsAndSymptoms'] as String?,
      differentialDiagnosis: map['differentialDiagnosis'] as String?,
      bloodPressure: map['bloodPressure'] as String?,
      pulseRate: map['pulseRate'] as int?,
      spO2: map['spO2'] as int?,
      investigation: map['investigation'] as String?,
      recommendation: map['recommendation'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Visit copyWith({
    String? id,
    String? patientId,
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
    DateTime? createdAt,
  }) {
    return Visit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitDate: visitDate ?? this.visitDate,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      signsAndSymptoms: signsAndSymptoms ?? this.signsAndSymptoms,
      differentialDiagnosis:
          differentialDiagnosis ?? this.differentialDiagnosis,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      pulseRate: pulseRate ?? this.pulseRate,
      spO2: spO2 ?? this.spO2,
      investigation: investigation ?? this.investigation,
      recommendation: recommendation ?? this.recommendation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
