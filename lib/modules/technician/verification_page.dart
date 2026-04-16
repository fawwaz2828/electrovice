import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../utils/maps_launcher.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../../widget/customer_location_map.dart';
import '../technician/technician_controller.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<String> _pin = List.filled(6, '');
  bool _isVerifying = false;
  final _hiddenCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _hiddenCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    final code = _pin.join();
    if (code.length < 6 || _pin.contains('')) {
      Get.snackbar('Oops', 'Masukkan 6 digit kode verifikasi',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await Get.find<TechnicianController>().verifyCode(code);
      setState(() => _isVerifying = false);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _VerificationResultDialog(success: true),
      );
      // Dialog dismissed → navigate to active job
      Get.offNamed(AppRoutes.activeJob);
    } catch (e) {
      // Clear pin for re-entry
      setState(() {
        for (int i = 0; i < 6; i++) { _pin[i] = ''; }
        _isVerifying = false;
      });
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _VerificationResultDialog(success: false, message: msg),
      );
    }
  }

  void _onKeyTap(String digit) {
    setState(() {
      final idx = _pin.indexOf('');
      if (idx != -1) _pin[idx] = digit;
    });
  }

  void _onDelete() {
    setState(() {
      final idx = _pin.lastIndexWhere((c) => c != '');
      if (idx != -1) _pin[idx] = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Scrollable area ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Card (Map + Client Info) ───────────────
                    _ClientSummaryCard(),
                    const SizedBox(height: 28),

                    // ── Verification Section ──────────────────────────
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            '6-Digit Verification Code',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enter user's code to start service",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F88AE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PIN Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _PinBox(value: _pin[index])),
                    ),
                    const SizedBox(height: 20),

                    // Numpad
                    _Numpad(onTap: _onKeyTap, onDelete: _onDelete),
                    const SizedBox(height: 24),

                    // ── Service Parameters ────────────────────────────
                    _ServiceParametersCard(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // ── Fixed Verify Button at bottom ────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Verifikasi & Mulai Servis',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _verifDamageLabel(String type) => switch (type) {
      'screen' => 'Kerusakan Layar',
      'battery' => 'Masalah Baterai',
      'hardware' => 'Kerusakan Hardware',
      'water' => 'Water Damage',
      'camera' => 'Masalah Kamera',
      _ => 'Perbaikan Umum',
    };

String _verifFormatRp(int price) {
  final str = price.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
    buf.write(str[i]);
  }
  return buf.toString();
}

class _ClientSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TechnicianController>();
    return Obx(() {
      final order = ctrl.selectedOrder.value ?? ctrl.activeOrder.value;
      final customerName = order?.userName ?? '-';
      final address = (order?.userAddress.isNotEmpty ?? false)
          ? order!.userAddress
          : 'Alamat tidak tersedia';
      final damageTitle = _verifDamageLabel(order?.damageType ?? '');
      final lat = order?.latitude;
      final lng = order?.longitude;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Map (real Mapbox jika lat/lng tersedia, placeholder jika tidak) ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: lat != null && lng != null
                    ? Stack(
                        children: [
                          CustomerLocationMap(lat: lat, lng: lng),
                          // Address label bawah-kiri
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    address.length > 22
                                        ? '${address.substring(0, 22)}...'
                                        : address,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Navigate button bawah-kanan
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => MapsLauncher.navigateTo(
                                lat: lat,
                                lng: lng,
                                label: address,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.navigation_rounded,
                                        size: 14, color: Color(0xFF0061FF)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Navigasi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0061FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: const Color(0xFFE8EDF5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off_outlined,
                                size: 28, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 8),
                            Text(
                              address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.home_outlined, size: 16, color: Color(0xFF6F88AE)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6F88AE),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Issue Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build_rounded, color: Color(0xFF111111)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'JENIS KERUSAKAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC0C8D7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                damageTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PinBox extends StatelessWidget {
  final String value;
  const _PinBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        value.isEmpty ? '0' : value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: value.isEmpty ? const Color(0xFFCBD5E1) : const Color(0xFF111111),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final ValueChanged<String> onTap;
  final VoidCallback onDelete;
  const _Numpad({required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final key = keys[i];
        if (key.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: key == '⌫' ? onDelete : () => onTap(key),
          child: Container(
            decoration: BoxDecoration(
              color: key == '⌫' ? const Color(0xFFFFE4E4) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: key == '⌫' ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  VERIFICATION RESULT DIALOG
// ─────────────────────────────────────────────────────────────────
class _VerificationResultDialog extends StatelessWidget {
  final bool success;
  final String? message;
  const _VerificationResultDialog({required this.success, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon Circle ─────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: success
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: success
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                size: 44,
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ───────────────────────────────────────────────
            Text(
              success ? 'Verification Accepted' : 'Verification Failed',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ────────────────────────────────────────────
            Text(
              success
                  ? 'Verification Code Received'
                  : (message ?? 'Enter the right Code'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // ── Button ──────────────────────────────────────────────
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                success ? 'Check Order' : 'Retry',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Quote ───────────────────────────────────────────────
            const Text(
              'No pain no gain\n-random person',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceParametersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TechnicianController>();
    return Obx(() {
      final order = ctrl.selectedOrder.value ?? ctrl.activeOrder.value;
      final price = order?.estimatedPrice ?? 0;
      final priceLabel = price > 0 ? 'Rp ${_verifFormatRp(price)}' : 'Tunai';

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PARAMETER LAYANAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: Color(0xFF475569), size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimasi Biaya',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined, color: Color(0xFF475569), size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Bayar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order?.paymentMethod == 'cash' ? 'Tunai' : (order?.paymentMethod ?? 'Tunai'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
