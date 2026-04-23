import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    _checkVersionThenNavigate();
  }

  Future<void> _checkVersionThenNavigate() async {
    // Tunggu animasi fade-in selesai dulu
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version; // e.g. "1.0.0"

      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (doc.exists) {
        final latestVersion = doc.data()?['latest_version'] as String? ?? '';
        final downloadUrl = doc.data()?['download_url'] as String? ?? '';
        final forceUpdate = doc.data()?['force_update'] as bool? ?? false;

        if (forceUpdate && latestVersion.isNotEmpty &&
            latestVersion != currentVersion) {
          if (mounted) _showUpdateDialog(latestVersion, downloadUrl);
          return;
        }
      }
    } catch (_) {
      // Gagal cek versi (offline dll) → lanjut normal
    }

    if (mounted) Get.offAllNamed(AppRoutes.register);
  }

  void _showUpdateDialog(String latestVersion, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // tidak bisa di-skip
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Color(0xFF3254FF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Update Tersedia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Versi $latestVersion sudah tersedia.\nPerbarui aplikasi untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: downloadUrl.isNotEmpty
                      ? () => launchUrl(
                            Uri.parse(downloadUrl),
                            mode: LaunchMode.externalApplication,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3254FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Download Sekarang',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // ── Logo ──────────────────────────────────────────────
            Center(
              child: Image.asset(
                'assets/images/ELECTROVICE_LOGO_HD.png',
                width: MediaQuery.of(context).size.width * 0.50,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            // ── Version ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'version 3.0.0 beta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0A0A).withValues(alpha: 0.35),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
