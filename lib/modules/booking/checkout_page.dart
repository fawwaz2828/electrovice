import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/booking_model.dart';
import 'booking_controller.dart';

class CheckoutPage extends GetView<BookingController> {
  const CheckoutPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final CheckoutSummary checkout = controller.checkoutData;

          return Column(
            children: [
              const _CheckoutTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      _CurrentRepairCard(checkout: checkout),
                      const SizedBox(height: 16),
                      const _SectionLabel('Payment Method'),
                      const SizedBox(height: 10),
                      ...checkout.paymentOptions.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PaymentOptionTile(
                            option: option,
                            selected: checkout.paymentMethod == option.type,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PromoTile(),
                      const SizedBox(height: 16),
                      _CostBreakdown(checkout: checkout),
                      const SizedBox(height: 16),
                      const _CheckoutFooterBadges(),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: SafeArea(
                  top: false,
                  child: Obx(() => FilledButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitBooking(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Konfirmasi Pesanan',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                              SizedBox(width: 8),
                              Icon(Icons.check_circle_outline_rounded),
                            ],
                          ),
                  )),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CheckoutTopBar extends StatelessWidget {
  const _CheckoutTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Text(
            'Checkout',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CurrentRepairCard extends StatelessWidget {
  const _CurrentRepairCard({required this.checkout});

  final CheckoutSummary checkout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT REPAIR',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkout.currentRepairTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkout.scheduledForLabel,
                      style: const TextStyle(color: Color(0xFF727B8B)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.laptop_mac_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Color(0xFF3654FF), size: 18),
                SizedBox(width: 8),
                Text(
                  'Verified Professional Service assigned',
                  style: TextStyle(
                    color: Color(0xFF3654FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.option,
    required this.selected,
  });

  final PaymentOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(option.type)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  option.subtitle,
                  style: const TextStyle(color: Color(0xFF727B8B), fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? const Color(0xFF3654FF) : const Color(0xFFB4BCCB),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
      case PaymentMethodType.googlePay:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethodType.wallet:
        return Icons.wallet_outlined;
    }
  }
}

class _PromoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.sell_outlined, color: Color(0xFF8A5A20)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Apply promo code or voucher',
              style: TextStyle(color: Color(0xFF727B8B)),
            ),
          ),
          Text(
            'Apply',
            style: TextStyle(color: Color(0xFF3654FF), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  const _CostBreakdown({required this.checkout});

  final CheckoutSummary checkout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _costRow('Service Fee', checkout.serviceFee),
          const SizedBox(height: 10),
          _costRow(checkout.partsLabel, checkout.partsFee),
          const SizedBox(height: 10),
          _costRow('Tax & Processing Fee', checkout.taxFee),
          const Divider(height: 26),
          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                _money(checkout.totalAmount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3654FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, double value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF60697A)))),
        Text(_money(value), style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _CheckoutFooterBadges extends StatelessWidget {
  const _CheckoutFooterBadges();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('SECURE ENCRYPTION', style: TextStyle(fontSize: 10, color: Color(0xFF727B8B))),
        Text('FRAUD PROTECTION', style: TextStyle(fontSize: 10, color: Color(0xFF727B8B))),
      ],
    );
  }
}
