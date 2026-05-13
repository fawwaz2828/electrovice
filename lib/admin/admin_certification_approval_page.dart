import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCertificationApprovalPage extends StatelessWidget {
  const AdminCertificationApprovalPage({super.key});

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _bg = Color(0xFFF3F4F6);
  static const Color _muted = Color(0xFF64748B);
  static const Color _declineColor = Color(0xFFEF4444);

  Stream<List<_PendingCert>> _streamPending() {
    return FirebaseFirestore.instance
        .collection('technicians_online')
        .where('certificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              final details =
                  (m['certificationDetails'] as List<dynamic>? ?? [])
                      .whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList();
              return _PendingCert(
                uid: d.id,
                name: m['name'] as String? ?? '—',
                specialty: m['specialty'] as String? ?? '',
                photoUrl: m['photoUrl'] as String?,
                accreditations:
                    (m['accreditations'] as List<dynamic>? ?? [])
                        .map((e) => e.toString())
                        .toList(),
                certificationUrls:
                    (m['certificationUrls'] as List<dynamic>? ?? [])
                        .map((e) => e.toString())
                        .toList(),
                details: details,
              );
            }).toList());
  }

  Future<void> _approve(BuildContext context, _PendingCert cert) async {
    await FirebaseFirestore.instance
        .collection('technicians_online')
        .doc(cert.uid)
        .set({
      'certificationStatus': 'approved',
      'isCertified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    Get.snackbar('Approved', '${cert.name} is now certified',
        snackPosition: SnackPosition.TOP);
  }

  Future<void> _decline(BuildContext context, _PendingCert cert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline certification?'),
        content: Text(
            "${cert.name}'s certificate will be marked as declined. The technician will need to upload again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _declineColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection('technicians_online')
        .doc(cert.uid)
        .set({
      'certificationStatus': 'declined',
      'isCertified': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    Get.snackbar('Declined', "${cert.name}'s certificate was declined",
        snackPosition: SnackPosition.TOP);
  }

  void _viewPhoto(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(40),
              child: Icon(Icons.broken_image_rounded,
                  color: Colors.white54, size: 60),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text(
          'Certification Approval',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<_PendingCert>>(
        stream: _streamPending(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 56, color: _muted.withValues(alpha: 0.6)),
                  const SizedBox(height: 12),
                  const Text('No pending certifications',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _muted)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _CertCard(
              cert: items[i],
              onApprove: () => _approve(context, items[i]),
              onDecline: () => _decline(context, items[i]),
              onViewPhoto: (url) => _viewPhoto(context, url),
            ),
          );
        },
      ),
    );
  }
}

class _PendingCert {
  final String uid;
  final String name;
  final String specialty;
  final String? photoUrl;
  final List<String> accreditations;
  final List<String> certificationUrls;
  final List<Map<String, dynamic>> details;

  _PendingCert({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.photoUrl,
    required this.accreditations,
    required this.certificationUrls,
    required this.details,
  });
}

class _CertCard extends StatelessWidget {
  final _PendingCert cert;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final void Function(String url) onViewPhoto;

  const _CertCard({
    required this.cert,
    required this.onApprove,
    required this.onDecline,
    required this.onViewPhoto,
  });

  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _approve = Color(0xFF10B981);
  static const Color _decline = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEEF4FF),
                backgroundImage:
                    (cert.photoUrl != null && cert.photoUrl!.isNotEmpty)
                        ? NetworkImage(cert.photoUrl!)
                        : null,
                child: (cert.photoUrl == null || cert.photoUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded,
                        color: Color(0xFF0061FF))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _ink)),
                    if (cert.specialty.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(cert.specialty,
                          style: const TextStyle(
                              fontSize: 12, color: _muted)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('CERTIFICATIONS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.0)),
          const SizedBox(height: 8),
          if (cert.details.isNotEmpty)
            ...cert.details.map((d) => _DetailCard(
                  detail: d,
                  onViewPhoto: onViewPhoto,
                ))
          else
            ...List.generate(cert.accreditations.length, (i) {
              final name = cert.accreditations[i];
              final url = i < cert.certificationUrls.length
                  ? cert.certificationUrls[i]
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: url.isNotEmpty ? () => onViewPhoto(url) : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          image: url.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: url.isEmpty
                            ? const Icon(Icons.image_not_supported_rounded,
                                color: Color(0xFF94A3B8), size: 22)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _ink)),
                    ),
                    if (url.isNotEmpty)
                      TextButton(
                        onPressed: () => onViewPhoto(url),
                        child: const Text('View'),
                      ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _decline,
                    side: const BorderSide(color: _decline),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _approve,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Detail card untuk sertifikat dengan field lengkap ──────────────────
class _DetailCard extends StatelessWidget {
  final Map<String, dynamic> detail;
  final void Function(String url) onViewPhoto;

  const _DetailCard({required this.detail, required this.onViewPhoto});

  static const Color _ink = Color(0xFF0A0A0A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _accent = Color(0xFF3254FF);

  static const List<String> _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _fmtDate(Timestamp? ts) {
    if (ts == null) return '—';
    final d = ts.toDate();
    return '${d.day} ${_monthNames[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final name = detail['name'] as String? ?? '—';
    final issuer = detail['issuer'] as String? ?? '';
    final certNumber = detail['certNumber'] as String? ?? '';
    final specialty = detail['specialty'] as String? ?? '';
    final notes = detail['notes'] as String? ?? '';
    final url = detail['photoUrl'] as String? ?? '';
    final issueDate = detail['issueDate'] as Timestamp?;
    final expiryDate = detail['expiryDate'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: url.isNotEmpty ? () => onViewPhoto(url) : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                    image: url.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(url), fit: BoxFit.cover)
                        : null,
                  ),
                  child: url.isEmpty
                      ? const Icon(Icons.image_not_supported_rounded,
                          color: Color(0xFF94A3B8), size: 26)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        )),
                    if (issuer.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('Issuer: $issuer',
                          style: const TextStyle(
                              fontSize: 12, color: _muted)),
                    ],
                    if (url.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => onViewPhoto(url),
                        child: const Text('View certificate photo',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accent)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (certNumber.isNotEmpty)
            _field('Certificate number', certNumber),
          if (specialty.isNotEmpty) _field('Specialty', specialty),
          _field('Issue date', _fmtDate(issueDate)),
          _field('Expiry date',
              expiryDate != null ? _fmtDate(expiryDate) : 'Lifetime'),
          if (notes.isNotEmpty) _field('Notes', notes),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    color: _ink,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
