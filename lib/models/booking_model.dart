enum DamageType {
  screen,
  battery,
  hardware,
  water,
  camera,
  other,
}

enum PaymentMethodType {
  card,
  googlePay,
  wallet,
}

enum OrderStatusStep {
  waiting,
  onTheWay,
  verification,
  inProgress,
  completed,
}

enum OrderHistoryStatus {
  success,
  canceled,
  verificationFailed,
}

class CustomerTechnicianDetail {
  const CustomerTechnicianDetail({
    required this.id,
    required this.name,
    required this.specialty,
    required this.yearsExperience,
    required this.successRate,
    required this.rating,
    required this.accreditations,
    required this.guaranteeText,
    required this.estimates,
    required this.workshopName,
    required this.workshopAddress,
    required this.reviews,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final int yearsExperience;
  final int successRate;
  final double rating;
  final String? avatarUrl;
  final List<String> accreditations;
  final String guaranteeText;
  final List<ServiceEstimate> estimates;
  final String workshopName;
  final String workshopAddress;
  final List<CustomerReview> reviews;

  factory CustomerTechnicianDetail.fromMap(Map<String, dynamic> map) {
    return CustomerTechnicianDetail(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      yearsExperience: (map['yearsExperience'] as num?)?.toInt() ?? 0,
      successRate: (map['successRate'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      avatarUrl: map['avatarUrl'] as String?,
      accreditations: (map['accreditations'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      guaranteeText: map['guaranteeText'] as String? ?? '',
      estimates: (map['estimates'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => ServiceEstimate.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      workshopName: map['workshopName'] as String? ?? '',
      workshopAddress: map['workshopAddress'] as String? ?? '',
      reviews: (map['reviews'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => CustomerReview.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'yearsExperience': yearsExperience,
      'successRate': successRate,
      'rating': rating,
      'avatarUrl': avatarUrl,
      'accreditations': accreditations,
      'guaranteeText': guaranteeText,
      'estimates': estimates.map((item) => item.toMap()).toList(),
      'workshopName': workshopName,
      'workshopAddress': workshopAddress,
      'reviews': reviews.map((item) => item.toMap()).toList(),
    };
  }
}

class ServiceEstimate {
  const ServiceEstimate({
    required this.title,
    required this.priceLabel,
  });

  final String title;
  final String priceLabel;

  factory ServiceEstimate.fromMap(Map<String, dynamic> map) {
    return ServiceEstimate(
      title: map['title'] as String? ?? '',
      priceLabel: map['priceLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priceLabel': priceLabel,
    };
  }
}

class CustomerReview {
  const CustomerReview({
    required this.author,
    required this.comment,
    required this.rating,
  });

  final String author;
  final String comment;
  final int rating;

  factory CustomerReview.fromMap(Map<String, dynamic> map) {
    return CustomerReview(
      author: map['author'] as String? ?? '',
      comment: map['comment'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'comment': comment,
      'rating': rating,
    };
  }
}

class CustomerOrderDraft {
  const CustomerOrderDraft({
    required this.deviceName,
    required this.serialNumber,
    required this.selectedDamage,
    required this.additionalNotes,
    required this.scheduleDateLabel,
    required this.scheduleTimeLabel,
    required this.serviceFee,
    required this.partsEstimate,
    required this.taxesAndLogistics,
    required this.securityCode,
    this.isUnderWarranty = false,
  });

  final String deviceName;
  final String serialNumber;
  final DamageType selectedDamage;
  final String additionalNotes;
  final String scheduleDateLabel;
  final String scheduleTimeLabel;
  final double serviceFee;
  final double partsEstimate;
  final double taxesAndLogistics;
  final String securityCode;
  final bool isUnderWarranty;

  double get totalEstimate => serviceFee + partsEstimate + taxesAndLogistics;

  factory CustomerOrderDraft.fromMap(Map<String, dynamic> map) {
    return CustomerOrderDraft(
      deviceName: map['deviceName'] as String? ?? '',
      serialNumber: map['serialNumber'] as String? ?? '',
      selectedDamage: DamageType.values.firstWhere(
        (item) => item.name == map['selectedDamage'],
        orElse: () => DamageType.screen,
      ),
      additionalNotes: map['additionalNotes'] as String? ?? '',
      scheduleDateLabel: map['scheduleDateLabel'] as String? ?? '',
      scheduleTimeLabel: map['scheduleTimeLabel'] as String? ?? '',
      serviceFee: (map['serviceFee'] as num?)?.toDouble() ?? 0,
      partsEstimate: (map['partsEstimate'] as num?)?.toDouble() ?? 0,
      taxesAndLogistics:
          (map['taxesAndLogistics'] as num?)?.toDouble() ?? 0,
      securityCode: map['securityCode'] as String? ?? '',
      isUnderWarranty: map['isUnderWarranty'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'selectedDamage': selectedDamage.name,
      'additionalNotes': additionalNotes,
      'scheduleDateLabel': scheduleDateLabel,
      'scheduleTimeLabel': scheduleTimeLabel,
      'serviceFee': serviceFee,
      'partsEstimate': partsEstimate,
      'taxesAndLogistics': taxesAndLogistics,
      'securityCode': securityCode,
      'isUnderWarranty': isUnderWarranty,
    };
  }
}

class CheckoutSummary {
  const CheckoutSummary({
    required this.currentRepairTitle,
    required this.scheduledForLabel,
    required this.paymentMethod,
    required this.paymentOptions,
    required this.serviceFee,
    required this.partsLabel,
    required this.partsFee,
    required this.adminFee,
    required this.deliveryFee,
  });

  final String currentRepairTitle;
  final String scheduledForLabel;
  final PaymentMethodType paymentMethod;
  final List<PaymentOption> paymentOptions;
  final double serviceFee;
  final String partsLabel;
  final double partsFee;
  /// Biaya admin = 10% dari serviceFee
  final double adminFee;
  /// Ongkos kirim: Rp8.000 jika jarak <10km, Rp15.000 jika ≥10km
  final double deliveryFee;

  double get totalAmount => serviceFee + partsFee + adminFee + deliveryFee;

  factory CheckoutSummary.fromMap(Map<String, dynamic> map) {
    return CheckoutSummary(
      currentRepairTitle: map['currentRepairTitle'] as String? ?? '',
      scheduledForLabel: map['scheduledForLabel'] as String? ?? '',
      paymentMethod: PaymentMethodType.values.firstWhere(
        (item) => item.name == map['paymentMethod'],
        orElse: () => PaymentMethodType.card,
      ),
      paymentOptions: (map['paymentOptions'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => PaymentOption.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      serviceFee: (map['serviceFee'] as num?)?.toDouble() ?? 0,
      partsLabel: map['partsLabel'] as String? ?? '',
      partsFee: (map['partsFee'] as num?)?.toDouble() ?? 0,
      adminFee: (map['adminFee'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentRepairTitle': currentRepairTitle,
      'scheduledForLabel': scheduledForLabel,
      'paymentMethod': paymentMethod.name,
      'paymentOptions': paymentOptions.map((item) => item.toMap()).toList(),
      'serviceFee': serviceFee,
      'partsLabel': partsLabel,
      'partsFee': partsFee,
      'adminFee': adminFee,
      'deliveryFee': deliveryFee,
    };
  }
}

class PaymentOption {
  const PaymentOption({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final PaymentMethodType type;
  final String title;
  final String subtitle;

  factory PaymentOption.fromMap(Map<String, dynamic> map) {
    return PaymentOption(
      type: PaymentMethodType.values.firstWhere(
        (item) => item.name == map['type'],
        orElse: () => PaymentMethodType.card,
      ),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
    };
  }
}

class TrackingStatusStep {
  const TrackingStatusStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.isCurrent,
  });

  final OrderStatusStep step;
  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isCurrent;

  factory TrackingStatusStep.fromMap(Map<String, dynamic> map) {
    return TrackingStatusStep(
      step: OrderStatusStep.values.firstWhere(
        (item) => item.name == map['step'],
        orElse: () => OrderStatusStep.waiting,
      ),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      isComplete: map['isComplete'] as bool? ?? false,
      isCurrent: map['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step': step.name,
      'title': title,
      'subtitle': subtitle,
      'isComplete': isComplete,
      'isCurrent': isCurrent,
    };
  }
}

class OrderTrackingData {
  const OrderTrackingData({
    required this.mapTitle,
    required this.currentStatusTitle,
    required this.statusSteps,
    required this.securityCode,
    required this.technicianName,
    required this.technicianRole,
    required this.partnerLabel,
    this.technicianAvatarUrl,
    this.customerLat,
    this.customerLng,
  });

  final String mapTitle;
  final String currentStatusTitle;
  final List<TrackingStatusStep> statusSteps;
  final String securityCode;
  final String technicianName;
  final String technicianRole;
  final String partnerLabel;
  final String? technicianAvatarUrl;
  final double? customerLat;
  final double? customerLng;

  factory OrderTrackingData.fromMap(Map<String, dynamic> map) {
    return OrderTrackingData(
      mapTitle: map['mapTitle'] as String? ?? '',
      currentStatusTitle: map['currentStatusTitle'] as String? ?? '',
      statusSteps: (map['statusSteps'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => TrackingStatusStep.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      securityCode: map['securityCode'] as String? ?? '',
      technicianName: map['technicianName'] as String? ?? '',
      technicianRole: map['technicianRole'] as String? ?? '',
      partnerLabel: map['partnerLabel'] as String? ?? '',
      technicianAvatarUrl: map['technicianAvatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mapTitle': mapTitle,
      'currentStatusTitle': currentStatusTitle,
      'statusSteps': statusSteps.map((item) => item.toMap()).toList(),
      'securityCode': securityCode,
      'technicianName': technicianName,
      'technicianRole': technicianRole,
      'partnerLabel': partnerLabel,
      'technicianAvatarUrl': technicianAvatarUrl,
    };
  }
}

class OrderHistoryRecord {
  const OrderHistoryRecord({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.amountLabel,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String dateLabel;
  final String amountLabel;
  final OrderHistoryStatus status;

  factory OrderHistoryRecord.fromMap(Map<String, dynamic> map) {
    return OrderHistoryRecord(
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      dateLabel: map['dateLabel'] as String? ?? '',
      amountLabel: map['amountLabel'] as String? ?? '',
      status: OrderHistoryStatus.values.firstWhere(
        (item) => item.name == map['status'],
        orElse: () => OrderHistoryStatus.success,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'dateLabel': dateLabel,
      'amountLabel': amountLabel,
      'status': status.name,
    };
  }
}
