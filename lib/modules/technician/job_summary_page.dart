import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';

class JobSummaryPage extends StatelessWidget {
  const JobSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              
              // ── Celebration Icon ─────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0061FF),
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Job Completed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'Excellent work! Your service has been\nsuccessfully verified and completed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // ── Earnings Card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL EARNINGS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$180.00',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    _SummaryRow(label: 'Service Fee', value: '\$45.00'),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Labor', value: '\$135.00'),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Client Rating', value: '5.0 ★', valueColor: const Color(0xFFFFB800)),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // ── Action Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.technicianHome),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'RETURN TO OVERVIEW',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  
  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
