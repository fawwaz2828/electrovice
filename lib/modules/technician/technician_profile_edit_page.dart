import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/technician_service.dart';
import '../../config/routes.dart';
import '../../widgets/skeleton_widgets.dart';

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
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();
  final _workshopAddressController = TextEditingController();
  final _diagnosisFeeController = TextEditingController();

  // State
  List<String> _deviceCategories = [];
  List<String> _serviceMethod = [];
  int _yearsExperience = 0;
  double _serviceRadius = 10;
  bool _isAvailable = false;
  double? _lat;
  double? _lng;
  List<String> _accreditations = [];
  /// Existing certification photo URLs (from Firestore), parallel to _accreditations.
  /// Read-only di halaman ini — edit dilakukan via "Upgrade Certification".
  List<String> _certUrls = [];
  List<Map<String, dynamic>> _serviceEstimates = [];
  String? _currentPhotoUrl;
  File? _newPhotoFile;
  bool _isLoading = false;
  bool _isFetching = true;

  static const Color _ink = Color(0xFF0A0A0A);
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

    // Load dari users collection
    final userModel = await _authService.getUserModel(user.uid);

    // Load dari technicians_online collection
    final techOnline =
        await _technicianService.getTechnicianDetail(user.uid);

    if (userModel == null) return;

    final tp = userModel.technicianProfile;

    setState(() {
      _nameController.text = userModel.name;
      _phoneController.text = userModel.phone ?? '';
      _currentPhotoUrl = userModel.photoUrl;
      _specialtyController.text = tp?.specialty ?? '';
      _bioController.text = tp?.bio ?? '';
      _yearsExperience = tp?.yearsExperience ?? 0;
      _serviceRadius = tp?.serviceRadius ?? 10;

      if (techOnline != null) {
        _isAvailable = techOnline.isAvailable;
        _workshopAddressController.text = techOnline.workshopAddress;
        _deviceCategories = List.from(techOnline.deviceCategories);
        _serviceMethod = List.from(techOnline.serviceMethod);
        _accreditations = List.from(techOnline.accreditations);
        _certUrls = List.from(techOnline.certificationUrls);
        while (_certUrls.length < _accreditations.length) {
          _certUrls.add('');
        }
        if (techOnline.diagnosisFee > 0) {
          _diagnosisFeeController.text = techOnline.diagnosisFee.toString();
        }
        _serviceEstimates = techOnline.serviceEstimates
            .map((e) => {
                  'service': e.service,
                  'minPrice': e.minPrice,
                  'maxPrice': e.maxPrice,
                })
            .toList();
        // Restore koordinat yang sudah disimpan sebelumnya
        if (techOnline.lat != null && techOnline.lng != null) {
          _lat = techOnline.lat;
          _lng = techOnline.lng;
        }
      }

      _isFetching = false;
    });
  }

  Future<void> _save() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Name cannot be empty',
          snackPosition: SnackPosition.TOP);
      return;
    }

    if (_lat == null || _lng == null) {
      Get.snackbar('Oops', 'Please select a workshop location on the map first',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final diagFee = int.tryParse(
              _diagnosisFeeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;

      // Upload profile photo jika ada yang baru
      if (_newPhotoFile != null) {
        final newUrl =
            await _storageService.uploadProfilePhoto(user.uid, _newPhotoFile!);
        await _authService.updateUserPhoto(user.uid, newUrl);
      }

      // Sertifikat tidak lagi diedit di halaman ini — kirim apa adanya
      // agar tidak overwrite data existing. Submit/edit sertifikat
      // dilakukan via halaman "Upgrade Certification".
      await _technicianService.updateTechnicianProfile(
        user.uid,
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        bio: _bioController.text.trim(),
        yearsExperience: _yearsExperience,
        serviceRadius: _serviceRadius,
        isAvailable: _isAvailable,
        workshopAddress: _workshopAddressController.text.trim(),
        lat: _lat!,
        lng: _lng!,
        accreditations: _accreditations,
        certificationUrls: _certUrls,
        serviceEstimates: _serviceEstimates,
        diagnosisFee: diagFee,
        deviceCategories: _deviceCategories,
        serviceMethod: _serviceMethod,
      );

      await _authService.updateUserProfile(
        user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      Get.back();
      Get.snackbar('Success', 'Profile saved successfully',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Get.toNamed(AppRoutes.mapboxLocationPicker);
    if (result != null && result is Map) {
      setState(() {
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _newPhotoFile = File(picked.path));
    }
  }

  void _removeServiceEstimate(int index) {
    setState(() => _serviceEstimates.removeAt(index));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _workshopAddressController.dispose();
    _diagnosisFeeController.dispose();
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
          ? const _TechProfileEditSkeleton()
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FOTO PROFIL ────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 24),

                  // ── IDENTITAS ──────────────────────────────────
                  _buildSection('IDENTITY', [
                    _buildField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Enter full name',
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: 'Example: +1234567890',
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── KETERSEDIAAN ───────────────────────────────
                  _buildSection('AVAILABILITY', [
                    _buildAvailabilityToggle(),
                  ]),
                  const SizedBox(height: 24),

                  // ── SERVICE CATEGORIES ─────────────────────────
                  _buildSection('SERVICE CATEGORIES', [
                    _buildServiceCategoriesCheckboxes(),
                  ]),
                  const SizedBox(height: 24),

                  // ── SERVICE METHOD ──────────────────────────────
                  _buildSection('SERVICE METHOD', [
                    _buildServiceMethodCards(),
                  ]),
                  const SizedBox(height: 24),

                  // ── KEAHLIAN ───────────────────────────────────
                  _buildSection('SKILLS', [
                    _buildField(
                      label: 'Specialty',
                      controller: _specialtyController,
                      hint: 'Example: Laptop & Micro-soldering',
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Bio',
                      controller: _bioController,
                      hint: 'Tell us about your skills and experience...',
                      maxLines: 4,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── PENGALAMAN ─────────────────────────────────
                  _buildSection('EXPERIENCE', [
                    _buildYearsSelector(),
                  ]),
                  const SizedBox(height: 24),

                  // ── SERTIFIKASI ────────────────────────────────
                  _buildSection('CERTIFICATIONS & ACCREDITATIONS', [
                    _buildAccreditationSection(),
                  ]),
                  const SizedBox(height: 24),

                  // ── BIAYA DIAGNOSA ─────────────────────────────
                  _buildSection('DIAGNOSIS FEE', [
                    _buildField(
                      label: 'Initial Diagnosis Fee (Rp)',
                      controller: _diagnosisFeeController,
                      hint: 'Example: 50000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This fee automatically appears as the first item in your service list.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _muted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── SERVICE ESTIMATE ───────────────────────────
                  _buildSection('SERVICE ESTIMATE', [
                    _buildServiceEstimateSection(),
                  ]),
                  const SizedBox(height: 24),

                  // ── LOKASI WORKSHOP ────────────────────────────
                  _buildSection('WORKSHOP LOCATION', [
                    _buildLocationSection(),
                  ]),
                  const SizedBox(height: 24),

                  // ── RADIUS LAYANAN ─────────────────────────────
                  _buildSection('SERVICE RADIUS', [
                    _buildRadiusSlider(),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ── SECTION WRAPPER ──────────────────────────────────────────────
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF0A0A0A), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  // ── AVAILABILITY TOGGLE ──────────────────────────────────────────
  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accept Orders',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isAvailable ? 'You are online' : 'You are offline',
              style: TextStyle(
                fontSize: 12,
                color: _isAvailable
                    ? Color(0xFF16A34A)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Switch(
          value: _isAvailable,
          onChanged: (val) => setState(() => _isAvailable = val),
          activeThumbColor: _accent,
        ),
      ],
    );
  }

  // ── ACCREDITATION SECTION (read-only, edit via Upgrade page) ────
  Widget _buildAccreditationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_accreditations.isNotEmpty) ...[
          ..._accreditations.asMap().entries.map((entry) {
            final i = entry.key;
            final name = entry.value;
            final url = i < _certUrls.length ? _certUrls[i] : '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: url.isNotEmpty
                        ? Image.network(url,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _certPlaceholder())
                        : _certPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ] else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No certificates yet. Tap the button below to submit a certificate and earn the "certified" badge.',
              style: TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        const SizedBox(height: 10),

        // CTA → halaman submit sertifikat (di luar edit profile)
        InkWell(
          onTap: () => Get.toNamed(AppRoutes.upgradeCertification),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: _accent, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Submit a new certificate via "Upgrade Certification"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _accent, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _certPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFFE2E8F0),
      child: const Icon(Icons.workspace_premium_rounded,
          size: 22, color: Color(0xFF94A3B8)),
    );
  }

  // ── SERVICE ESTIMATE SECTION ─────────────────────────────────────
  Widget _buildServiceEstimateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing estimates
        if (_serviceEstimates.isNotEmpty) ...[
          ..._serviceEstimates.asMap().entries.map((entry) {
            final est = entry.value;
            final minPrice = est['minPrice'] as int;
            final maxPrice = est['maxPrice'] as int;
            final priceLabel = minPrice == maxPrice
                ? 'Rp$minPrice'
                : 'Rp$minPrice - Rp$maxPrice';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          est['service'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          priceLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeServiceEstimate(entry.key),
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: Color(0xFFE11D48)),
                    splashRadius: 22,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Remove estimate',
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

      ],
    );
  }

  // ── LOCATION SECTION ─────────────────────────────────────────────
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: 'Workshop Address',
          controller: _workshopAddressController,
          hint: '123 Main St, City',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Map picker button
        GestureDetector(
          onTap: _openMapPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _lat != null
                  ? Color(0xFFEEF2FF)
                  : const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _lat != null
                    ? _accent.withOpacity(0.3)
                    : Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _lat != null
                      ? Icons.location_on_rounded
                      : Icons.add_location_alt_rounded,
                  color: _lat != null ? _accent : _muted,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _lat != null
                        ? '${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}'
                        : 'Pick location on map',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _lat != null ? _accent : _muted,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        if (_lat != null) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 14, color: Color(0xFF16A34A)),
              SizedBox(width: 6),
              Text(
                'Location selected successfully',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── FIELD ────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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
            fillColor: Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ── SERVICE CATEGORIES CHECKBOXES ───────────────────────────────
  static const _categoryOptions = [
    ('Laptop',         'laptop',      Icons.laptop_rounded),
    ('Smartphone',     'smartphone',  Icons.smartphone_rounded),
    ('Home Appliance', 'appliance',   Icons.kitchen_rounded),
    ('AC & Cooling',   'ac',          Icons.ac_unit_rounded),
    ('TV & Display',   'tv',          Icons.tv_rounded),
    ('Vehicles',       'vehicle',     Icons.directions_car_rounded),
    ('Other',          'other',       Icons.build_circle_outlined),
  ];

  Widget _buildServiceCategoriesCheckboxes() {
    return Column(
      children: _categoryOptions.map((opt) {
        final label = opt.$1;
        final key   = opt.$2;
        final icon  = opt.$3;
        final selected = _deviceCategories.contains(key);
        return InkWell(
          onTap: () => setState(() {
            if (selected) {
              _deviceCategories.remove(key);
            } else {
              _deviceCategories.add(key);
            }
          }),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? _accent.withValues(alpha: 0.12)
                        : Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      size: 18,
                      color: selected ? _accent : _muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? _ink : _muted,
                    ),
                  ),
                ),
                Checkbox(
                  value: selected,
                  onChanged: (_) => setState(() {
                    if (selected) {
                      _deviceCategories.remove(key);
                    } else {
                      _deviceCategories.add(key);
                    }
                  }),
                  activeColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: selected ? _accent : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── SERVICE METHOD CARDS ─────────────────────────────────────────
  Widget _buildServiceMethodCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You can select both',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _serviceMethodCard(
              key: 'pickup',
              title: 'Pick-up',
              subtitle: 'Collect from\ncustomer location',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(width: 10),
            _serviceMethodCard(
              key: 'dropoff',
              title: 'Drop-in',
              subtitle: 'Accept visits at\nyour workshop',
              icon: Icons.store_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceMethodCard({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _serviceMethod.contains(key);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          if (selected) {
            _serviceMethod.remove(key);
          } else {
            _serviceMethod.add(key);
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? _accent.withValues(alpha: 0.08)
                : Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? _accent : _muted),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? _accent : _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: _muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── YEARS SELECTOR ───────────────────────────────────────────────
  Widget _buildYearsSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Years of Experience',
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

  Widget _counterButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: _ink),
      ),
    );
  }

  // ── RADIUS SLIDER ────────────────────────────────────────────────
  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Maximum Distance',
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
            inactiveTrackColor: Color(0xFFE2E8F0),
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
            Text('1 km',
                style: TextStyle(fontSize: 11, color: _muted)),
            Text('50 km',
                style: TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ],
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
class _TechProfileEditSkeleton extends StatelessWidget {
  const _TechProfileEditSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SkeletonBox(width: 100, height: 100, radius: 16)),
            const SizedBox(height: 24),
            _sectionSkeleton(fieldCount: 2),
            const SizedBox(height: 24),
            _sectionSkeleton(fieldCount: 1),
            const SizedBox(height: 24),
            _sectionSkeleton(fieldCount: 3),
            const SizedBox(height: 24),
            _sectionSkeleton(fieldCount: 2),
            const SizedBox(height: 24),
            _sectionSkeleton(fieldCount: 1),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionSkeleton({required int fieldCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 100, height: 11, radius: 6),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF0A0A0A), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(fieldCount * 2 - 1, (i) {
              if (i.isOdd) return const SizedBox(height: 16);
              return const SkeletonLabelField();
            }),
          ),
        ),
      ],
    );
  }
}