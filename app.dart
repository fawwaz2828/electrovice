import 'package:flutter/material.dart';

void main() {
  runApp(const ElectroviceApp());
}

class ElectroviceApp extends StatelessWidget {
  const ElectroviceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electrovice',
      theme: ThemeData(
        primaryColor: const Color(0xFF0061FF),
        scaffoldBackgroundColor: const Color(0xFFF9FAFC),
        fontFamily: 'Roboto', // Make sure to load an appropriate font in your pubspec.yaml if needed
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

enum UserRole { customer, technician }

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole = UserRole.technician;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Header
              const Text(
                'WELCOME TO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'E',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF0061FF),
                    ),
                  ),
                  const Icon(
                    Icons.bolt,
                    color: Color(0xFF0061FF),
                    size: 42,
                  ),
                  Text(
                    'CTROVICE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF0061FF),
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose how you would like to use the\nplatform',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF475569),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Cards
              RoleCard(
                title: 'I am a Customer',
                description: 'I want to find expert technicians and repair my devices/vehicles.',
                icon: Icons.person_outline,
                isSelected: _selectedRole == UserRole.customer,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.customer;
                  });
                },
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'I am a Technician',
                description: 'I want to manage jobs, build my profile, and grow my repair business.',
                icon: Icons.build_circle, // Wrench-like icon
                // Alternatively, simply use Icons.build
                isSelected: _selectedRole == UserRole.technician,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.technician;
                  });
                },
              ),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _selectedRole != null ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0061FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF0061FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
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
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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
                color: isSelected ? const Color(0xFF0061FF) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0061FF) : const Color(0xFFD6E4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon == Icons.build_circle ? Icons.build : icon,
                    color: isSelected ? Colors.white : const Color(0xFF0061FF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0061FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFCBD5E1),
                  ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0061FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SELECTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
