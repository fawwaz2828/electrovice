import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminVerificationPage extends StatelessWidget {
  const AdminVerificationPage({super.key});

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);
  static const Color _decline = Color(0xFFEF4444);
  static const Color _approve = Color(0xFF111827);
  static const Color _pending = Color(0xFFF59E0B);
  static const Color _verified = Color(0xFF10B981);
  static const Color _sectionBg = Color(0xFFFFFFFF);
  static const Color _divider = Color(0xFFE5E7EB);

  String get _uid => (Get.arguments as Map?)?['uid'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('UID tidak ditemukan')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(_uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            appBar: _buildAppBar(),
            body: const Center(child: Text('Data tidak ditemukan')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final profile = data['technicianProfile'] as Map<String, dynamic>? ?? {};
        final name = data['name'] as String? ?? '—';
        final phone = profile['phone'] as String? ?? '—';
        final city = profile['city'] as String? ?? '—';
        final nik = profile['nik'] as String? ?? '—';
        final workshopName = profile['workshopName'] as String? ?? '—';
        final workshopAddress = profile['workshopAddress'] as String? ?? '—';
        final serviceRadius = profile['serviceRadius']?.toString() ?? '—';
        final ktpUrl = profile['ktpImageUrl'] as String? ?? '';
        final selfieUrl = profile['selfieImageUrl'] as String? ?? '';
        final certUrls = (profile['certificationUrls'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final accreditations = (profile['accreditations'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final deviceCategories = (profile['deviceCategories'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final availableDays =
            (profile['availableDays'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final openTime = profile['openTime'] as String? ?? '—';
        final closeTime = profile['closeTime'] as String? ?? '—';
        final verificationStatus = profile['verificationStatus'] as String? ?? 'pending';

        final initials = name.trim().split(' ').take(2).map((w) {
          return w.isNotEmpty ? w[0].toUpperCase() : '';
        }).join();

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(),
                      const SizedBox(height: 12),
                      _buildProfileCard(
                          name, initials, city, phone, verificationStatus),
                      const SizedBox(height: 12),
                      _buildKtpSelfieSection(nik, ktpUrl, selfieUrl),
                      if (accreditations.isNotEmpty ||
                          certUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSertifikasiSection(accreditations, certUrls),
                      ],
                      const SizedBox(height: 12),
                      _buildAlamatSection(
                          city, workshopName, workshopAddress, serviceRadius),
                      const SizedBox(height: 12),
                      _buildJadwalSection(availableDays, openTime, closeTime),
                      const SizedBox(height: 12),
                      _buildDeviceCategorySection(deviceCategories),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (verificationStatus == 'pending')
                _buildBottomButtons(context, name),
            ],
          ),
        );
      },
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
                        fontSize: 16)),
                TextSpan(
                    text: 'TROVICE',
                    style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('ADMIN — VERIFIKASI',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
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

  Widget _buildProfileCard(String name, String initials, String city,
      String phone, String status) {
    final Color statusColor = status == 'verified'
        ? _verified
        : status == 'declined'
            ? _decline
            : _pending;
    final String statusLabel = status == 'verified'
        ? 'VERIFIED'
        : status == 'declined'
            ? 'DECLINED'
            : 'PENDING';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _sectionBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text('$city  ·  $phone',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKtpSelfieSection(
      String nik, String ktpUrl, String selfieUrl) {
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
                TextSpan(text: 'Pastikan foto KTP jelas terbaca dan selfie menunjukkan '),
                TextSpan(
                    text: 'wajah yang sama',
                    style: TextStyle(
                        color: _accent, fontWeight: FontWeight.w600)),
                TextSpan(text: ' dengan KTP.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLabelValue('NIK', nik),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildImageWidget('FOTO KTP', ktpUrl, Icons.badge_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _buildImageWidget('SELFIE + KTP', selfieUrl, Icons.person_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSertifikasiSection(
      List<String> names, List<String> certUrls) {
    return _buildSection(
      icon: Icons.verified_outlined,
      title: 'SERTIFIKASI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (names.isNotEmpty)
            ...names.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: _accent, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87))),
                  ],
                ),
              ),
            ),
          if (certUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: certUrls.asMap().entries.map((e) {
                return _buildImageWidget(
                    'Sertifikat ${e.key + 1}', e.value, Icons.image_outlined,
                    height: 90);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlamatSection(String city, String workshopName,
      String workshopAddress, String serviceRadius) {
    return _buildSection(
      icon: Icons.location_on_outlined,
      title: 'ALAMAT BENGKEL / TOKO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('KOTA', city),
          const SizedBox(height: 10),
          _buildLabelValue('NAMA WORKSHOP', workshopName),
          const SizedBox(height: 10),
          _buildLabelValue('ALAMAT LENGKAP', workshopAddress),
          const SizedBox(height: 10),
          _buildLabelValue('SERVICE RADIUS', 'Up to $serviceRadius km'),
        ],
      ),
    );
  }

  Widget _buildJadwalSection(
      List<String> days, String openTime, String closeTime) {
    const allDays = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    final dayMap = <String, String>{};
    for (final d in allDays) {
      dayMap[d] = days.contains(d) ? '$openTime–$closeTime' : 'Tutup';
    }

    final rows = <Widget>[];
    for (int i = 0; i < allDays.length - 1; i += 2) {
      final d1 = allDays[i];
      final d2 = allDays[i + 1];
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
                child: _buildDayCell(d1, dayMap[d1]!,
                    isClosed: dayMap[d1] == 'Tutup')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildDayCell(d2, dayMap[d2]!,
                    isClosed: dayMap[d2] == 'Tutup')),
          ],
        ),
      ));
    }
    // MIN (last item solo)
    final lastDay = allDays.last;
    rows.add(Row(
      children: [
        Expanded(
            child: _buildDayCell(lastDay, dayMap[lastDay]!,
                isClosed: dayMap[lastDay] == 'Tutup')),
        const Expanded(child: SizedBox()),
      ],
    ));

    return _buildSection(
      icon: Icons.access_time_outlined,
      title: 'JADWAL OPERASIONAL',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }

  Widget _buildDayCell(String day, String jam, {bool isClosed = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: _divider),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(jam,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isClosed ? _decline : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDeviceCategorySection(List<String> categories) {
    return _buildSection(
      icon: Icons.devices_outlined,
      title: 'DEVICE CATEGORY',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories
            .map((cat) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: _divider),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(cat,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _divider))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showDeclineConfirm(context, name),
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
              onPressed: () => _showApproveConfirm(context, name),
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

  void _showApproveConfirm(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Teknisi?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            '$name akan diaktifkan dan bisa menerima order dari customer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus('verified');
              Get.back();
              Get.snackbar('Berhasil', '$name telah diverifikasi',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFF10B981),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _approve,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Ya, Approve'),
          ),
        ],
      ),
    );
  }

  void _showDeclineConfirm(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Teknisi?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            '$name akan diberi tahu bahwa pendaftarannya tidak lolos verifikasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus('declined');
              Get.back();
              Get.snackbar('Ditolak', '$name telah di-decline',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: _decline,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _decline,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Ya, Decline'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'technicianProfile.verificationStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Helper Widgets ──────────────────────────────────────────────

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

  Widget _buildImageWidget(String label, String url, IconData fallbackIcon,
      {double height = 120}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF9FAFB),
      ),
      child: url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(label, fallbackIcon),
              ),
            )
          : _imagePlaceholder(label, fallbackIcon),
    );
  }

  Widget _imagePlaceholder(String label, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: Colors.black26),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.black38, fontSize: 11, letterSpacing: 0.5)),
      ],
    );
  }
}
