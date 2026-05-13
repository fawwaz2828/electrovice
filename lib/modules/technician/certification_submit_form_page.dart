import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/technician_service.dart';

class CertificationSubmitFormPage extends StatefulWidget {
  const CertificationSubmitFormPage({super.key});

  @override
  State<CertificationSubmitFormPage> createState() =>
      _CertificationSubmitFormPageState();
}

class _CertificationSubmitFormPageState
    extends State<CertificationSubmitFormPage> {
  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF2F3F7);
  static const Color _accent = Color(0xFF3254FF);
  static const Color _field = Color(0xFFF8F9FB);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _storageService = StorageService();
  final _technicianService = TechnicianService();
  final _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  final _certNumberCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  File? _photoFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
    _certNumberCtrl.dispose();
    _specialtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _pickIssueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? now,
      firstDate: DateTime(1980),
      lastDate: now,
      helpText: 'Select certificate issue date',
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: _issueDate ?? DateTime(1980),
      lastDate: DateTime(now.year + 50),
      helpText: 'Select expiry date (optional)',
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issueDate == null) {
      _toast('Select the certificate issue date');
      return;
    }
    if (_photoFile == null) {
      _toast('Upload a certificate photo');
      return;
    }
    final user = _authService.currentUser;
    if (user == null) {
      _toast('Please sign in again');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final photoUrl = await _storageService.uploadSingleCertification(
          user.uid, _photoFile!);

      await _technicianService.submitCertification(
        user.uid,
        name: _nameCtrl.text.trim(),
        issuer: _issuerCtrl.text.trim(),
        certNumber: _certNumberCtrl.text.trim(),
        issueDate: _issueDate!,
        expiryDate: _expiryDate,
        specialty: _specialtyCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      _toast('Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _toast(String msg) {
    Get.snackbar('Oops', msg, snackPosition: SnackPosition.TOP);
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: const Icon(Icons.hourglass_top_rounded,
                  color: _accent, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Certificate submitted successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'An admin will verify your certificate. The "certified" badge will appear once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
                height: 1.4,
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
                Navigator.of(ctx).pop();
                Get.back(); // close form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('OK',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
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
          'Submit Certificate',
          style: TextStyle(
              color: _ink, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _sectionLabel('CERTIFICATE PHOTO *'),
              _buildPhotoPicker(),
              const SizedBox(height: 20),

              _sectionLabel('CERTIFICATE NAME *'),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Example: LSP Digital Technician',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _sectionLabel('ISSUING ORGANIZATION *'),
              _buildTextField(
                controller: _issuerCtrl,
                hint: 'Example: BNSP, LSP Komputer, Apple Inc.',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _sectionLabel('CERTIFICATE NUMBER'),
              _buildTextField(
                controller: _certNumberCtrl,
                hint: 'Optional — example: BNSP-2024-001234',
              ),
              const SizedBox(height: 16),

              _sectionLabel('SPECIALTY *'),
              _buildTextField(
                controller: _specialtyCtrl,
                hint: 'Example: Computer & laptop repair',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),

              _sectionLabel('ISSUE DATE *'),
              _buildDateField(
                value: _issueDate,
                placeholder: 'Select issue date',
                onTap: _pickIssueDate,
              ),
              const SizedBox(height: 16),

              _sectionLabel('EXPIRY DATE'),
              _buildDateField(
                value: _expiryDate,
                placeholder: 'Optional — leave empty if lifetime',
                onTap: _pickExpiryDate,
                onClear: _expiryDate == null
                    ? null
                    : () => setState(() => _expiryDate = null),
              ),
              const SizedBox(height: 16),

              _sectionLabel('ADDITIONAL NOTES'),
              _buildTextField(
                controller: _notesCtrl,
                hint: 'Optional — extra info for the admin',
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Submit for verification',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _accent,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _muted.withValues(alpha: 0.6),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: _field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  static const List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _fmtDate(DateTime d) =>
      '${d.day} ${_monthNames[d.month]} ${d.year}';

  Widget _buildDateField({
    required DateTime? value,
    required String placeholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: _muted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value != null ? _fmtDate(value) : placeholder,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value != null
                      ? _ink
                      : _muted.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    color: _muted, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return InkWell(
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _photoFile == null ? _border : _accent,
            width: _photoFile == null ? 1 : 2,
            style: _photoFile == null
                ? BorderStyle.solid
                : BorderStyle.solid,
          ),
          image: _photoFile != null
              ? DecorationImage(
                  image: FileImage(_photoFile!), fit: BoxFit.cover)
              : null,
        ),
        child: _photoFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: _muted.withValues(alpha: 0.7), size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to upload certificate photo',
                    style: TextStyle(
                      fontSize: 13,
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG/PNG, max ~5MB',
                    style: TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Change',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }
}
