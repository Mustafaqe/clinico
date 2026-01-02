class Patient {
  final String id;
  final String fullName;
  final String? maritalStatus;
  final String? parentalRelationship;
  final String? occupation;
  final String? bloodGroup;
  final double? weight;
  final double? height;
  final String? drugAllergy;
  final bool smoking;
  final bool alcoholism;
  final String? phone;
  final String? address;
  final String? pastMedicalHistory;
  final String? pastSurgicalHistory;
  final String? pastFamilyHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.fullName,
    this.maritalStatus,
    this.parentalRelationship,
    this.occupation,
    this.bloodGroup,
    this.weight,
    this.height,
    this.drugAllergy,
    this.smoking = false,
    this.alcoholism = false,
    this.phone,
    this.address,
    this.pastMedicalHistory,
    this.pastSurgicalHistory,
    this.pastFamilyHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'maritalStatus': maritalStatus,
      'parentalRelationship': parentalRelationship,
      'occupation': occupation,
      'bloodGroup': bloodGroup,
      'weight': weight,
      'height': height,
      'drugAllergy': drugAllergy,
      'smoking': smoking ? 1 : 0,
      'alcoholism': alcoholism ? 1 : 0,
      'phone': phone,
      'address': address,
      'pastMedicalHistory': pastMedicalHistory,
      'pastSurgicalHistory': pastSurgicalHistory,
      'pastFamilyHistory': pastFamilyHistory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      maritalStatus: map['maritalStatus'] as String?,
      parentalRelationship: map['parentalRelationship'] as String?,
      occupation: map['occupation'] as String?,
      bloodGroup: map['bloodGroup'] as String?,
      weight: map['weight'] as double?,
      height: map['height'] as double?,
      drugAllergy: map['drugAllergy'] as String?,
      smoking: (map['smoking'] as int?) == 1,
      alcoholism: (map['alcoholism'] as int?) == 1,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      pastMedicalHistory: map['pastMedicalHistory'] as String?,
      pastSurgicalHistory: map['pastSurgicalHistory'] as String?,
      pastFamilyHistory: map['pastFamilyHistory'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Patient copyWith({
    String? id,
    String? fullName,
    String? maritalStatus,
    String? parentalRelationship,
    String? occupation,
    String? bloodGroup,
    double? weight,
    double? height,
    String? drugAllergy,
    bool? smoking,
    bool? alcoholism,
    String? phone,
    String? address,
    String? pastMedicalHistory,
    String? pastSurgicalHistory,
    String? pastFamilyHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      parentalRelationship: parentalRelationship ?? this.parentalRelationship,
      occupation: occupation ?? this.occupation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      drugAllergy: drugAllergy ?? this.drugAllergy,
      smoking: smoking ?? this.smoking,
      alcoholism: alcoholism ?? this.alcoholism,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      pastMedicalHistory: pastMedicalHistory ?? this.pastMedicalHistory,
      pastSurgicalHistory: pastSurgicalHistory ?? this.pastSurgicalHistory,
      pastFamilyHistory: pastFamilyHistory ?? this.pastFamilyHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const List<String> maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  static const List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
}
