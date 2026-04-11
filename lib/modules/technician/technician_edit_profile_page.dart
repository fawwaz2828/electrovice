import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'technician_controller.dart';

class TechnicianEditProfilePage extends StatefulWidget {
  const TechnicianEditProfilePage({super.key});

  @override
  State<TechnicianEditProfilePage> createState() => _TechnicianEditProfilePageState();
}

class _TechnicianEditProfilePageState extends State<TechnicianEditProfilePage> {
  final TechnicianController controller = Get.find<TechnicianController>();
  
  late TextEditingController nameController;
  late TextEditingController specialtyController;
  late TextEditingController bioController;
  late TextEditingController addressController;
  
  final List<TextEditingController> _certsControllers = [];
  String? _currentAvatarUrl;

  static const Color _ink = Color(0xFF0F172A);
  static const Color _blue = Color(0xFF3254FF);

  @override
  void initState() {
    super.initState();
    final profile = controller.profile.value;
    nameController = TextEditingController(text: profile?.fullName);
    specialtyController = TextEditingController(text: profile?.specialty);
    bioController = TextEditingController(text: profile?.description);
    addressController = TextEditingController(text: profile?.address);
    _currentAvatarUrl = profile?.avatarUrl;

    if (profile?.certifications != null) {
      for (var cert in profile!.certifications) {
        _certsControllers.add(TextEditingController(text: cert));
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    bioController.dispose();
    addressController.dispose();
    for (var c in _certsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCertification() {
    setState(() {
      _certsControllers.add(TextEditingController());
    });
  }

  void _removeCertification(int index) {
    setState(() {
      _certsControllers[index].dispose();
      _certsControllers.removeAt(index);
    });
  }

  void _showAvatarPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption('https://images.unsplash.com/photo-1540560714873-1219c488f51a?w=400'),
                _buildAvatarOption('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400'),
                _buildAvatarOption('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400'),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String url) {
    return InkWell(
      onTap: () {
        setState(() => _currentAvatarUrl = url);
        Get.back();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: _currentAvatarUrl == url ? Border.all(color: _blue, width: 3) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Professional Profile',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final certs = _certsControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();
              controller.updateProfileInfo(
                fullName: nameController.text,
                specialty: specialtyController.text,
                description: bioController.text,
                certifications: certs,
                address: addressController.text,
                avatarUrl: _currentAvatarUrl,
              );
              Get.back();
              Get.snackbar(
                'Success',
                'Profile updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
              );
            },
            child: const Text('SAVE', style: TextStyle(color: _blue, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: _showAvatarPicker,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(30),
                            image: _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(_currentAvatarUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _currentAvatarUrl == null || _currentAvatarUrl!.isEmpty
                              ? const Center(child: Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 60))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: _blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap photo to change', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Professional Title', Icons.work_rounded),
            const SizedBox(height: 12),
            _buildTextField(controller: specialtyController, hint: 'e.g. LAPTOP REPAIR SPECIALIST'),
            const SizedBox(height: 24),

            _buildSectionHeader('Professional Bio', Icons.description_rounded),
            const SizedBox(height: 12),
            _buildTextField(controller: bioController, hint: 'Describe your expertise...', maxLines: 4),
            const SizedBox(height: 24),

            _buildSectionHeader('Certifications', Icons.verified_rounded),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _certsControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _certsControllers[index], hint: 'e.g. Cisco CCNA Certified')),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _removeCertification(index),
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFE11D48)),
                      ),
                    ],
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _addCertification,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('Add Certification Point', style: TextStyle(fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(foregroundColor: _blue, padding: EdgeInsets.zero),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Service Address', Icons.location_on_rounded),
            const SizedBox(height: 12),
            _buildTextField(controller: addressController, hint: 'Where are you based?', maxLines: 2),
            
            const SizedBox(height: 40),
            
            _buildInfoBox(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _ink, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: _ink, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _blue, width: 2)),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
          SizedBox(width: 12),
          Expanded(child: Text('This information will be visible to potential customers searching for your services.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.4))),
        ],
      ),
    );
  }
}
