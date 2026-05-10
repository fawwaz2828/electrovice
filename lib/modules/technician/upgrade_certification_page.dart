import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/routes.dart';

class UpgradeCertificationPage extends StatefulWidget {
  const UpgradeCertificationPage({super.key});

  @override
  State<UpgradeCertificationPage> createState() =>
      _UpgradeCertificationPageState();
}

class _UpgradeCertificationPageState extends State<UpgradeCertificationPage> {
  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF2F3F7);
  static const Color _accent = Color(0xFF3254FF);

  final _imagePicker = ImagePicker();
  File? _certificateFile;
  bool _isUploading = false;

  Future<void> _pickCertificate() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _certificateFile = File(picked.path);
      _isUploading = true;
    });

    // Local/dummy storage only — simulate brief upload delay
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isUploading = false);
    Get.snackbar(
      'Saved',
      'Certificate stored locally. Final submission will sync once online.',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _goToRegistration() {
    Get.toNamed(AppRoutes.certificationRegistration);
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
          'Upgrade Certification',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero card ──────────────────────────────────────
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
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: _accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Become a certified technician',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload your certificate if you already have one, '
                      'or register for a new certification exam.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _muted,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Upload section ─────────────────────────────────
              const Text(
                'I ALREADY HAVE A CERTIFICATE',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_certificateFile != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _certificateFile!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF16A34A), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _certificateFile!.path.split(Platform.pathSeparator).last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickCertificate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload_file_rounded, size: 20),
                        label: Text(
                          _certificateFile == null
                              ? 'Upload Certificate'
                              : 'Replace Certificate',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Accepted: JPG, PNG. Stored locally for now.',
                      style: TextStyle(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ────────────────────────────────────────
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 24),

              // ── Register section ───────────────────────────────
              const Text(
                'I DON\'T HAVE A CERTIFICATE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _goToRegistration,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _ink, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: _accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register for certification here',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'LSP Automotive or LSP Digital/Computer.\n'
                              'Remote exam, fully online.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _muted,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
