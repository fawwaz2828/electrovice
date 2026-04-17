import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

enum UserRole { customer, technician }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserRole? _selectedRole = UserRole.customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text('WELCOME TO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Image.asset(
                'assets/images/ELECTROVICE_LOGO_HD.png',
                height: 48,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),
              const Text(
                'Choose how you would like to use the\nplatform',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.4, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              RoleCard(
                title: 'I am a Customer',
                description: 'I want to find expert technicians and repair my devices/vehicles.',
                icon: Icons.person_outline,
                isSelected: _selectedRole == UserRole.customer,
                onTap: () => setState(() => _selectedRole = UserRole.customer),
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'I am a Technician',
                description: 'I want to manage jobs, build my profile, and grow my repair business.',
                icon: Icons.build,
                isSelected: _selectedRole == UserRole.technician,
                onTap: () => setState(() => _selectedRole = UserRole.technician),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _selectedRole != null ? () {
                  Get.toNamed(AppRoutes.signup, arguments: {'role': _selectedRole});
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login, arguments: {'role': _selectedRole}),
                    child: const Text('Log In', style: TextStyle(color: Color(0xFF0061FF), fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // ── Privacy Policy & Terms ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'Dengan melanjutkan, kamu menyetujui\n'),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse('https://electrovice.vercel.app/terms'),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: const Text(
                            'Syarat & Ketentuan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0061FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF0061FF),
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '  dan  '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse('https://electrovice.vercel.app/privacy-policy'),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0061FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF0061FF),
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' kami.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isSelected)
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                else
                  const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -12, right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                child: const Text('SELECTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}