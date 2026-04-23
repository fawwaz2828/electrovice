import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../config/routes.dart';
import '../technician/onboarding/onboarding_controller.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
const _bg = Color(0xFFF8F9FD);
const _surface = Colors.white;
const _card = Colors.white;
const _border = Color(0xFFE2E8F0);
const _white = Color(0xFF0A0A0A);
const _secondary = Color(0xFF64748B);
const _hint = Color(0xFF94A3B8);

const _stepLabels = [
  'Personal',
  'Identity',
  'Location',
  'Skills',
  'Pricing',
  'Review',
];

// ─────────────────────────────────────────────────────────────────────────────
class TechnicianOnboardingPage extends GetView<TechnicianOnboardingController> {
  const TechnicianOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Obx(
          () => IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _white, size: 20),
            onPressed: controller.currentStep.value > 0
                ? controller.prevStep
                : () => Get.back(),
          ),
        ),
        title: Obx(
          () => Text(
            'Step ${controller.currentStep.value + 1} of 6  •  ${_stepLabels[controller.currentStep.value]}',
            style: const TextStyle(
              color: _secondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _StepIndicator(ctrl: controller),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.currentStep.value,
                children: [
                  _Step1(ctrl: controller),
                  _Step2(ctrl: controller),
                  _Step3(ctrl: controller),
                  _Step4(ctrl: controller),
                  _Step5(ctrl: controller),
                  _Step6(ctrl: controller),
                ],
              ),
            ),
          ),
          _BottomBar(ctrl: controller),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _StepIndicator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = ctrl.currentStep.value;
      return Container(
        color: _surface,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            for (int i = 0; i < 6; i++) ...[
              _StepDot(index: i, isActive: i == step, isDone: i < step),
              if (i < 5)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: i < step ? _white : _border,
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDone;
  const _StepDot(
      {required this.index, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Widget child;

    if (isDone) {
      bg = _white;
      child = const Icon(Icons.check_rounded, size: 12, color: Colors.white);
    } else if (isActive) {
      bg = _white;
      child = Text(
        '${index + 1}',
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
      );
    } else {
      bg = _border;
      child = Text(
        '${index + 1}',
        style: const TextStyle(fontSize: 11, color: _secondary),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _BottomBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = ctrl.currentStep.value;
      final isLast = step == 5;
      final isSubmitting = ctrl.isSubmitting.value;

      return Container(
        color: _surface,
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ctrl.submitError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  ctrl.submitError.value,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              children: [
                if (step > 0) ...[
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : ctrl.prevStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _white,
                        side: const BorderSide(color: _border),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : isLast
                            ? ctrl.submitOnboarding
                            : ctrl.nextStep,
                    style: FilledButton.styleFrom(
                      backgroundColor: _white,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isLast ? 'Submit Registration →' : 'Continue →',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Personal Info
// ─────────────────────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step1({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Tell us about\nyourself',
            subtitle:
                'Please provide accurate information to build trust with your future clients.',
          ),
          const SizedBox(height: 32),

          // ── Profile Photo ──
          Center(
            child: Obx(() {
              final file = ctrl.profilePhotoFile.value;
              return GestureDetector(
                onTap: ctrl.pickProfilePhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _card,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: file != null
                              ? Colors.greenAccent.shade700
                              : _border,
                          width: 2,
                        ),
                      ),
                      child: file != null
                          ? ClipOval(
                              child: Image.file(file,
                                  fit: BoxFit.cover, width: 100, height: 100))
                          : const Icon(Icons.camera_alt_outlined,
                              color: _secondary, size: 38),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                              file != null ? Colors.greenAccent.shade700 : _white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _bg, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Color(0xFF0A0A0A), size: 15),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Profile Photo',
                style: TextStyle(
                    color: Color(0xFF6B9FFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          const Center(
            child: Text('Upload a clear, professional headshot.',
                style: TextStyle(color: _hint, fontSize: 11)),
          ),
          const SizedBox(height: 32),

          // ── Full Name ──
          _Label('FULL NAME'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.fullNameCtrl,
            hint: 'Johnathan Doe',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // ── Phone ──
          _Label('PHONE NUMBER'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.phoneCtrl,
            hint: '+1 (555) 000-0000',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 20),

          // ── Date of Birth ──
          _Label('DATE OF BIRTH'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ctrl.pickDob(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: _secondary, size: 20),
                  const SizedBox(width: 12),
                  Obx(() {
                    final hasDob = ctrl.dob.value != null;
                    return Text(
                      hasDob ? ctrl.dobCtrl.text : 'MM / DD / YYYY',
                      style: TextStyle(
                        color: hasDob ? _white : _hint,
                        fontSize: 14,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Gender ──
          _Label('GENDER'),
          const SizedBox(height: 10),
          Obx(() => Row(
                children: [
                  _GenderChip(
                    label: 'Male',
                    isSelected: ctrl.gender.value == 'male',
                    onTap: () => ctrl.gender.value = 'male',
                  ),
                  const SizedBox(width: 10),
                  _GenderChip(
                    label: 'Female',
                    isSelected: ctrl.gender.value == 'female',
                    onTap: () => ctrl.gender.value = 'female',
                  ),
                ],
              )),
          const SizedBox(height: 20),

          // ── Bio ──
          _Label('SHORT BIO'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.bioCtrl,
            hint: 'Describe your technical experience and specialization...',
            maxLines: 4,
            maxLength: 200,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _GenderChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _white : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _white : _border, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _secondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Identity
// ─────────────────────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step2({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Verify your\nidentity',
            subtitle:
                'Required to protect both customers and technicians. Your data is stored securely and never shared publicly.',
          ),
          const SizedBox(height: 28),
          _Label('NIK (ID NUMBER)'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.nikCtrl,
            hint: '16-digit NIK from your KTP',
            keyboardType: TextInputType.number,
            maxLength: 16,
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 6),
          const Text('Found on your national ID card (KTP)',
              style: TextStyle(color: _hint, fontSize: 11)),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.upload_file_outlined, color: _secondary, size: 16),
              const SizedBox(width: 6),
              _Label('UPLOAD KTP PHOTO'),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => _PhotoUploadCard(
                file: ctrl.ktpFile.value,
                label: 'Tap to Upload KTP',
                subLabel: 'JPG or PNG · max 5MB · must be clearly readable',
                icon: Icons.upload_file_outlined,
                onTap: ctrl.pickKtp,
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined, color: _secondary, size: 16),
              const SizedBox(width: 6),
              _Label('SELFIE HOLDING KTP'),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => _PhotoUploadCard(
                file: ctrl.selfieFile.value,
                label: 'Tap to take selfie',
                subLabel: 'Hold your KTP next to your face · good lighting',
                icon: Icons.face_outlined,
                onTap: ctrl.takeSelfie,
                secondaryLabel: 'or upload from gallery',
                onSecondaryTap: ctrl.pickSelfieFromGallery,
              )),
        ],
      ),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  final File? file;
  final String label;
  final String subLabel;
  final IconData icon;
  final VoidCallback onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const _PhotoUploadCard({
    required this.file,
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? Colors.greenAccent.shade700 : _border,
            width: 1.5,
            style: file != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: file != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('✓ Uploaded',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: _secondary, size: 30),
                  const SizedBox(height: 8),
                  Text(label,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subLabel,
                      style:
                          const TextStyle(color: _hint, fontSize: 11)),
                  if (secondaryLabel != null && onSecondaryTap != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onSecondaryTap,
                      child: Text(
                        secondaryLabel!,
                        style: const TextStyle(
                            color: Color(0xFF6B9FFF), fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Location
// ─────────────────────────────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step3({required this.ctrl});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const _radiusOptions = [
    ('1-3km', 3.0),
    ('Up to 5km', 5.0),
    ('10km', 10.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Where are\nyou based?',
            subtitle:
                'Define your operational hub and the distance you\'re willing to travel for service requests.',
          ),
          const SizedBox(height: 28),

          // ── City ──
          _Label('CITY/AREA'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.cityCtrl,
            hint: 'e.g. San Francisco, CA',
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 20),

          // ── Workshop Name ──
          _Label('WORKSHOP NAME (optional)'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.workshopNameCtrl,
            hint: 'AutoLab Precision',
            prefixIcon: Icons.store_outlined,
          ),
          const SizedBox(height: 20),

          // ── Workshop Address + Mini Map ──
          _Label('WORKSHOP ADDRESS'),
          const SizedBox(height: 8),
          _DarkField(
            controller: ctrl.workshopAddressCtrl,
            hint: 'Street address of your workshop',
            prefixIcon: Icons.place_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          _MiniMapPicker(ctrl: ctrl),
          const SizedBox(height: 20),

          // ── Service Radius ──
          _Label('SERVICE RADIUS'),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: _radiusOptions.map((r) {
                  final isSelected = ctrl.serviceRadius.value == r.$2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SelectChip(
                      label: r.$1,
                      isSelected: isSelected,
                      onTap: () => ctrl.serviceRadius.value = r.$2,
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 20),

          // ── Availability & Hours ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: _secondary, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Availability & Hours',
                      style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Label('OPEN DAYS'),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: List.generate(7, (i) {
                        final isSelected =
                            ctrl.availableDays.contains(_dayKeys[i]);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => ctrl.toggleDay(_dayKeys[i]),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? _white : Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isSelected ? _white : _border),
                              ),
                              child: Center(
                                child: Text(
                                  _days[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF0A0A0A)
                                        : _secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    )),
                const SizedBox(height: 16),
                _Label('STANDARD HOURS'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TimePickerButton(
                        ctrl: ctrl.openTimeCtrl,
                        onTap: () => ctrl.pickTime(context, true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child:
                          Text('to', style: TextStyle(color: _secondary)),
                    ),
                    Expanded(
                      child: _TimePickerButton(
                        ctrl: ctrl.closeTimeCtrl,
                        onTap: () => ctrl.pickTime(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Map Picker ───────────────────────────────────────────────────────────
class _MiniMapPicker extends StatefulWidget {
  final TechnicianOnboardingController ctrl;
  const _MiniMapPicker({required this.ctrl});

  @override
  State<_MiniMapPicker> createState() => _MiniMapPickerState();
}

class _MiniMapPickerState extends State<_MiniMapPicker> {
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _circleManager;

  Future<void> _openPicker() async {
    final result = await Get.toNamed(AppRoutes.mapboxLocationPicker);
    if (result != null && result is Map) {
      widget.ctrl.setLocation(
        (result['lat'] as num).toDouble(),
        (result['lng'] as num).toDouble(),
        result['address'] as String? ?? '',
      );
      if (_map != null) {
        _updatePin(widget.ctrl.lat.value, widget.ctrl.lng.value);
      }
    }
  }

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _map = map;
    _circleManager = await map.annotations.createCircleAnnotationManager();
    if (widget.ctrl.hasLocation.value) {
      _updatePin(widget.ctrl.lat.value, widget.ctrl.lng.value);
    }
  }

  Future<void> _updatePin(double lat, double lng) async {
    if (_map == null || _circleManager == null) return;
    await _map!.flyTo(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        zoom: 14.0,
      ),
      mapbox.MapAnimationOptions(duration: 500),
    );
    await _circleManager!.deleteAll();
    await _circleManager!.create(
      mapbox.CircleAnnotationOptions(
        geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        circleRadius: 10.0,
        circleColor: 0xFF3654FF,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasLoc = widget.ctrl.hasLocation.value;
      return GestureDetector(
        onTap: _openPicker,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasLoc ? Colors.greenAccent.shade700 : _border,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasLoc
                ? Stack(
                    children: [
                      AbsorbPointer(
                        child: mapbox.MapWidget(
                          key: const ValueKey('onboarding_location_map'),
                          onMapCreated: _onMapCreated,
                          cameraOptions: mapbox.CameraOptions(
                            center: mapbox.Point(
                              coordinates: mapbox.Position(
                                widget.ctrl.lng.value,
                                widget.ctrl.lat.value,
                              ),
                            ),
                            zoom: 14.0,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A0A0A).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_location_outlined,
                                  color: _white, size: 14),
                              SizedBox(width: 4),
                              Text('Tap to change',
                                  style: TextStyle(
                                      color: _white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined,
                          color: _secondary, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to pick location from map',
                        style: TextStyle(
                            color: _white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Set your workshop pin on the map',
                        style: TextStyle(color: _hint, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

class _TimePickerButton extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onTap;
  const _TimePickerButton({required this.ctrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: ctrl,
              builder: (context2, value, child) => Text(
                ctrl.text,
                style: const TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down_rounded,
                color: _secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Skills  (order: Categories → Experience → Certification → Service Method)
// ─────────────────────────────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step4({required this.ctrl});

  static const _categories = [
    ('Laptop', 'laptop'),
    ('Smartphone', 'smartphone'),
    ('Home appliance', 'appliance'),
    ('AC & Cooling', 'ac'),
    ('TV & Display', 'tv'),
    ('Vehicles', 'vehicle'),
    ('Other', 'other'),
  ];

  static const _expOptions = [
    ('<1 year', '<1yr'),
    ('1-2 Years', '1-2yr'),
    ('3-5 Years', '3-5yr'),
    ('3-5 Years+', '5yr+'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'What can\nyou fix?',
            subtitle: 'Select all service categories you specialize in.',
          ),
          const SizedBox(height: 28),

          // ── Service Categories ──
          _Label('SERVICE CATEGORIES'),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = ctrl.deviceCategories.contains(c.$2);
                  return _SelectChip(
                    label: c.$1,
                    isSelected: isSelected,
                    onTap: () => ctrl.toggleCategory(c.$2),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),

          // ── Years of Experience ──
          _Label('YEARS OF EXPERIENCE'),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 8,
                children: _expOptions.map((e) {
                  final isSelected = ctrl.yearsExperience.value == e.$2;
                  return _SelectChip(
                    label: e.$1,
                    isSelected: isSelected,
                    onTap: () => ctrl.yearsExperience.value = e.$2,
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),

          // ── Certification ──
          _Label('CERTIFICATION'),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: [
                  ...ctrl.certificationFiles.asMap().entries.map((e) =>
                      _CertItem(
                          index: e.key,
                          file: e.value,
                          initialName: e.key < ctrl.certificationNames.length
                              ? ctrl.certificationNames[e.key]
                              : '',
                          onNameChanged: (name) =>
                              ctrl.updateCertificationName(e.key, name),
                          onRemove: () => ctrl.removeCertification(e.key))),
                  if (ctrl.certificationFiles.length < 5)
                    _AddCertButton(onTap: ctrl.pickCertification),
                ],
              )),
          const SizedBox(height: 24),

          // ── Service Method ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('SERVICE METHOD'),
                const SizedBox(height: 4),
                const Text('You can select both',
                    style: TextStyle(color: _hint, fontSize: 11)),
                const SizedBox(height: 12),
                Obx(() => Row(
                      children: [
                        _ServiceMethodCard(
                          title: 'Pick-up',
                          subtitle: 'Collect from\ncustomer location',
                          icon: Icons.directions_car_outlined,
                          isSelected: ctrl.serviceMethod.contains('pickup'),
                          onTap: () => ctrl.toggleServiceMethod('pickup'),
                        ),
                        const SizedBox(width: 10),
                        _ServiceMethodCard(
                          title: 'Drop-in',
                          subtitle: 'Accept visits at\nyour workshop',
                          icon: Icons.store_outlined,
                          isSelected: ctrl.serviceMethod.contains('dropoff'),
                          onTap: () => ctrl.toggleServiceMethod('dropoff'),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _ServiceMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFD6E4FF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Color(0xFF3654FF) : _border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: isSelected ? const Color(0xFF3654FF) : _secondary,
                  size: 24),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF1E2A4A) : _white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: isSelected
                          ? Color(0xFF4B6BB5)
                          : _hint,
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertItem extends StatefulWidget {
  final int index;
  final File file;
  final String initialName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onRemove;
  const _CertItem({
    required this.index,
    required this.file,
    required this.initialName,
    required this.onNameChanged,
    required this.onRemove,
  });

  @override
  State<_CertItem> createState() => _CertItemState();
}

class _CertItemState extends State<_CertItem> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(widget.file,
                width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              onChanged: widget.onNameChanged,
              style: const TextStyle(color: _white, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Certificate name (e.g. Samsung Certified)',
                hintStyle: const TextStyle(color: _hint, fontSize: 12),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3654FF)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.close_rounded,
                color: Colors.redAccent, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _AddCertButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCertButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file_outlined, color: _secondary, size: 20),
            SizedBox(width: 8),
            Text('Tap to Upload Certification',
                style: TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5 — Pricing
// ─────────────────────────────────────────────────────────────────────────────
class _Step5 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step5({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Set your\ndiagnosis fee',
            subtitle:
                'This fee is charged upfront for the initial visit and system check.',
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFFBBF24), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Biaya ini tetap dibayar customer meski mereka menolak penawaran perbaikanmu.',
                    style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Label('DIAGNOSIS FEE'),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.diagnosisFeeCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                color: _white, fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'e.g. 25000',
              hintStyle: const TextStyle(color: _hint, fontSize: 22),
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                  color: _secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _white),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Saran: Rp 25.000 – Rp 75.000 untuk kebanyakan teknisi.',
            style: TextStyle(color: _hint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 6 — Review & Submit
// ─────────────────────────────────────────────────────────────────────────────
class _Step6 extends StatelessWidget {
  final TechnicianOnboardingController ctrl;
  const _Step6({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepHeader(
                title: 'Check your\ndetails',
                subtitle:
                    'Review all information before finalizing your registration. This ensures our clients get accurate data for matching.',
              ),
              const SizedBox(height: 24),
              _ReviewSection(title: 'PERSONAL INFO', items: [
                _ReviewItem('Name', ctrl.fullNameCtrl.text),
                _ReviewItem('Phone', ctrl.phoneCtrl.text),
                _ReviewItem('Gender',
                    ctrl.gender.value == 'male' ? 'Male' : 'Female'),
                _ReviewItem('Bio', ctrl.bioCtrl.text),
              ]),
              _ReviewSection(title: 'IDENTITY', items: [
                _ReviewItem('NIK', ctrl.nikCtrl.text.isEmpty
                    ? '–'
                    : '${ctrl.nikCtrl.text.substring(0, 4)}XXXXXXXXXXXX'),
                _ReviewItem('KTP Photo',
                    ctrl.ktpFile.value != null ? 'Uploaded' : '–'),
                _ReviewItem('Selfie with KTP',
                    ctrl.selfieFile.value != null ? 'Uploaded' : '–'),
              ]),
              _ReviewSection(title: 'LOCATION', items: [
                _ReviewItem('Area', ctrl.cityCtrl.text),
                _ReviewItem('Radius',
                    'Up to ${ctrl.serviceRadius.value.toInt()}km'),
                _ReviewItem('Workshop',
                    ctrl.workshopAddressCtrl.text.isEmpty
                        ? '–'
                        : ctrl.workshopAddressCtrl.text),
              ]),
              _ReviewSection(title: 'SKILLS', items: [
                _ReviewItem(
                    'Categories',
                    ctrl.deviceCategories.isEmpty
                        ? '–'
                        : ctrl.deviceCategories.map((c) {
                            const map = {
                              'laptop': 'Laptop',
                              'smartphone': 'Smartphone',
                              'appliance': 'Home Appliance',
                              'ac': 'AC & Cooling',
                              'tv': 'TV & Display',
                              'vehicle': 'Vehicles',
                              'other': 'Other',
                            };
                            return map[c] ?? c;
                          }).join(' & ')),
                _ReviewItem('Experience', ctrl.yearsExperience.value.isEmpty
                    ? '–'
                    : ctrl.yearsExperience.value.replaceAll('yr', ' year')),
                _ReviewItem('Service method',
                    ctrl.serviceMethod.isEmpty
                        ? '–'
                        : ctrl.serviceMethod
                            .map((m) => m == 'pickup' ? 'Pick up' : 'Drop in')
                            .join(', ')),
              ]),
              _ReviewSection(title: 'PRICING', items: [
                _ReviewItem('Diagnosis fee',
                    ctrl.diagnosisFeeCtrl.text.isEmpty
                        ? '–'
                        : 'Rp${ctrl.diagnosisFeeCtrl.text}'),
              ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: Color(0xFF4ADE80), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Akun akan langsung diaktifkan setelah submit.',
                        style: TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewItem> items;
  const _ReviewSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(item.label,
                          style: const TextStyle(
                              color: _hint, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(
                        item.value.isEmpty ? '–' : item.value,
                        style: TextStyle(
                          color: item.value == 'Uploaded'
                              ? Colors.greenAccent.shade400
                              : _white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  const _ReviewItem(this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: _white, fontSize: 28, fontWeight: FontWeight.w800,
                height: 1.2)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(
                color: _secondary, fontSize: 14, height: 1.5)),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _secondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;

  const _DarkField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _secondary, size: 20)
            : null,
        filled: true,
        fillColor: _card,
        counterStyle: const TextStyle(color: _hint, fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _white),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _white : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? _white : _border, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _secondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
