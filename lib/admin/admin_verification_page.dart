import 'package:flutter/material.dart';

class admin_verification_page extends StatelessWidget {
  const admin_verification_page({super.key});

  // ─── HARDCODED DATA (ganti dengan Firebase nanti) ───────────────────────────
  static const String _nama = 'Ahmad Rizki Pratama';
  static const String _lokasi = 'Yogyakarta · +62 812-3456-7890';
  static const String _status = 'PENDING';
  static const String _namaKtp = 'Ahmad Rizki Pratama';
  static const String _nik = '3404••••••••0012';
  static const List<String> _sertifikasi = [
    'Sertifikat Teknisi Komputer — BNSP 2023',
    'Pelatihan Motherboard Repair — 2024',
  ];
  static const String _kota = 'Yogyakarta';
  static const String _namaWorkshop = 'Rizki Laptop Service';
  static const String _alamatLengkap =
      'Jl. Kaliurang Km 7 No. 15B, Condongcatur, Depok, Sleman';
  static const String _serviceRadius = 'Up to 5 km';
  static const Map<String, String> _jadwal = {
    'SEN': '09:00–18:00',
    'SEL': '09:00–18:00',
    'RAB': '09:00–18:00',
    'KAM': '09:00–18:00',
    'JUM': '09:00–17:00',
    'SAB': '10:00–15:00',
    'MIN': 'Tutup',
  };
  static const List<String> _deviceCategory = ['Laptop', 'Smartphone'];
  // ────────────────────────────────────────────────────────────────────────────

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);
  static const Color _pending = Color(0xFFF59E0B);
  static const Color _decline = Color(0xFFEF4444);
  static const Color _approve = Color(0xFF111827);
  static const Color _sectionBg = Color(0xFFFFFFFF);
  static const Color _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 12),
                  _buildProfileCard(),
                  const SizedBox(height: 12),
                  _buildKtpSelfieSection(),
                  const SizedBox(height: 12),
                  _buildSertifikasiSection(),
                  const SizedBox(height: 12),
                  _buildAlamatSection(),
                  const SizedBox(height: 12),
                  _buildJadwalSection(),
                  const SizedBox(height: 12),
                  _buildDeviceCategorySection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
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
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: 'TROVICE',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ADMIN — VERIFIKASI',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _accent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'SA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
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
          Text(
            'Kembali ke daftar',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sectionBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'AR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _lokasi,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _pending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    _status,
                    style: TextStyle(
                      color: _pending,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKtpSelfieSection() {
    return _buildSection(
      icon: Icons.credit_card,
      title: 'KTP & SELFIE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(text: 'Pastikan foto KTP jelas terbaca dan selfie menunjukkan '),
                TextSpan(
                  text: 'wajah yang sama',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' dengan KTP. Dokumen ini menjadi '),
                TextSpan(
                  text: 'jaminan identitas',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' teknisi.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLabelValue('NAMA DI KTP', _namaKtp),
          const SizedBox(height: 10),
          _buildLabelValue('NIK', _nik),
          const SizedBox(height: 14),
          _buildImagePlaceholder('FOTO KTP', Icons.badge_outlined),
          const SizedBox(height: 10),
          _buildImagePlaceholder('SELFIE + KTP', Icons.person_outlined),
        ],
      ),
    );
  }

  Widget _buildSertifikasiSection() {
    return _buildSection(
      icon: Icons.verified_outlined,
      title: 'SERTIFIKASI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(text: 'Sertifikasi '),
                TextSpan(
                  text: 'meyakinkan pelanggan',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' bahwa keahlian teknisi ini terjamin dan profesional.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._sertifikasi.map(
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
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlamatSection() {
    return _buildSection(
      icon: Icons.location_on_outlined,
      title: 'ALAMAT BENGKEL / TOKO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(
                  text: 'Lokasi workshop tempat teknisi beroperasi. Ditampilkan di ',
                ),
                TextSpan(
                  text: 'peta',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' dan untuk kalkulasi jarak ke customer.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLabelValue('KOTA', _kota),
          const SizedBox(height: 10),
          _buildLabelValue('NAMA WORKSHOP', _namaWorkshop),
          const SizedBox(height: 10),
          _buildLabelValue('ALAMAT LENGKAP', _alamatLengkap),
          const SizedBox(height: 10),
          _buildLabelValue('SERVICE RADIUS', _serviceRadius),
        ],
      ),
    );
  }

  Widget _buildJadwalSection() {
    final days = _jadwal.keys.toList();
    final rows = <Widget>[];

    for (int i = 0; i < days.length - 1; i += 2) {
      final day1 = days[i];
      final day2 = days[i + 1];
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(child: _buildDayCell(day1, _jadwal[day1]!)),
              const SizedBox(width: 8),
              Expanded(child: _buildDayCell(day2, _jadwal[day2]!)),
            ],
          ),
        ),
      );
    }

    // MIN (last item solo)
    if (days.length.isOdd) {
      final lastDay = days.last;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildDayCell(lastDay, _jadwal[lastDay]!, isClosed: true)),
            const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return _buildSection(
      icon: Icons.access_time_outlined,
      title: 'JADWAL OPERASIONAL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(text: 'Hari dan jam buka toko — agar customer tahu '),
                TextSpan(
                  text: 'kapan teknisi tersedia',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDayCell(String day, String jam, {bool isClosed = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            jam,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isClosed ? _decline : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCategorySection() {
    return _buildSection(
      icon: Icons.devices_outlined,
      title: 'DEVICE CATEGORY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              children: [
                TextSpan(text: 'Kategori perangkat yang '),
                TextSpan(
                  text: 'bisa diperbaiki',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' oleh teknisi ini.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _deviceCategory
                .map(
                  (cat) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _divider),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
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
              onPressed: () {
                // TODO: Firebase — update status to DECLINED
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _decline,
                side: const BorderSide(color: _decline),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'DECLINE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Firebase — update status to APPROVED
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _approve,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'APPROVE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sectionBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String label, IconData icon) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: _divider, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.black26),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black38,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}