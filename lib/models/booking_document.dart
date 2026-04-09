import 'package:cloud_firestore/cloud_firestore.dart';

/// Status flow: confirmed → on_progress → done | cancelled
/// (pending_payment dipakai untuk non-cash, skip dulu untuk MVP cash-only)
class BookingStatus {
  static const confirmed = 'confirmed';
  static const onProgress = 'on_progress';
  static const done = 'done';
  static const cancelled = 'cancelled';
}

class PaymentMethod {
  static const cash = 'cash';
  static const gopay = 'gopay';
  static const qris = 'qris';
  static const bankTransfer = 'bank_transfer';
}

class BookingDocument {
  final String bookingId;
  final String userId;
  final String userName;
  final String technicianId;
  final String technicianName;
  final String? technicianPhotoUrl;
  final String category; // electronic | vehicle
  final String description; // keluhan dari customer
  final String damageType; // screen | battery | hardware | water | camera | other
  final DateTime scheduledAt;
  final String paymentMethod;
  final int estimatedPrice; // dalam Rupiah, 0 = diskusi di lokasi
  final String? verificationCode; // 6 digit
  final DateTime? codeExpiryAt;
  final DateTime? codeVerifiedAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingDocument({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.technicianId,
    required this.technicianName,
    required this.category,
    required this.description,
    required this.damageType,
    required this.scheduledAt,
    required this.paymentMethod,
    required this.estimatedPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.technicianPhotoUrl,
    this.verificationCode,
    this.codeExpiryAt,
    this.codeVerifiedAt,
  });

  factory BookingDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingDocument(
      bookingId: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      technicianId: data['technicianId'] as String? ?? '',
      technicianName: data['technicianName'] as String? ?? '',
      technicianPhotoUrl: data['technicianPhotoUrl'] as String?,
      category: data['category'] as String? ?? 'electronic',
      description: data['description'] as String? ?? '',
      damageType: data['damageType'] as String? ?? 'other',
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'] as String? ?? PaymentMethod.cash,
      estimatedPrice: (data['estimatedPrice'] as num?)?.toInt() ?? 0,
      verificationCode: data['verificationCode'] as String?,
      codeExpiryAt: (data['codeExpiryAt'] as Timestamp?)?.toDate(),
      codeVerifiedAt: (data['codeVerifiedAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? BookingStatus.confirmed,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'technicianPhotoUrl': technicianPhotoUrl,
      'category': category,
      'description': description,
      'damageType': damageType,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'paymentMethod': paymentMethod,
      'estimatedPrice': estimatedPrice,
      'verificationCode': verificationCode,
      'codeExpiryAt': codeExpiryAt != null ? Timestamp.fromDate(codeExpiryAt!) : null,
      'codeVerifiedAt': codeVerifiedAt != null ? Timestamp.fromDate(codeVerifiedAt!) : null,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isActive =>
      status == BookingStatus.confirmed || status == BookingStatus.onProgress;

  bool get isCodeExpired =>
      codeExpiryAt != null && DateTime.now().isAfter(codeExpiryAt!);
}
