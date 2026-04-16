import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/technician_service.dart';
import '../../config/routes.dart';

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
  final _newAccreditationController = TextEditingController();

  // State
  String _category = 'electronic';
  int _yearsExperience = 0;
  double _serviceRadius = 10;
  bool _isAvailable = false;
  double? _lat;
  double? _lng;
  List<String> _accreditations = [];
  /// Existing certification photo URLs (from Firestore), parallel to _accreditations
  List<String> _certUrls = [];
  /// New photo files to upload (null = keep existing URL, if any)
  List<File?> _certNewFiles = [];
  List<Map<String, dynamic>> _serviceEstimates = [];
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
      _specialtyController.text = tp?.specialty ?? '';
      _bioController.text = tp?.bio ?? '';
      _category = tp?.category ?? 'electronic';
      _yearsExperience = tp?.yearsExperience ?? 0;
      _serviceRadius = tp?.serviceRadius ?? 10;

      if (techOnline != null) {
        _isAvailable = techOnline.isAvailable;
        _workshopAddressController.text = techOnline.workshopAddress;
        _accreditations = List.from(techOnline.accreditations);
        _certUrls = List.from(techOnline.certificationUrls);
        // Pad _certNewFiles and _certUrls to match _accreditations length
        while (_certUrls.length < _accreditations.length) { _certUrls.add(''); }
        _certNewFiles = List.filled(_accreditations.length, null);
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
      Get.snackbar('Oops', 'Nama tidak boleh kosong',
          snackPosition: SnackPosition.TOP);
      return;
    }

    if (_lat == null || _lng == null) {
      Get.snackbar('Oops', 'Pilih lokasi workshop di peta dulu',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final diagFee = int.tryParse(
              _diagnosisFeeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;

      // Upload any new cert photos and build final URL list
      final List<String> finalCertUrls = [];
      for (int i = 0; i < _accreditations.length; i++) {
        final newFile = i < _certNewFiles.length ? _certNewFiles[i] : null;
        if (newFile != null) {
          final uploaded = await _storageService.uploadCertifications(
              user.uid, [newFile]);
          finalCertUrls.add(uploaded.isNotEmpty ? uploaded.first : '');
        } else {
          finalCertUrls.add(i < _certUrls.length ? _certUrls[i] : '');
        }
      }

      await _technicianService.updateTechnicianProfile(
        user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        category: _category,
        specialty: _specialtyController.text.trim(),
        bio: _bioController.text.trim(),
        yearsExperience: _yearsExperience,
        serviceRadius: _serviceRadius,
        isAvailable: _isAvailable,
        workshopAddress: _workshopAddressController.text.trim(),
        lat: _lat!,
        lng: _lng!,
        accreditations: _accreditations,
        certificationUrls: finalCertUrls,
        serviceEstimates: _serviceEstimates,
        diagnosisFee: diagFee,
      );

      // Update diagnosisFee juga di users collection jika ada
      if (_phoneController.text.trim().isNotEmpty) {
        await _authService.updateUserProfile(
          user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      Get.back();
      Get.snackbar('Berhasil', 'Profil berhasil disimpan',
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

  void _addAccreditation() {
    final text = _newAccreditationController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _accreditations.add(text);
      _certUrls.add('');
      _certNewFiles.add(null);
      _newAccreditationController.clear();
    });
  }

  void _removeAccreditation(int index) {
    setState(() {
      _accreditations.removeAt(index);
      if (index < _certUrls.length) _certUrls.removeAt(index);
      if (index < _certNewFiles.length) _certNewFiles.removeAt(index);
    });
  }

  Future<void> _pickCertPhoto(int index) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        while (_certNewFiles.length <= index) { _certNewFiles.add(null); }
        _certNewFiles[index] = File(picked.path);
      });
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
    _newAccreditationController.dispose();
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── IDENTITAS ──────────────────────────────────
                  _buildSection('IDENTITAS', [
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      hint: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Nomor HP',
                      controller: _phoneController,
                      hint: 'Contoh: 08123456789',
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── KETERSEDIAAN ───────────────────────────────
                  _buildSection('KETERSEDIAAN', [
                    _buildAvailabilityToggle(),
                  ]),
                  const SizedBox(height: 24),

                  // ── KATEGORI ───────────────────────────────────
                  _buildSection('KATEGORI LAYANAN', [
                    _buildCategoryToggle(),
                  ]),
                  const SizedBox(height: 24),

                  // ── KEAHLIAN ───────────────────────────────────
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

                  // ── PENGALAMAN ─────────────────────────────────
                  _buildSection('PENGALAMAN', [
                    _buildYearsSelector(),
                  ]),
                  const SizedBox(height: 24),

                  // ── SERTIFIKASI ────────────────────────────────
                  _buildSection('SERTIFIKASI & AKREDITASI', [
                    _buildAccreditationSection(),
                  ]),
                  const SizedBox(height: 24),

                  // ── BIAYA DIAGNOSA ─────────────────────────────
                  _buildSection('BIAYA DIAGNOSA', [
                    _buildField(
                      label: 'Biaya Diagnosa Awal (Rp)',
                      controller: _diagnosisFeeController,
                      hint: 'Contoh: 50000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Biaya ini otomatis muncul sebagai item pertama di daftar layananmu.',
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
                  _buildSection('LOKASI WORKSHOP', [
                    _buildLocationSection(),
                  ]),
                  const SizedBox(height: 24),

                  // ── RADIUS LAYANAN ─────────────────────────────
                  _buildSection('RADIUS LAYANAN', [
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

  // ── AVAILABILITY TOGGLE ──────────────────────────────────────────
  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terima Pesanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isAvailable ? 'Kamu sedang online' : 'Kamu sedang offline',
              style: TextStyle(
                fontSize: 12,
                color: _isAvailable
                    ? const Color(0xFF16A34A)
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

  // ── ACCREDITATION SECTION ────────────────────────────────────────
  Widget _buildAccreditationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing certs with photo
        if (_accreditations.isNotEmpty) ...[
          ..._accreditations.asMap().entries.map((entry) {
            final i = entry.key;
            final name = entry.value;
            final newFile = i < _certNewFiles.length ? _certNewFiles[i] : null;
            final existingUrl = i < _certUrls.length ? _certUrls[i] : '';
            final hasPhoto = newFile != null || existingUrl.isNotEmpty;

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
                  // Photo thumbnail / upload button
                  GestureDetector(
                    onTap: () => _pickCertPhoto(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasPhoto
                          ? (newFile != null
                              ? Image.file(newFile,
                                  width: 52, height: 52, fit: BoxFit.cover)
                              : Image.network(existingUrl,
                                  width: 52, height: 52, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _certPlaceholder()))
                          : _certPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _pickCertPhoto(i),
                          child: Text(
                            hasPhoto ? 'Ganti foto' : 'Upload foto sertifikat',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeAccreditation(i),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: Color(0xFFE11D48)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // Add new cert name
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newAccreditationController,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Contoh: Apple Certified',
                  hintStyle: TextStyle(
                    color: _muted.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _addAccreditation,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _certPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFFE2E8F0),
      child: const Icon(Icons.upload_file_outlined,
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
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(10),
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
                  GestureDetector(
                    onTap: () => _removeServiceEstimate(entry.key),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: Color(0xFFE11D48)),
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
          label: 'Alamat Workshop',
          controller: _workshopAddressController,
          hint: 'Jl. Contoh No. 1, Kota',
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
                  ? const Color(0xFFEEF2FF)
                  : const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _lat != null
                    ? _accent.withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
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
                        : 'Pilih lokasi di peta',
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
                'Lokasi berhasil dipilih',
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

  // ── CATEGORY TOGGLE ──────────────────────────────────────────────
  Widget _buildCategoryToggle() {
    return Row(
      children: [
        _categoryChip('electronic', Icons.devices_rounded, 'Elektronik'),
        const SizedBox(width: 12),
        _categoryChip(
            'vehicle', Icons.directions_car_rounded, 'Kendaraan'),
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

  // ── YEARS SELECTOR ───────────────────────────────────────────────
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

  Widget _counterButton(
      {required IconData icon, required VoidCallback onTap}) {
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

  // ── RADIUS SLIDER ────────────────────────────────────────────────
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