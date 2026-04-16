import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class ProfileController extends GetxController {
  final Rxn<ProfileData> profile = Rxn<ProfileData>();
  final RxBool isUploadingPhoto = false.obs;
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    reloadProfile();
  }

  Future<void> reloadProfile() async {
    // Tunggu hingga Firebase Auth siap (max 3 detik)
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final userModel = await _authService.getUserModel(user.uid);
      if (userModel == null) return;

      profile.value = ProfileData(
        fullName: userModel.name,
        emailAddress: userModel.email,
        mobileNumber: userModel.phone ?? '',
        isMobileVerified: false,
        avatarUrl: userModel.photoUrl,
        // primaryNodes & securityOptions bukan data Firestore — statis
        primaryNodes: const [],
        securityOptions: const [
          SecurityOption(key: 'change_access_key', title: 'Change Password'),
          SecurityOption(key: 'privacy_management', title: 'Privacy Management'),
        ],
      );
    } catch (e) {
      debugPrint('ProfileController: gagal load - $e');
    }
  }

  Future<void> pickAndUploadPhoto() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    isUploadingPhoto.value = true;
    try {
      final url = await _storageService.uploadProfilePhoto(
        user.uid,
        File(picked.path),
      );
      await _authService.updateUserPhoto(user.uid, url);
      // Update local profile
      if (profile.value != null) {
        profile.value = ProfileData(
          fullName: profile.value!.fullName,
          emailAddress: profile.value!.emailAddress,
          mobileNumber: profile.value!.mobileNumber,
          isMobileVerified: profile.value!.isMobileVerified,
          avatarUrl: url,
          primaryNodes: profile.value!.primaryNodes,
          securityOptions: profile.value!.securityOptions,
        );
      }
    } catch (e) {
      debugPrint('ProfileController: gagal upload foto - $e');
      Get.snackbar(
        'Upload Gagal',
        'Foto profil tidak bisa diupload. Coba lagi.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }
}
