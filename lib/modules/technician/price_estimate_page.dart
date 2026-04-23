import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/routes.dart';
import '../../services/storage_service.dart';
import 'technician_controller.dart';

class PriceEstimatePage extends StatefulWidget {
  const PriceEstimatePage({super.key});

  @override
  State<PriceEstimatePage> createState() => _PriceEstimatePageState();
}

class _PriceEstimatePageState extends State<PriceEstimatePage> {
  final _serviceFeeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // [{nameCtrl, priceCtrl}]
  final List<_PartEntry> _parts = [];

  final List<File> _workPhotos = [];
  bool _isSubmitting = false;

  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF7F8FC);

  @override
  void initState() {
    super.initState();
    // Pre-fill service fee from existing estimated price
    final order = Get.find<TechnicianController>().activeOrder.value;
    if (order != null) {
      if ((order.finalServiceFee ?? 0) > 0) {
        _serviceFeeCtrl.text = order.finalServiceFee.toString();
      }
      if (order.finalSpareParts.isNotEmpty) {
        for (final p in order.finalSpareParts) {
          _parts.add(_PartEntry(
            nameCtrl: TextEditingController(text: p['name'] as String? ?? ''),
            priceCtrl: TextEditingController(
                text: (p['price'] as num?)?.toInt().toString() ?? ''),
          ));
        }
      }
      if ((order.finalNote ?? '').isNotEmpty) {
        _noteCtrl.text = order.finalNote!;
      }
    }
  }

  @override
  void dispose() {
    _serviceFeeCtrl.dispose();
    _noteCtrl.dispose();
    for (final p in _parts) {
      p.nameCtrl.dispose();
      p.priceCtrl.dispose();
    }
    super.dispose();
  }

  void _addPart() {
    setState(() {
      _parts.add(_PartEntry(
        nameCtrl: TextEditingController(),
        priceCtrl: TextEditingController(),
      ));
    });
  }

  Future<void> _pickWorkPhotos() async {
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked.isEmpty) return;
    setState(() {
      for (final xf in picked) {
        if (_workPhotos.length < 5) _workPhotos.add(File(xf.path));
      }
    });
  }

  void _removeWorkPhoto(int index) {
    setState(() => _workPhotos.removeAt(index));
  }

  void _removePart(int index) {
    setState(() {
      _parts[index].nameCtrl.dispose();
      _parts[index].priceCtrl.dispose();
      _parts.removeAt(index);
    });
  }

  int get _serviceFee =>
      int.tryParse(_serviceFeeCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int get _partsTotal => _parts.fold(
      0,
      (sum, p) =>
          sum +
          (int.tryParse(p.priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
              0));

  int get _diagnosisFee {
    final order = Get.find<TechnicianController>().activeOrder.value;
    // Use estimatedPrice as diagnosa fee fallback if finalServiceFee not set
    return order?.estimatedPrice ?? 0;
  }

  int get _total => _serviceFee + _partsTotal + _diagnosisFee;

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

  Future<void> _confirm() async {
    if (_serviceFee == 0 && _partsTotal == 0) {
      Get.snackbar('Oops', 'Enter at least a service fee or spare part',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_workPhotos.isEmpty) {
      Get.snackbar('Photo Required', 'Upload at least 1 work evidence photo',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final parts = _parts
          .map((p) => {
                'name': p.nameCtrl.text.trim(),
                'price': int.tryParse(
                        p.priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0,
              })
          .where((p) => (p['name'] as String).isNotEmpty)
          .toList();

      final order = Get.find<TechnicianController>().activeOrder.value;
      final bookingId = order?.bookingId ?? '';
      List<String> uploadedUrls = [];
      if (_workPhotos.isNotEmpty && bookingId.isNotEmpty) {
        uploadedUrls =
            await StorageService().uploadWorkPhotos(bookingId, _workPhotos);
      }

      await Get.find<TechnicianController>().submitFinalPrice(
        serviceFee: _serviceFee,
        spareParts: parts,
        note: _noteCtrl.text.trim(),
        diagnosisFee: _diagnosisFee,
        workPhotoUrls: uploadedUrls,
      );

      Get.offNamed(AppRoutes.repairApproval);
    } catch (e) {
      Get.snackbar('Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _ink),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Estimate Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Fee Offer Header ───────────────────────────
                    const Text(
                      'Fee Offer',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Service Fee ────────────────────────────────
                    const Text(
                      'Service Fee',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PriceField(
                      controller: _serviceFeeCtrl,
                      hint: '0',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // ── Spare Parts ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spare Parts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        GestureDetector(
                          onTap: _addPart,
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                  size: 16, color: Color(0xFF0061FF)),
                              SizedBox(width: 4),
                              Text(
                                'Add Part',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0061FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Parts list
                    ...List.generate(_parts.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _parts[i].nameCtrl,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _ink),
                                decoration: InputDecoration(
                                  hintText: 'Part name',
                                  hintStyle: TextStyle(
                                      color: _muted.withOpacity(0.5),
                                      fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF0061FF)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PriceField(
                                controller: _parts[i].priceCtrl,
                                hint: '0',
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _removePart(i),
                              child: const Icon(Icons.close_rounded,
                                  size: 20, color: Color(0xFFE11D48)),
                            ),
                          ],
                        ),
                      );
                    }),

                    if (_parts.isEmpty)
                      GestureDetector(
                        onTap: _addPart,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFE2E8F0),
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  color: Color(0xFF94A3B8), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Tap to add spare part',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // ── Estimation Total Card ──────────────────────
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _serviceFeeCtrl,
                        ..._parts.map((p) => p.priceCtrl),
                      ]),
                      builder: (_, __) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimation total',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _rp(_total),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            if (_diagnosisFee > 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Including diagnosis fee ${_rp(_diagnosisFee)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white54),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Work Photos (wajib) ────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Work Photos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Required',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_workPhotos.length}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload work evidence photos before submitting.',
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add photo button
                          if (_workPhotos.length < 5)
                            GestureDetector(
                              onTap: _pickWorkPhotos,
                              child: Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFFE2E8F0),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Color(0xFF94A3B8),
                                  size: 28,
                                ),
                              ),
                            ),
                          // Photo thumbnails
                          ...List.generate(_workPhotos.length, (i) {
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(_workPhotos[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 3,
                                  right: 11,
                                  child: GestureDetector(
                                    onTap: () => _removeWorkPhoto(i),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 13, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Note for Customer ──────────────────────────
                    const Text(
                      'Note for Customer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 4,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _ink),
                      decoration: InputDecoration(
                        hintText:
                            'Example: Estimated processing time is 2-3 business days, depending on part availability.',
                        hintStyle: TextStyle(
                            color: _muted.withOpacity(0.5),
                            fontSize: 13,
                            height: 1.5),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF0061FF)),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Diagnosa warning ───────────────────────────
                    if (_diagnosisFee > 0)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_rounded,
                                size: 16, color: Color(0xFFDC2626)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'The ${_rp(_diagnosisFee)} diagnostic fee will still apply if the customer declines this offer.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDC2626),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Confirm Button ─────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: Price input field ──────────────────────────────────────────────
class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _PriceField(
      {required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        prefixText: 'Rp  ',
        prefixStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0061FF)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ── Part entry model ───────────────────────────────────────────────────────
class _PartEntry {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  _PartEntry({required this.nameCtrl, required this.priceCtrl});
}
