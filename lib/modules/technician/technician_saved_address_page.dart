import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/technician_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../../widgets/skeleton_widgets.dart';

class TechnicianSavedAddressPage extends StatefulWidget {
  const TechnicianSavedAddressPage({super.key});

  @override
  State<TechnicianSavedAddressPage> createState() =>
      _TechnicianSavedAddressPageState();
}

class _TechnicianSavedAddressPageState
    extends State<TechnicianSavedAddressPage> {
  final _authService = AuthService();
  final _techService = TechnicianService();
  final _addressCtrl = TextEditingController();

  double? _lat;
  double? _lng;
  bool _isFetching = true;
  bool _isSaving = false;

  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _bg = Color(0xFFF2F3F7);
  static const Color _accent = Color(0xFF3254FF);

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final user = _authService.currentUser;
    if (user == null) { setState(() => _isFetching = false); return; }

    final techOnline = await _techService.getTechnicianDetail(user.uid);
    if (!mounted) return;

    setState(() {
      _addressCtrl.text = techOnline?.workshopAddress ?? '';
      _lat = techOnline?.lat;
      _lng = techOnline?.lng;
      _isFetching = false;
    });
  }

  Future<void> _openMapPicker() async {
    final result = await Get.toNamed(AppRoutes.mapboxLocationPicker);
    if (result != null && result is Map) {
      setState(() {
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
        if (result['address'] != null &&
            (result['address'] as String).isNotEmpty) {
          _addressCtrl.text = result['address'] as String;
        }
      });
    }
  }

  Future<void> _save() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_addressCtrl.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Address cannot be empty',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_lat == null || _lng == null) {
      Get.snackbar('Oops', 'Please select a location on the map first',
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Update hanya field address & koordinat di technicians_online
      await _techService.updateWorkshopAddress(
        uid: user.uid,
        address: _addressCtrl.text.trim(),
        lat: _lat!,
        lng: _lng!,
      );
      Get.back();
      Get.snackbar('Success', 'Workshop address saved successfully',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar:
          const TechnicianNavBar(selectedItem: AppNavItem.profile),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isSaving
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
          ? const _SavedAddressSkeleton()
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section label ──────────────────────────────────
                  const Text(
                    'WORKSHOP LOCATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Card ───────────────────────────────────────────
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
                      children: [
                        // Address field
                        const Text(
                          'Workshop Address',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _addressCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Example: 123 Main St, District, City',
                            hintStyle: TextStyle(
                              color: _muted.withValues(alpha: 0.5),
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
                                    ? _accent.withValues(alpha: 0.3)
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _lat != null ? _accent : _muted,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: _muted, size: 20),
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
                                'Coordinates saved',
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
                    ),
                  ),

                  const SizedBox(height: 24),
                  // ── Info ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: _accent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This address is used by customers to find your workshop '
                            'and is displayed on the technician profile page.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _accent,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  SAVED ADDRESS SKELETON
// ─────────────────────────────────────────────────────────────────
class _SavedAddressSkeleton extends StatelessWidget {
  const _SavedAddressSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 140, height: 11, radius: 6),
            const SizedBox(height: 12),
            SkeletonCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 12, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(height: 80, radius: 10),
                  SizedBox(height: 16),
                  SkeletonBox(height: 48, radius: 10),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SkeletonBox(height: 64, radius: 14),
          ],
        ),
      ),
    );
  }
}
