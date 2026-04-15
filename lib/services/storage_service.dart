import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadTechnicianKtp(String uid, File file) async {
    final ref = _storage.ref('technicians/$uid/ktp.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<String> uploadTechnicianSelfie(String uid, File file) async {
    final ref = _storage.ref('technicians/$uid/selfie.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadCertifications(String uid, List<File> files) async {
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      final ref = _storage.ref('technicians/$uid/certifications/cert_$i.jpg');
      await ref.putFile(files[i], SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref('profile_photos/$uid/photo.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  /// Upload foto kerusakan dari customer (disimpan di bookings/{bookingId}/damages/)
  Future<List<String>> uploadDamagePhotos(
      String bookingId, List<File> files) async {
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('bookings/$bookingId/damages/img_${ts}_$i.jpg');
      await ref.putFile(files[i], SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  /// Upload foto bukti kerja teknisi
  Future<List<String>> uploadWorkPhotos(
      String bookingId, List<File> files) async {
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('bookings/$bookingId/work/img_${ts}_$i.jpg');
      await ref.putFile(files[i], SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  /// Upload foto di chat.
  /// Menggunakan readAsBytes + putData agar bisa menangani content URI
  /// (Android 10+) maupun path reguler tanpa error "not found".
  Future<String> uploadChatPhoto(String chatId, File file) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('chats/$chatId/img_$ts.jpg');
    final bytes = await file.readAsBytes();
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }
}
