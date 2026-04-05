import 'package:get/get.dart';

import '../../models/booking_model.dart';

class BookingController extends GetxController {
  final Rxn<CustomerTechnicianDetail> technician = Rxn<CustomerTechnicianDetail>();
  final Rxn<CustomerOrderDraft> orderDraft = Rxn<CustomerOrderDraft>();
  final Rxn<CheckoutSummary> checkout = Rxn<CheckoutSummary>();
  final Rxn<OrderTrackingData> tracking = Rxn<OrderTrackingData>();
  final RxList<OrderHistoryRecord> orderHistory = <OrderHistoryRecord>[].obs;

  CustomerTechnicianDetail get technicianData => technician.value ?? _sampleTechnician();
  CustomerOrderDraft get orderDraftData => orderDraft.value ?? _sampleOrderDraft();
  CheckoutSummary get checkoutData => checkout.value ?? _sampleCheckout();
  OrderTrackingData get trackingData => tracking.value ?? _sampleTracking();
  List<OrderHistoryRecord> get orderHistoryData =>
      orderHistory.isEmpty ? _sampleHistory() : orderHistory;

  @override
  void onInit() {
    super.onInit();
    technician.value = _sampleTechnician();
    orderDraft.value = _sampleOrderDraft();
    checkout.value = _sampleCheckout();
    tracking.value = _sampleTracking();
    orderHistory.assignAll(_sampleHistory());
  }

  void loadTechnicianFromMap(Map<String, dynamic> map) {
    technician.value = CustomerTechnicianDetail.fromMap(map);
  }

  void loadOrderDraftFromMap(Map<String, dynamic> map) {
    orderDraft.value = CustomerOrderDraft.fromMap(map);
  }

  void loadCheckoutFromMap(Map<String, dynamic> map) {
    checkout.value = CheckoutSummary.fromMap(map);
  }

  void loadTrackingFromMap(Map<String, dynamic> map) {
    tracking.value = OrderTrackingData.fromMap(map);
  }

  void loadHistoryFromList(List<Map<String, dynamic>> items) {
    orderHistory.assignAll(
      items.map(OrderHistoryRecord.fromMap),
    );
  }

  CustomerTechnicianDetail _sampleTechnician() {
    return const CustomerTechnicianDetail(
      id: 'tech_marcus_chen',
      name: 'Marcus Chen',
      specialty: 'LAPTOP & MICRO-SOLDERING\nSPECIALIST',
      yearsExperience: 12,
      successRate: 99,
      rating: 4.9,
      accreditations: [
        'Apple Certified',
        'ISO 9001',
        'Compliance',
      ],
      guaranteeText:
          'Verification via a unique 6-digit session code is required at the time of repair for your data safety.',
      estimates: [
        ServiceEstimate(
          title: 'LCD Screen Replacement',
          priceLabel: '\$120 - \$180',
        ),
        ServiceEstimate(
          title: 'Logic Board Micro-Soldering',
          priceLabel: '\$85 - \$150',
        ),
        ServiceEstimate(
          title: 'Data Recovery Service',
          priceLabel: 'From \$200',
        ),
      ],
      workshopName: 'Workshop Hub',
      workshopAddress: '88 Techcentre Ave, Suite 402, Neo-District, 50212',
      reviews: [
        CustomerReview(
          author: 'Jonathan Vance',
          comment:
              'Marcus fixed my Macbook logic board in 2 hours when everyone else said it was trash.',
          rating: 5,
        ),
        CustomerReview(
          author: 'Sarah G.',
          comment:
              'Very professional workshop and the pricing was exactly as estimated.',
          rating: 5,
        ),
      ],
    );
  }

  CustomerOrderDraft _sampleOrderDraft() {
    return const CustomerOrderDraft(
      deviceName: 'iPhone 15 Pro Max',
      serialNumber: 'SN: 7892-XT-9921',
      selectedDamage: DamageType.screen,
      additionalNotes: 'Display flickers after impact and touch response lags.',
      scheduleDateLabel: 'OCT 24 Thu',
      scheduleTimeLabel: '09:00 AM',
      serviceFee: 45.0,
      partsEstimate: 189.0,
      taxesAndLogistics: 12.4,
      securityCode: '842915',
      isUnderWarranty: true,
    );
  }

  CheckoutSummary _sampleCheckout() {
    return const CheckoutSummary(
      currentRepairTitle: 'MacBook Pro Screen\nRepair',
      scheduledForLabel: 'Scheduled for Oct 24, 10:00 AM',
      paymentMethod: PaymentMethodType.card,
      paymentOptions: [
        PaymentOption(
          type: PaymentMethodType.card,
          title: 'Credit or Debit Card',
          subtitle: 'Visa, Mastercard, JCB',
        ),
        PaymentOption(
          type: PaymentMethodType.googlePay,
          title: 'Google Pay',
          subtitle: 'Fast and secure payment',
        ),
        PaymentOption(
          type: PaymentMethodType.wallet,
          title: 'Digital Wallet',
          subtitle: 'OVO, Dana, GoPay',
        ),
      ],
      serviceFee: 45.0,
      partsLabel: 'Parts (Retina Display Panel)',
      partsFee: 189.0,
      taxFee: 12.45,
    );
  }

  OrderTrackingData _sampleTracking() {
    return const OrderTrackingData(
      mapTitle: 'LIVE LOCATION',
      currentStatusTitle: 'Waiting for Technician',
      statusSteps: [
        TrackingStatusStep(
          step: OrderStatusStep.waiting,
          title: 'Waiting for Technician',
          subtitle: 'Matching your request with the best engineer',
          isComplete: true,
          isCurrent: true,
        ),
        TrackingStatusStep(
          step: OrderStatusStep.onTheWay,
          title: 'Technician on the Way',
          subtitle: 'Eta 15-20 minutes',
          isComplete: false,
          isCurrent: false,
        ),
        TrackingStatusStep(
          step: OrderStatusStep.verification,
          title: '6-Digit Code Verification',
          subtitle: '',
          isComplete: false,
          isCurrent: false,
        ),
        TrackingStatusStep(
          step: OrderStatusStep.inProgress,
          title: 'Repair in Progress',
          subtitle: '',
          isComplete: false,
          isCurrent: false,
        ),
        TrackingStatusStep(
          step: OrderStatusStep.completed,
          title: 'Completed',
          subtitle: '',
          isComplete: false,
          isCurrent: false,
        ),
      ],
      securityCode: '842915',
      technicianName: 'Marcus Chen',
      technicianRole: 'HVAC SENIOR SPECIALIST',
      partnerLabel: 'PLATINUM PARTNER',
    );
  }

  List<OrderHistoryRecord> _sampleHistory() {
    return const [
      OrderHistoryRecord(
        title: 'MacBook Pro Screen\nRepair',
        subtitle: 'Marcus Chen',
        dateLabel: 'Oct 12, 2023',
        amountLabel: '\$189.00',
        status: OrderHistoryStatus.success,
      ),
      OrderHistoryRecord(
        title: 'iPhone 14 Battery Swap',
        subtitle: 'Canceled by Technician',
        dateLabel: 'Sep 28, 2023',
        amountLabel: 'No Charge',
        status: OrderHistoryStatus.canceled,
      ),
      OrderHistoryRecord(
        title: 'AC Unit\nMaintenance',
        subtitle: 'Security code mismatch',
        dateLabel: 'Sep 15, 2023',
        amountLabel: 'Retry Verification',
        status: OrderHistoryStatus.verificationFailed,
      ),
      OrderHistoryRecord(
        title: 'Samsung TV Backlight',
        subtitle: 'Sarah Jenkins',
        dateLabel: 'Aug 22, 2023',
        amountLabel: '\$120.00',
        status: OrderHistoryStatus.success,
      ),
    ];
  }
}
