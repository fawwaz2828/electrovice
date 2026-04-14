import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buka Google Maps — navigasi ke koordinat atau pencarian berdasarkan alamat.
class MapsLauncher {
  /// Buka Google Maps dengan navigasi (Direction) ke [lat],[lng].
  /// Jika gagal, fallback ke URL browser biasa.
  static Future<void> navigateTo({
    required double lat,
    required double lng,
    String? label,
  }) async {
    final query = label != null && label.isNotEmpty
        ? Uri.encodeComponent(label)
        : '$lat,$lng';

    // Coba buka aplikasi Maps native
    final nativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($query)');
    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri);
      return;
    }

    // Fallback ke Google Maps web
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar(
      'Tidak Bisa Membuka Maps',
      'Pastikan aplikasi Maps sudah terpasang',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Buka Google Maps pencarian berdasarkan teks alamat.
  static Future<void> searchAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    Get.snackbar(
      'Tidak Bisa Membuka Maps',
      'Periksa koneksi internet',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
