import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_controller.dart';

class admin_verification_page extends StatelessWidget {
  const admin_verification_page({super.key});

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);
  static const Color _pending = Color(0xFFF59E0B);
  static const Color _decline = Color(0xFFEF4444);
  static const Color _approve = Color(0xFF111827);
  static const Color _sectionBg = Color(0xFFFFFFFF);
  static const Color _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final TechnicianVerificationModel tech =
        Get.arguments as TechnicianVerificationModel;
    final AdminController controller = Get.find<AdminController>();

    final statusColor = tech.verificationStatus == 'verified'
        ? const Color(0xFF10B981)
        : tech.verificationStatus == 'declined'
            ? _decline
            : _pending;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 12),
                  _buildProfileCard(tech, statusColor),
                  const SizedBox(height: 12),
                  _buildKtpSelfieSection(tech),
                  const SizedBox(height: 12),
                  _buildBioSection(tech),
                  const SizedBox(height: 12),
                  _buildAlamatSection(tech),
                  const SizedBox(height: 12),
                  _buildJadwalSection(tech),
                  const SizedBox(height: 12),
                  _buildDeviceCategorySection(tech),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (tech.verificationStatus == 'pending')
            _buildBottomButtons(context, tech, controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          RichText(
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
          const SizedBox(width: 8),
          const Text(
            'ADMIN — VERIFIKASI',
            style: TextStyle(
                color: Colors.white54, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration:
              const BoxDecoration(color: _accent, shape: BoxShape.circle),
          child: const Center(
            child: Text('SA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 20, color: Colors.black87),
          Text('Kembali ke daftar',
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      TechnicianVerificationModel tech, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _sectionBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildAvatar(tech),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tech.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '${tech.city}${tech.phone != null ? '  ·  ${tech.phone}' : ''}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tech.verificationStatus.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TechnicianVerificationModel tech) {
    if (tech.photoUrl != null && tech.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          tech.photoUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsBox(tech.initials),
        ),
      );
    }
    return _buildInitialsBox(tech.initials);
  }

  Widget _buildInitialsBox(String initials) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
    );
  }

  Widget _buildKtpSelfieSection(TechnicianVerificationModel tech) {
    return _buildSection(
      icon: Icons.credit_card,
      title: 'KTP & SELFIE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(
                    text:
                        'Pastikan foto KTP jelas terbaca dan selfie menunjukkan '),
                TextSpan(
                  text: 'wajah yang sama',
                  style: TextStyle(
                      color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' dengan KTP.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLabelValue('NAMA DI KTP', tech.namaKtp ?? tech.name),
          const SizedBox(height: 10),
          _buildLabelValue('NIK',
              tech.nik != null && tech.nik!.isNotEmpty ? tech.nik! : '-'),
          const SizedBox(height: 14),
          _buildNetworkImageOrPlaceholder(
              'FOTO KTP', tech.ktpImageUrl, Icons.badge_outlined),
          const SizedBox(height: 10),
          _buildNetworkImageOrPlaceholder(
              'SELFIE + KTP', tech.selfieImageUrl, Icons.person_outlined),
        ],
      ),
    );
  }

  Widget _buildBioSection(TechnicianVerificationModel tech) {
    if (tech.bio == null && tech.certificationUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildSection(
      icon: Icons.verified_outlined,
      title: 'BIO & SERTIFIKASI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tech.bio != null && tech.bio!.isNotEmpty) ...[
            Text(tech.bio!,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 12),
          ],
          if (tech.certificationUrls.isNotEmpty) ...[
            const Text('Sertifikasi:',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...tech.certificationUrls.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _showImageDialog(e.value),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined,
                            size: 18, color: _accent),
                        const SizedBox(width: 8),
                        Text('Sertifikat ${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: _accent,
                                decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildAlamatSection(TechnicianVerificationModel tech) {
    return _buildSection(
      icon: Icons.location_on_outlined,
      title: 'ALAMAT BENGKEL / TOKO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('KOTA',
              tech.city.isNotEmpty ? tech.city : '-'),
          const SizedBox(height: 10),
          _buildLabelValue('NAMA WORKSHOP', tech.workshopName),
          const SizedBox(height: 10),
          _buildLabelValue('SERVICE RADIUS',
              '${tech.serviceRadius.toStringAsFixed(0)} km'),
        ],
      ),
    );
  }

  Widget _buildJadwalSection(TechnicianVerificationModel tech) {
    if (tech.availableDays.isEmpty) return const SizedBox.shrink();
    return _buildSection(
      icon: Icons.access_time_outlined,
      title: 'JADWAL OPERASIONAL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tech.availableDays
                .map((day) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: _divider),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(day.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          if (tech.openTime != null && tech.closeTime != null) ...[
            const SizedBox(height: 10),
            _buildLabelValue('JAM OPERASIONAL',
                '${tech.openTime} – ${tech.closeTime}'),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCategorySection(TechnicianVerificationModel tech) {
    return _buildSection(
      icon: Icons.devices_outlined,
      title: 'DEVICE CATEGORY',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tech.deviceCategories
            .map((cat) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: _divider),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cat,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context,
      TechnicianVerificationModel tech, AdminController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmAction(
                context,
                title: 'Tolak Teknisi?',
                message:
                    'Apakah kamu yakin ingin menolak verifikasi ${tech.name}?',
                onConfirm: () => controller.decline(tech.uid),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _decline,
                side: const BorderSide(color: _decline),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('DECLINE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _confirmAction(
                context,
                title: 'Approve Teknisi?',
                message:
                    'Verifikasi ${tech.name} sebagai teknisi resmi Electrovice?',
                onConfirm: () => controller.approve(tech.uid),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _approve,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('APPROVE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya, lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String url) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url,
                errorBuilder: (_, __, ___) =>
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Gagal memuat gambar'),
                    )),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _sectionBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: _divider),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildNetworkImageOrPlaceholder(
      String label, String? url, IconData fallbackIcon) {
    if (url != null && url.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showImageDialog(url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildImagePlaceholder(label, fallbackIcon),
              ),
            ),
          ),
        ],
      );
    }
    return _buildImagePlaceholder(label, fallbackIcon);
  }

  Widget _buildImagePlaceholder(String label, IconData icon) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border:
            Border.all(color: _divider, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.black26),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 12,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
