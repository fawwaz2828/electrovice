import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum _CertType { automotive, digital }

enum _PaymentMethod { bankTransfer, eMoney }

class CertificationRegistrationFormPage extends StatefulWidget {
  const CertificationRegistrationFormPage({super.key});

  @override
  State<CertificationRegistrationFormPage> createState() =>
      _CertificationRegistrationFormPageState();
}

class _CertificationRegistrationFormPageState
    extends State<CertificationRegistrationFormPage> {
  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF2F3F7);
  static const Color _accent = Color(0xFF3254FF);
  static const Color _border = Color(0xFFE2E8F0);

  // ── Certification fees (Indonesian Rupiah) ───────────────────
  static const int _examFee = 1500000;
  static const int _serviceFee = 200000;
  static const int _totalCost = _examFee + _serviceFee;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _examDate;
  _CertType? _certType;
  _PaymentMethod? _paymentMethod = _PaymentMethod.bankTransfer;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _birthPlaceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 17, now.month, now.day),
      helpText: 'Select date of birth',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickExamDate() async {
    final now = DateTime.now();
    final firstAvailable = now.add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? firstAvailable,
      firstDate: firstAvailable,
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'Select remote exam date',
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _toast('Please select your date of birth');
      return;
    }
    if (_examDate == null) {
      _toast('Please select an exam date');
      return;
    }
    if (_certType == null) {
      _toast('Please select a certification type');
      return;
    }
    if (_paymentMethod == null) {
      _toast('Please select a payment method');
      return;
    }

    setState(() => _isSubmitting = true);
    // Dummy payment — no backend, no gateway. Brief delay simulates submission.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    await _showSuccessDialog();
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _accent, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Successfully registered for certification exam',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait for further information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Get.back(); // close registration form
                Get.back(); // close upgrade page → back to profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) =>
      Get.snackbar('Oops', msg, snackPosition: SnackPosition.TOP);

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Certification Registration',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('PERSONAL DETAILS', [
                  _textField(
                    label: 'Full Name',
                    controller: _nameController,
                    hint: 'As written on your ID',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Full name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'NIK (National ID Number)',
                    controller: _nikController,
                    hint: '16-digit NIK',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'NIK is required';
                      if (v.trim().length != 16) return 'NIK must be 16 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: 'e.g. 081234567890',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone is required';
                      if (v.trim().length < 8) return 'Phone too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Place of Birth',
                    controller: _birthPlaceController,
                    hint: 'e.g. Jakarta',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Place of birth is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _datePickerField(
                    label: 'Date of Birth',
                    value: _birthDate,
                    onTap: _pickBirthDate,
                    placeholder: 'Tap to pick date',
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    label: 'Full Address',
                    controller: _addressController,
                    hint: 'Street, RT/RW, kelurahan, city, province',
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Address is required'
                        : null,
                  ),
                ]),
                const SizedBox(height: 20),

                _buildSection('CERTIFICATION', [
                  _buildCertTypeOption(
                    value: _CertType.automotive,
                    title: 'LSP Automotive Technician',
                    subtitle: 'Vehicle electrical & EV systems',
                    icon: Icons.directions_car_filled_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildCertTypeOption(
                    value: _CertType.digital,
                    title: 'LSP Digital/Computer Technician',
                    subtitle: 'Laptops, smartphones & PC repair',
                    icon: Icons.laptop_mac_outlined,
                  ),
                  const SizedBox(height: 14),
                  _datePickerField(
                    label: 'Exam Date (Remote)',
                    value: _examDate,
                    onTap: _pickExamDate,
                    placeholder: 'Tap to pick exam date',
                  ),
                ]),
                const SizedBox(height: 20),

                _buildSection('PAYMENT METHOD', [
                  _buildPaymentOption(
                    value: _PaymentMethod.bankTransfer,
                    title: 'Bank Transfer',
                    subtitle: 'BCA, Mandiri, BNI, BRI',
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    value: _PaymentMethod.eMoney,
                    title: 'E-Money',
                    subtitle: 'GoPay, OVO, DANA, ShopeePay',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── COST BREAKDOWN ────────────────────────────────
                _buildCostBreakdown(),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── BUILDERS ───────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _muted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _ink, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _muted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _muted.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _muted,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: _muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value == null ? placeholder : _formatDate(value),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? _muted.withValues(alpha: 0.7)
                          : _ink,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: _muted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertTypeOption({
    required _CertType value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _certType == value;
    return InkWell(
      onTap: () => setState(() => _certType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.08)
              : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? _accent.withValues(alpha: 0.15)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? _accent : _muted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? _accent : _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Radio<_CertType>(
              value: value,
              groupValue: _certType,
              onChanged: (v) => setState(() => _certType = v),
              activeColor: _accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required _PaymentMethod value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.08)
              : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? _accent.withValues(alpha: 0.15)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? _accent : _muted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? _accent : _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Radio<_PaymentMethod>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v),
              activeColor: _accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COST BREAKDOWN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _muted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _ink, width: 1),
          ),
          child: Column(
            children: [
              _costRow('Exam Fee', _examFee),
              const SizedBox(height: 10),
              _costRow('Service Fee (Electrovice)', _serviceFee),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: _border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  Text(
                    _formatRupiah(_totalCost),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _costRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
        Text(
          _formatRupiah(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }
}
