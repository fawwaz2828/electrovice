import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import 'auth_controller.dart';

enum UserRole { customer, technician }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
<<<<<<< HEAD
  UserRole? _selectedRole = UserRole.technician;
  bool _showForm = false; // ← toggle antara pilih role & form

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthController _authController = Get.put(AuthController());

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
=======
  UserRole? _selectedRole = UserRole.customer;
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo
              const Text('WELCOME TO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
<<<<<<< HEAD
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('E', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0061FF))),
                  const Icon(Icons.bolt, color: Color(0xFF0061FF), size: 42),
                  Text('CTROVICE', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: const Color(0xFF0061FF), letterSpacing: -1.0)),
                ],
=======
              Image.asset(
                'assets/images/ELECTROVICE_LOGO_HD.png',
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Image logo.png not found in assets/images/',
                    style: TextStyle(color: Colors.red),
                  );
                },
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24
              ),
              const SizedBox(height: 32),

              // Step 1: Pilih Role
              if (!_showForm) ...[
                const Text(
                  'Choose how you would like to use the\nplatform',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.4, fontWeight: FontWeight.w500),
                ),
<<<<<<< HEAD
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
                  onPressed: _selectedRole != null ? () => setState(() => _showForm = true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
=======
              ),
              const SizedBox(height: 32),

              // Cards
              RoleCard(
                title: 'I am a Customer',
                description:
                    'I want to find expert technicians and repair my devices/vehicles.',
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
                description:
                    'I want to manage jobs, build my profile, and grow my repair business.',
                icon: Icons.build_circle,
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
                onPressed: _selectedRole != null
                    ? () {
                        Get.toNamed(
                          AppRoutes.signup,
                          arguments: {'role': _selectedRole},
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24
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
<<<<<<< HEAD
              ],

              // Step 2: Form Register
              if (_showForm) ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                      onPressed: () => setState(() => _showForm = false),
                    ),
                    Text(
                      _selectedRole == UserRole.technician ? 'Technician Account' : 'Customer Account',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      const Text('FULL NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E40AF))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'John Doe',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E40AF))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'name@email.com',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF64748B)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password
                      const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E40AF))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), letterSpacing: 4),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF64748B)),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      Obx(() => ElevatedButton(
                        onPressed: _authController.isLoading.value ? null : () {
                          _authController.register(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _nameController.text.trim(),
                            _selectedRole == UserRole.technician ? 'technician' : 'customer',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                      )),

                      Obx(() => _authController.errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(_authController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                          )
                        : const SizedBox(),
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
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
=======
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 48),
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24
            ],
          ),
        ),
      ),
    );
  }
}

// RoleCard widget tetap sama
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
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xFFD6E4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryColor, size: 28),
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
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
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
<<<<<<< HEAD
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                child: const Text('SELECTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
=======
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
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
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24
              ),
            ),
        ],
      ),
    );
  }
}