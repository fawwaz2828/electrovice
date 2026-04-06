import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/technician_service.dart';

class TechnicianProfileEditPage extends StatefulWidget {
  const TechnicianProfileEditPage({super.key});

  @override
  State<TechnicianProfileEditPage> createState() =>
      _TechnicianProfileEditPageState();
}

class _TechnicianProfileEditPageState
    extends State<TechnicianProfileEditPage> {
  final _authService = AuthService();
  final _technicianService = TechnicianService();

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  String _category = 'electronic';
  int _yearsExperience = 0;
  double _serviceRadius = 10;
  bool _isLoading = false;
  bool _isFetching = true;

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF2F3F7);
  static const Color _accent = Color(0xFF3254FF);

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

    final tp = userModel.technicianProfile;
    setState(() {
      _nameController.text = userModel.name;
      _specialtyController.text = tp?.specialty ?? '';
      _bioController.text = tp?.bio ?? '';
      _category = tp?.category ?? 'electronic';
      _yearsExperience = tp?.yearsExperience ?? 0;
      _serviceRadius = tp?.serviceRadius ?? 10;
      _isFetching = false;
    });
  }

  Future<void> _save() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Nama tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _technicianService.updateTechnicianProfile(
        user.uid,
        name: _nameController.text.trim(),
        category: _category,
        specialty: _specialtyController.text.trim(),
        bio: _bioController.text.trim(),
        yearsExperience: _yearsExperience,
        serviceRadius: _serviceRadius,
      );

      Get.back();
      Get.snackbar('Berhasil', 'Profil berhasil disimpan',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
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
                      'Simpan',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('IDENTITAS', [
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      hint: 'Masukkan nama lengkap',
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('KATEGORI LAYANAN', [
                    _buildCategoryToggle(),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('KEAHLIAN', [
                    _buildField(
                      label: 'Specialty',
                      controller: _specialtyController,
                      hint: 'Contoh: Laptop & Micro-soldering',
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Bio',
                      controller: _bioController,
                      hint: 'Ceritakan keahlian dan pengalaman kamu...',
                      maxLines: 4,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('PENGALAMAN', [
                    _buildYearsSelector(),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('RADIUS LAYANAN', [
                    _buildRadiusSlider(),
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
                color: Colors.black.withOpacity(0.04),
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
    int maxLines = 1,
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
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _muted.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryToggle() {
    return Row(
      children: [
        _categoryChip('electronic', Icons.devices_rounded, 'Elektronik'),
        const SizedBox(width: 12),
        _categoryChip('vehicle', Icons.directions_car_rounded, 'Kendaraan'),
      ],
    );
  }

  Widget _categoryChip(String value, IconData icon, String label) {
    final bool selected = _category == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _accent : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : _muted, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearsSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tahun Pengalaman',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        Row(
          children: [
            _counterButton(
              icon: Icons.remove,
              onTap: () {
                if (_yearsExperience > 0) {
                  setState(() => _yearsExperience--);
                }
              },
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$_yearsExperience',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ),
            _counterButton(
              icon: Icons.add,
              onTap: () => setState(() => _yearsExperience++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _counterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: _ink),
      ),
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jarak Maksimal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            Text(
              '${_serviceRadius.toInt()} km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _accent,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: _accent,
            overlayColor: _accent.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: _serviceRadius,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: (val) => setState(() => _serviceRadius = val),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 km', style: TextStyle(fontSize: 11, color: _muted)),
            Text('50 km', style: TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ],
    );
  }
}