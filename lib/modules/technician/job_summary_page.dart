import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';

class JobSummaryPage extends StatelessWidget {
  const JobSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingDocument? order = Get.arguments is BookingDocument
        ? Get.arguments as BookingDocument
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Success Card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF0A0A0A), width: 1),
                  ),
                  child: Column(
                    children: [
                      // Green checkmark circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF16A34A),
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Payment Accepted',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order != null
                            ? 'You completed repair order for\n${order.userName}'
                            : 'You completed repair order',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Find Another Job button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.technicianHome),
                          style: FilledButton.styleFrom(
                            backgroundColor: Color(0xFF0A0A0A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Find Another Job',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Motivational quote
                      const Text(
                        '"No pain no gain"\n— random person',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0BAC9),
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
