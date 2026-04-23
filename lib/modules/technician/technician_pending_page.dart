import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';

class TechnicianPendingPage extends StatelessWidget {
  const TechnicianPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDeclined =
        (Get.arguments as Map?)?['declined'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDeclined
                      ? Color(0xFFFEF2F2)
                      : const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDeclined
                      ? Icons.cancel_outlined
                      : Icons.hourglass_top_rounded,
                  size: 48,
                  color: isDeclined
                      ? Color(0xFFEF4444)
                      : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isDeclined ? 'Verification Declined' : 'Awaiting Verification',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                isDeclined
                    ? 'Sorry, your registration did not pass admin verification. Please make sure the data you entered is complete and accurate, then re-register.'
                    : 'Your technician account is being verified by the Electrovice team. This usually takes up to 24 hours.\n\nYou will receive a notification once verification is complete.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!isDeclined) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF3B82F6), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Our team verifies your ID, selfie, and workshop data to ensure customer safety.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(flex: 3),
              // Tombol daftar ulang (hanya jika declined)
              if (isDeclined)
                FilledButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.technicianOnboarding),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFF0A0A0A),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Re-register',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              // Tombol logout
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await AuthService().logout();
                  Get.offAllNamed(AppRoutes.register);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
