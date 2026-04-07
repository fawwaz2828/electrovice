class TechnicianProfileData {
  const TechnicianProfileData({
    required this.fullName,
    required this.specialty,
    required this.yearsExperience,
    required this.successRate,
    required this.rating,
    required this.completedWindowLabel,
    required this.serviceHistory,
    this.avatarUrl,
    this.description,
    required this.certifications,
    this.address,
  });

  final String fullName;
  final String specialty;
  final int yearsExperience;
  final int successRate;
  final double rating;
  final String completedWindowLabel;
  final String? avatarUrl;
  final String? description;
  final List<String> certifications;
  final String? address;
  final List<TechnicianJobRecord> serviceHistory;

  factory TechnicianProfileData.fromMap(Map<String, dynamic> map) {
    final List<dynamic> history = map['serviceHistory'] as List<dynamic>? ?? [];
    final List<dynamic> certs = map['certifications'] as List<dynamic>? ?? [];

    return TechnicianProfileData(
      fullName: map['fullName'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      yearsExperience: (map['yearsExperience'] as num?)?.toInt() ?? 0,
      successRate: (map['successRate'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedWindowLabel:
          map['completedWindowLabel'] as String? ?? 'LAST 30 DAYS',
      avatarUrl: map['avatarUrl'] as String?,
      description: map['description'] as String?,
      certifications: certs.cast<String>(),
      address: map['address'] as String?,
      serviceHistory: history
          .whereType<Map>()
          .map(
            (item) => TechnicianJobRecord.fromMap(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
    );
  }

  TechnicianProfileData copyWith({
    String? fullName,
    String? specialty,
    int? yearsExperience,
    int? successRate,
    double? rating,
    String? completedWindowLabel,
    String? avatarUrl,
    String? description,
    List<String>? certifications,
    String? address,
    List<TechnicianJobRecord>? serviceHistory,
  }) {
    return TechnicianProfileData(
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      successRate: successRate ?? this.successRate,
      rating: rating ?? this.rating,
      completedWindowLabel: completedWindowLabel ?? this.completedWindowLabel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      certifications: certifications ?? this.certifications,
      address: address ?? this.address,
      serviceHistory: serviceHistory ?? this.serviceHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'specialty': specialty,
      'yearsExperience': yearsExperience,
      'successRate': successRate,
      'rating': rating,
      'completedWindowLabel': completedWindowLabel,
      'avatarUrl': avatarUrl,
      'description': description,
      'certifications': certifications,
      'address': address,
      'serviceHistory': serviceHistory.map((item) => item.toMap()).toList(),
    };
  }

  factory TechnicianProfileData.sample() {
    return const TechnicianProfileData(
      fullName: 'Marcus Chen',
      specialty: 'LAPTOP & MICRO-SOLDERING\nSPECIALIST',
      yearsExperience: 12,
      successRate: 99,
      rating: 4.9,
      completedWindowLabel: 'LAST 30 DAYS',
      description: 'Expert in micro-soldering and complex logic board repairs for laptops and high-end electronics. Certified Apple and Microsoft repair technician with over a decade of experience in Jakarta.',
      certifications: [
        'Apple Certified Support Professional (ACSP)',
        'CompTIA A+ Certification',
        'Microsoft Certified Solutions Associate'
      ],
      address: 'Jl. Sudirman No. 123, Jakarta Selatan',
      serviceHistory: [
        TechnicianJobRecord(
          title: 'Industrial HVAC\nCalibration',
          clientName: 'North Logistics Hub',
          amount: 625,
          rating: 5.0,
          completedDateLabel: 'Completed: Oct 28, 2023',
        ),
        TechnicianJobRecord(
          title: 'Cylinder Head\nResurfacing',
          clientName: 'Jonathan Vance',
          amount: 450,
          rating: 5.0,
          completedDateLabel: 'Completed: Oct 24, 2023',
        ),
        TechnicianJobRecord(
          title: 'Transmission Diagnostic',
          clientName: 'Sarah Chen',
          amount: 185.5,
          rating: 4.8,
          completedDateLabel: 'Completed: Oct 22, 2023',
        ),
        TechnicianJobRecord(
          title: 'Precision Alignment',
          clientName: 'Michael Roe',
          amount: 320,
          rating: 5.0,
          completedDateLabel: 'Completed: Oct 20, 2023',
        ),
      ],
    );
  }
}

class TechnicianJobRecord {
  const TechnicianJobRecord({
    required this.title,
    required this.clientName,
    required this.amount,
    required this.rating,
    required this.completedDateLabel,
  });

  final String title;
  final String clientName;
  final double amount;
  final double rating;
  final String completedDateLabel;

  factory TechnicianJobRecord.fromMap(Map<String, dynamic> map) {
    return TechnicianJobRecord(
      title: map['title'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedDateLabel: map['completedDateLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'clientName': clientName,
      'amount': amount,
      'rating': rating,
      'completedDateLabel': completedDateLabel,
    };
  }
}
