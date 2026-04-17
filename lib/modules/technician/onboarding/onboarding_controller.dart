import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/routes.dart';
import '../../../services/storage_service.dart';

class TechnicianOnboardingController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  final RxInt currentStep = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;

  // ── Step 1: Personal Info ──────────────────────────────────────
  final Rxn<File> profilePhotoFile = Rxn<File>();
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final Rxn<DateTime> dob = Rxn<DateTime>();
  final RxString gender = ''.obs;
  final bioCtrl = TextEditingController();

  // ── Step 2: Identity ──────────────────────────────────────────
  final nikCtrl = TextEditingController();
  final Rxn<File> ktpFile = Rxn<File>();
  final Rxn<File> selfieFile = Rxn<File>();

  // ── Step 3: Location ──────────────────────────────────────────
  final cityCtrl = TextEditingController();
  final workshopNameCtrl = TextEditingController();
  final workshopAddressCtrl = TextEditingController();
  final RxDouble serviceRadius = 5.0.obs;
  final RxList<String> availableDays = <String>[].obs;
  final openTimeCtrl = TextEditingController(text: '09:00');
  final closeTimeCtrl = TextEditingController(text: '18:00');
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxBool hasLocation = false.obs;

  // ── Step 4: Skills ────────────────────────────────────────────
  final RxList<String> deviceCategories = <String>[].obs;
  final RxString yearsExperience = ''.obs;
  final RxList<File> certificationFiles = <File>[].obs;
  final RxList<String> serviceMethod = <String>[].obs;

  // ── Step 5: Pricing ───────────────────────────────────────────
  final diagnosisFeeCtrl = TextEditingController();

  @override
  void onClose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    bioCtrl.dispose();
    nikCtrl.dispose();
    cityCtrl.dispose();
    workshopNameCtrl.dispose();
    workshopAddressCtrl.dispose();
    openTimeCtrl.dispose();
    closeTimeCtrl.dispose();
    diagnosisFeeCtrl.dispose();
    super.onClose();
  }

  // ── Navigation ────────────────────────────────────────────────

  void nextStep() {
    if (currentStep.value < 5) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ── Toggles ───────────────────────────────────────────────────

  void toggleDay(String day) {
    if (availableDays.contains(day)) {
      availableDays.remove(day);
    } else {
      availableDays.add(day);
    }
  }

  void toggleCategory(String cat) {
    if (deviceCategories.contains(cat)) {
      deviceCategories.remove(cat);
    } else {
      deviceCategories.add(cat);
    }
  }

  void toggleServiceMethod(String method) {
    if (serviceMethod.contains(method)) {
      serviceMethod.remove(method);
    } else {
      serviceMethod.add(method);
    }
  }

  // ── Image Pickers ─────────────────────────────────────────────

  Future<void> pickProfilePhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) profilePhotoFile.value = File(picked.path);
  }

  Future<void> pickKtp() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) ktpFile.value = File(picked.path);
  }

  Future<void> takeSelfie() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) selfieFile.value = File(picked.path);
  }

  Future<void> pickSelfieFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) selfieFile.value = File(picked.path);
  }

  Future<void> pickCertification() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) certificationFiles.add(File(picked.path));
  }

  void removeCertification(int index) {
    certificationFiles.removeAt(index);
  }

  // ── Date of Birth ─────────────────────────────────────────────

  Future<void> pickDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF111111)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dob.value = picked;
      dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  // ── Location ──────────────────────────────────────────────────

  void setLocation(double latitude, double longitude, String address) {
    lat.value = latitude;
    lng.value = longitude;
    if (address.isNotEmpty) workshopAddressCtrl.text = address;
    hasLocation.value = true;
  }

  // ── Time Picker ───────────────────────────────────────────────

  Future<void> pickTime(BuildContext context, bool isOpen) async {
    final initial = _parseTime(isOpen ? openTimeCtrl.text : closeTimeCtrl.text);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    if (isOpen) {
      openTimeCtrl.text = formatted;
    } else {
      closeTimeCtrl.text = formatted;
    }
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  // ── Submit ────────────────────────────────────────────────────

  Future<void> submitOnboarding() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isSubmitting.value = true;
    submitError.value = '';

    try {
      // Upload photos
      String profilePhotoUrl = '';
      String ktpUrl = '';
      String selfieUrl = '';
      List<String> certUrls = [];

      if (profilePhotoFile.value != null) {
        profilePhotoUrl =
            await _storageService.uploadProfilePhoto(uid, profilePhotoFile.value!);
      }
      if (ktpFile.value != null) {
        ktpUrl = await _storageService.uploadTechnicianKtp(uid, ktpFile.value!);
      }
      if (selfieFile.value != null) {
        selfieUrl =
            await _storageService.uploadTechnicianSelfie(uid, selfieFile.value!);
      }
      if (certificationFiles.isNotEmpty) {
        certUrls = await _storageService.uploadCertifications(
            uid, certificationFiles.toList());
      }

      final fee = int.tryParse(
              diagnosisFeeCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      final radius = serviceRadius.value;
      final cats = deviceCategories.toList();
      final specialty = cats.isNotEmpty ? cats.first : 'General';
      final fullName = fullNameCtrl.text.trim();

      // Build technicianProfile map
      final techProfile = {
        'phone': phoneCtrl.text.trim(),
        'gender': gender.value,
        'bio': bioCtrl.text.trim(),
        'dateOfBirth':
            dob.value != null ? Timestamp.fromDate(dob.value!) : null,
        'nik': nikCtrl.text.trim(),
        'ktpImageUrl': ktpUrl,
        'selfieImageUrl': selfieUrl,
        'city': cityCtrl.text.trim(),
        'workshopName': workshopNameCtrl.text.trim(),
        'workshopAddress': workshopAddressCtrl.text.trim(),
        'serviceRadius': radius,
        'availableDays': availableDays.toList(),
        'openTime': openTimeCtrl.text,
        'closeTime': closeTimeCtrl.text,
        'latitude': lat.value,
        'longitude': lng.value,
        'deviceCategories': cats,
        'serviceMethod': serviceMethod.toList(),
        'yearsExperience': yearsExperience.value,
        'certificationUrls': certUrls,
        'diagnosisFee': fee,
        'verificationStatus': 'pending',
        'isAvailable': false,
        'rating': 0.0,
        'totalRatings': 0,
        'totalJobs': 0,
        'successRate': 100,
        'specialty': specialty,
        'category': specialty.toLowerCase(),
        if (profilePhotoUrl.isNotEmpty) 'photoUrl': profilePhotoUrl,
      };

      // Save to users/{uid} — update nama lengkap juga
      await _firestore.collection('users').doc(uid).update({
        'name': fullName,
        if (profilePhotoUrl.isNotEmpty) 'photoUrl': profilePhotoUrl,
        'technicianProfile': techProfile,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Build diagnosa service estimate dari diagnosisFee
      final List<Map<String, dynamic>> initialServices = [];
      if (fee > 0) {
        initialServices.add({
          'service': 'Diagnosa',
          'minPrice': fee,
          'maxPrice': fee,
          'description':
              'Pemeriksaan awal kondisi perangkat untuk menentukan kerusakan dan estimasi biaya perbaikan.',
          'duration': 'same_day',
        });
      }

      // Create technicians_online doc (untuk geo-query)
      final GeoFirePoint point = GeoFirePoint(GeoPoint(lat.value, lng.value));
      await _firestore.collection('technicians_online').doc(uid).set({
        'uid': uid,
        'name': fullName,
        'specialty': specialty,
        'category': specialty.toLowerCase(),
        'isAvailable': false,
        'workshopAddress': workshopAddressCtrl.text.trim(),
        'location': point.data,
        'accreditations': certUrls,
        'serviceEstimates': initialServices,
        'serviceRadius': radius,
        'diagnosisFee': fee,
        'rating': 0.0,
        'totalJobs': 0,
        if (profilePhotoUrl.isNotEmpty) 'photoUrl': profilePhotoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.offAllNamed(AppRoutes.verificationPending);
    } catch (e) {
      submitError.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }
}
