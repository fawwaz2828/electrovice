import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'profile_controller.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _authService = AuthService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _currentPhotoUrl;
  File? _newPhotoFile;

  bool _isLoading = false;
  bool _isFetching = true;

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _accent = Color(0xFF0061FF);

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final userModel = await _authService.getUserModel(user.uid);
    if (userModel == null) return;

    setState(() {
      _nameController.text = userModel.name;
      _phoneController.text = userModel.phone ?? '';
      _currentPhotoUrl = userModel.photoUrl;
      _isFetching = false;
    });
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _newPhotoFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Name cannot be empty',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_newPhotoFile != null) {
        final newUrl =
            await _storageService.uploadProfilePhoto(user.uid, _newPhotoFile!);
        await _authService.updateUserPhoto(user.uid, newUrl);
      }

      await _authService.updateUserProfile(
        user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Refresh data di ProfileController
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().reloadProfile();
      }

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          'Edit Profile',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar with upload ─────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _newPhotoFile != null
                                  ? Image.file(_newPhotoFile!,
                                      fit: BoxFit.cover)
                                  : (_currentPhotoUrl != null &&
                                          _currentPhotoUrl!.isNotEmpty)
                                      ? Image.network(_currentPhotoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.person_rounded,
                                                  color: Color(0xFF94A3B8),
                                                  size: 52))
                                      : const Icon(Icons.person_rounded,
                                          color: Color(0xFF94A3B8), size: 52),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── IDENTITAS ──────────────────────────────────
                  _buildSection('IDENTITY', [
                    _buildField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Enter full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: 'Example: +1234567890',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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
            prefixIcon: Icon(icon, color: _muted, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
