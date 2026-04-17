import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../modules/auth/auth_controller.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.put(AuthController());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _primary,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '● ELEc',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              TextSpan(
                text: 'TROVICE',
                style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: auth.logout,
            child: const Text('Logout',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 40, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Menunggu Verifikasi',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Akun teknisimu sedang ditinjau oleh admin Electrovice. '
                'Proses verifikasi biasanya memakan waktu 1×24 jam.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.6),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  children: [
                    _StepItem(
                      icon: Icons.check_circle,
                      color: Color(0xFF10B981),
                      label: 'Onboarding selesai',
                      done: true,
                    ),
                    _StepItem(
                      icon: Icons.pending_outlined,
                      color: Color(0xFFF59E0B),
                      label: 'Verifikasi admin',
                      done: false,
                    ),
                    _StepItem(
                      icon: Icons.rocket_launch_outlined,
                      color: Colors.black38,
                      label: 'Akun aktif & siap digunakan',
                      done: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.verificationPending),
                icon: const Icon(Icons.refresh),
                label: const Text('Cek Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.done,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: done ? Colors.black87 : Colors.black45,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
