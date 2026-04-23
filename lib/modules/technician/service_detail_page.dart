import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/technician_service.dart' show ServiceEstimate;
import 'technician_controller.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  static const Color _bg   = Color(0xFFF2F3F7);
  static const Color _card = Colors.white;
  static const Color _ink  = Color(0xFF0A0A0A);
  static const Color _muted= Color(0xFF64748B);
  static const Color _blue = Color(0xFF0061FF);

  final _formKey = GlobalKey<FormState>();
  final _serviceCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _minCtrl     = TextEditingController();
  final _maxCtrl     = TextEditingController();

  String _duration = 'same_day';
  bool _isLoading = false;

  // Edit mode
  ServiceEstimate? _existing;
  int? _editIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _existing = args['service'] as ServiceEstimate?;
      _editIndex = args['index'] as int?;
    }

    if (_existing != null) {
      _serviceCtrl.text = _existing!.service;
      _descCtrl.text    = _existing!.description;
      _minCtrl.text     = _existing!.minPrice > 0
          ? _existing!.minPrice.toString()
          : '';
      _maxCtrl.text     = _existing!.maxPrice > 0
          ? _existing!.maxPrice.toString()
          : '';
      _duration = _existing!.duration;
    }
  }

  @override
  void dispose() {
    _serviceCtrl.dispose();
    _descCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final s = ServiceEstimate(
      service:     _serviceCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      minPrice:    int.tryParse(_minCtrl.text.replaceAll('.', '')) ?? 0,
      maxPrice:    int.tryParse(_maxCtrl.text.replaceAll('.', '')) ?? 0,
      duration:    _duration,
    );

    try {
      final ctrl = Get.find<TechnicianController>();
      if (_editIndex != null) {
        await ctrl.updateService(_editIndex!, s);
      } else {
        await ctrl.addService(s);
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save service: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Container(
              color: _card,
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: _ink),
                  ),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Service' : 'Add Service',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name
                      _SectionLabel(label: 'Service Name'),
                      const SizedBox(height: 8),
                      _FormCard(
                        child: TextFormField(
                          controller: _serviceCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDeco(
                            hint: 'cth. Screen Replacement, Battery Replacement',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Service name is required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _SectionLabel(label: 'Description'),
                      const SizedBox(height: 8),
                      _FormCard(
                        child: TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _inputDeco(
                            hint: 'Describe the service details you offer...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price range
                      _SectionLabel(label: 'Price Estimate'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _FormCard(
                              child: TextFormField(
                                controller: _minCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: _inputDeco(
                                  hint: '50000',
                                  prefix: 'Rp  ',
                                  label: 'Min Price',
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '–',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _muted),
                            ),
                          ),
                          Expanded(
                            child: _FormCard(
                              child: TextFormField(
                                controller: _maxCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: _inputDeco(
                                  hint: '150000',
                                  prefix: 'Rp  ',
                                  label: 'Max Price',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Leave max price empty if price starts from min only.',
                          style: TextStyle(
                            fontSize: 11,
                            color: _muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      _SectionLabel(label: 'Service Duration'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _DurationChip(
                            label: 'Same day',
                            value: 'same_day',
                            selected: _duration == 'same_day',
                            onTap: () => setState(() => _duration = 'same_day'),
                          ),
                          const SizedBox(width: 8),
                          _DurationChip(
                            label: '1 - 2 Days',
                            value: '1-2_days',
                            selected: _duration == '1-2_days',
                            onTap: () => setState(() => _duration = '1-2_days'),
                          ),
                          const SizedBox(width: 8),
                          _DurationChip(
                            label: '2 - 6 Days',
                            value: '2-6_days',
                            selected: _duration == '2-6_days',
                            onTap: () => setState(() => _duration = '2-6_days'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Save Changes' : 'Publish Service',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
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

  InputDecoration _inputDeco({
    required String hint,
    String? prefix,
    String? label,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixText: prefix,
      prefixStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _ink,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: _muted.withValues(alpha: 0.7),
      ),
      border: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A0A0A),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: child,
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Color(0xFF0061FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0061FF)
                  : Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
