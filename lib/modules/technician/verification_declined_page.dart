import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';

class VerificationDeclinedPage extends StatelessWidget {
  const VerificationDeclinedPage({super.key});

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);
  static const Color _decline = Color(0xFFEF4444);

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
                  color: _decline.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    size: 40, color: _decline),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verifikasi Ditolak',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Maaf, akun teknisimu tidak lolos verifikasi. '
                'Pastikan data yang kamu kirimkan lengkap dan valid, '
                'kemudian hubungi tim Electrovice untuk informasi lebih lanjut.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.black45, size: 18),
                        SizedBox(width: 8),
                        Text('Kemungkinan penyebab:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...[
                      'Foto KTP tidak terbaca dengan jelas',
                      'Data tidak sesuai dengan KTP asli',
                      'Sertifikasi tidak valid atau kadaluarsa',
                      'Informasi workshop tidak lengkap',
                    ].map((reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: _decline,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(reason,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: auth.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Kembali ke Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
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
