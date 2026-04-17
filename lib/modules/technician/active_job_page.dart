import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../services/auth_service.dart';
import '../../utils/maps_launcher.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../technician/technician_controller.dart';

class ActiveJobPage extends StatefulWidget {
  const ActiveJobPage({super.key});

  @override
  State<ActiveJobPage> createState() => _ActiveJobPageState();
}

class _ActiveJobPageState extends State<ActiveJobPage> {
  bool _isCompleting = false;
  bool _isCalling = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  Future<void> _callCustomer() async {
    final ctrl = Get.find<TechnicianController>();
    final order = ctrl.activeOrder.value ?? ctrl.selectedOrder.value;
    if (order == null) return;
    setState(() => _isCalling = true);
    try {
      final user = await AuthService().getUserModel(order.userId);
      final phone = (user?.phone ?? '').trim();
      if (phone.isEmpty) {
        Get.snackbar('Not available', 'Customer phone number is not registered',
            snackPosition: SnackPosition.TOP);
        return;
      }
      await launchUrl(Uri(scheme: 'tel', path: phone));
    } catch (e) {
      Get.snackbar('Failed', 'Unable to open phone app',
          snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _isCalling = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _startElapsedTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startElapsedTimer() {
    final order = Get.find<TechnicianController>().activeOrder.value;
    final startTime = order?.codeVerifiedAt ?? order?.updatedAt;
    if (startTime != null) {
      _elapsed = DateTime.now().difference(startTime);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String get _elapsedLabel {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Screen Damage',
        'battery' => 'Battery Issue',
        'hardware' => 'Hardware Damage',
        'water' => 'Water Damage',
        'camera' => 'Camera Issue',
        _ => 'General Repair',
      };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TechnicianController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(
        selectedItem: AppNavItem.active,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(() {
            final order = controller.activeOrder.value ?? controller.selectedOrder.value;
            return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Main Work Order Card ───────────────────────────────
              _WorkOrderHeader(
                bookingId: order?.bookingId.substring(0, 8).toUpperCase() ?? '--------',
                issueTitle: _damageLabel(order?.damageType ?? ''),
                customerName: order?.userName ?? '-',
                userAddress: order?.userAddress ?? 'Address not available',
                status: order?.status ?? BookingStatus.onProgress,
                elapsedLabel: _elapsedLabel,
                lat: order?.latitude,
                lng: order?.longitude,
              ),

              const SizedBox(height: 24),

              // ── Actions Grid ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.phone_in_talk_rounded,
                      label: 'CALL CLIENT',
                      sublabel: order?.userName ?? '-',
                      onTap: _isCalling ? null : _callCustomer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.chat_bubble_rounded,
                      label: 'LIVE CHAT',
                      sublabel: order?.userName ?? '-',
                      onTap: order == null
                          ? null
                          : () => Get.toNamed(
                                AppRoutes.chat,
                                arguments: {
                                  'chatId': order.bookingId,
                                  'otherPartyName': order.userName,
                                  'bookingDoc': order,
                                },
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── System Estimate Card ────────────────────────────────
              if (order != null) _SystemEstimateCard(order: order),

              const SizedBox(height: 16),

              // ── Update price button ─────────────────────────────────
              OutlinedButton(
                onPressed: order == null
                    ? null
                    : () => Get.toNamed(AppRoutes.priceEstimate),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(
                      color: Color(0xFF0061FF), width: 1.5),
                  foregroundColor: const Color(0xFF0061FF),
                ),
                child: const Text(
                  'Update price',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 12),

              // ── Complete Order button ───────────────────────────────
              ElevatedButton(
                onPressed: _isCompleting || order == null
                    ? null
                    : () async {
                        // If no final price set, prompt to set it first
                        if ((order.finalTotalAmount ?? 0) == 0) {
                          Get.toNamed(AppRoutes.priceEstimate);
                          return;
                        }
                        setState(() => _isCompleting = true);
                        // finalTotalAmount already set → already in awaiting_payment
                        // Just navigate to repair approval
                        Get.toNamed(AppRoutes.repairApproval);
                        if (mounted) setState(() => _isCompleting = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: _isCompleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Complete Order',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'By clicking complete, you confirm all safety checks are performed and a diagnostic report will be sent to the customer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 140),
            ],
          ); // end Column
          }), // end Obx
        ),
      ),
    );
  }
}

class _WorkOrderHeader extends StatelessWidget {
  final String bookingId;
  final String issueTitle;
  final String customerName;
  final String userAddress;
  final String status;
  final String elapsedLabel;
  final double? lat;
  final double? lng;

  const _WorkOrderHeader({
    required this.bookingId,
    required this.issueTitle,
    required this.customerName,
    required this.userAddress,
    required this.status,
    required this.elapsedLabel,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORK ORDER #$bookingId',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Repairing',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            issueTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),

          // Nested Cards
          _TimeElapsedCard(elapsedLabel: elapsedLabel),
          const SizedBox(height: 12),
          _LocationCard(address: userAddress, lat: lat, lng: lng),

          const SizedBox(height: 24),
          const _TaskProgressSection(),
        ],
      ),
    );
  }
}

class _TimeElapsedCard extends StatelessWidget {
  final String elapsedLabel;
  const _TimeElapsedCard({required this.elapsedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIME ELAPSED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
                letterSpacing: -1,
              ),
              children: [
                TextSpan(text: elapsedLabel),
                const TextSpan(
                  text: ' hrs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
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

class _LocationCard extends StatelessWidget {
  final String address;
  final double? lat;
  final double? lng;
  const _LocationCard({required this.address, this.lat, this.lng});
  @override
  Widget build(BuildContext context) {
    final hasCoords = lat != null && lng != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CUSTOMER LOCATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          if (hasCoords) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => MapsLauncher.navigateTo(
                lat: lat!,
                lng: lng!,
                label: address,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: Color(0xFF3254FF),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Navigate to Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3254FF),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF3254FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskProgressSection extends StatelessWidget {
  const _TaskProgressSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TASK PROGRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '75% COMPLETE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(4, (index) {
            final bool completed = index < 3;
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF3254FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3254FF), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── System Estimate Card ──────────────────────────────────────────────────
class _SystemEstimateCard extends StatelessWidget {
  final BookingDocument order;
  const _SystemEstimateCard({required this.order});

  String _rp(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final hasFinal = (order.finalTotalAmount ?? 0) > 0;
    final total = hasFinal
        ? order.finalTotalAmount!
        : order.estimatedPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Estimate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL RANGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _rp(total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0061FF),
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasFinal) ...[
                  const SizedBox(height: 12),
                  if ((order.finalServiceFee ?? 0) > 0)
                    _EstimateRow(
                      label: 'Service Fee',
                      value: _rp(order.finalServiceFee!),
                    ),
                  ...order.finalSpareParts.map((p) => _EstimateRow(
                        label: p['name'] as String? ?? 'Part',
                        value: _rp(
                            (p['price'] as num?)?.toInt() ?? 0),
                      )),
                ] else ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Initial estimate (not final)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateRow extends StatelessWidget {
  final String label;
  final String value;
  const _EstimateRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF475569)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

