import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox
    if (dart.library.html) '../../config/mapbox_web_stub.dart';

import '../../config/routes.dart';
import '../../services/technician_service.dart';
import '../../utils/maps_launcher.dart';
import 'booking_controller.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const Color _bg    = Color(0xFFF2F3F7);
const Color _card  = Colors.white;
const Color _ink   = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _blue  = Color(0xFF0061FF);

class BookingTechnicianDetailPage extends GetView<BookingController> {
  const BookingTechnicianDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Obx(() {
            final tech = controller.selectedTechnician.value;
            if (tech == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                // ── Top bar ─────────────────────────────────────────
                _TopBar(name: tech.name),
                // ── Profile header ──────────────────────────────────
                _ProfileHeader(tech: tech),
                // ── Tab bar ─────────────────────────────────────────
                Container(
                  color: _card,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'SERVICE'),
                      Tab(text: 'REVIEWS'),
                      Tab(text: 'ABOUT'),
                    ],
                  ),
                ),
                // ── Tab views ───────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    children: [
                      _ServiceTab(tech: tech),
                      _ReviewsTab(),
                      _AboutTab(tech: tech),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String name;
  const _TopBar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Expanded(
            child: Text(
              'Technician Details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: _ink),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PROFILE HEADER  (avatar, name, location, stats, CHAT FIRST)
// ════════════════════════════════════════════════════════════════════════════
class _ProfileHeader extends GetView<BookingController> {
  final TechnicianOnlineModel tech;
  const _ProfileHeader({required this.tech});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // ── Avatar + Name + Location ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(photoUrl: tech.photoUrl, size: 80),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tech.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: _muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            tech.workshopAddress.isEmpty
                                ? tech.distanceLabel
                                : '${tech.distanceLabel} • ${tech.workshopAddress}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── Specialty tags ─────────────────────────────
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(
                          label: tech.specialty.isEmpty
                              ? tech.category.toUpperCase()
                              : tech.specialty.toUpperCase(),
                          color: const Color(0xFFDCEDFF),
                          textColor: const Color(0xFF1D4ED8),
                        ),
                        if (tech.accreditations.isNotEmpty)
                          _Tag(
                            label: tech.accreditations.first.toUpperCase(),
                            color: const Color(0xFFE0F2FE),
                            textColor: const Color(0xFF0369A1),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Stats row ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  value: '${tech.totalJobs}',
                  label: 'JOBS DONE',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _StatChip(
                  value: '98%',
                  label: 'COMPLETION',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  value: '${tech.yearsExperience > 0 ? tech.yearsExperience : 1}y',
                  label: 'MEMBER',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── CHAT FIRST button ────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => controller.openPreChat(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ink,
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text(
              'CHAT FIRST',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  const _Avatar({required this.size, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.22),
              child: Image.network(photoUrl!, fit: BoxFit.cover),
            )
          : Icon(Icons.person_rounded, color: const Color(0xFF94A3B8), size: size * 0.45),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Tag({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _muted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SERVICE TAB
// ════════════════════════════════════════════════════════════════════════════
class _ServiceTab extends GetView<BookingController> {
  final TechnicianOnlineModel tech;
  const _ServiceTab({required this.tech});

  @override
  Widget build(BuildContext context) {
    final estimates = tech.serviceEstimates;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (estimates.isEmpty)
          _EmptyServices()
        else ...[
          ...estimates.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ServiceCard(estimate: e),
              )),
        ],
        _NotListedCard(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ServiceCard extends GetView<BookingController> {
  final ServiceEstimate estimate;
  const _ServiceCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + Price ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  estimate.service,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimate.priceLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: _blue,
                    ),
                  ),
                  const Text(
                    'depend on brands & size',
                    style: TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Tags ──────────────────────────────────────────────
          Wrap(
            spacing: 6,
            children: [
              _ServiceTag(label: 'HOME VISIT'),
              _ServiceTag(label: estimate.durationLabel.toUpperCase()),
            ],
          ),
          const SizedBox(height: 14),
          // ── Book Now ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.setSelectedService(estimate);
                Get.toNamed(AppRoutes.createOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 15),
                  SizedBox(width: 6),
                  Text('BOOK NOW', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;
  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _muted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NotListedCard extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Text(
            '+ Not Listed Above?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chat directly — if it\'s a laptop or PC, they can most likely help.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => controller.openPreChat(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.chat_rounded, size: 15),
            label: const Text('START CHAT',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.build_outlined, size: 40, color: _muted),
          const SizedBox(height: 12),
          const Text(
            'No services listed yet.\nChat the technician for pricing information.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  REVIEWS TAB
// ════════════════════════════════════════════════════════════════════════════
class _ReviewsTab extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final reviews = controller.technicianReviews;
      final tech = controller.selectedTechnician.value;
      final avgRating = tech?.rating ?? 0;
      final totalRatings = reviews.length;

      // Count per star
      final counts = List.filled(6, 0);
      for (final r in reviews) {
        final s = (r['rating'] as num?)?.toInt() ?? 0;
        if (s >= 1 && s <= 5) counts[s]++;
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ── Rating Summary Card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Big rating number
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < avgRating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalRatings Reviewed',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Star bars
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = counts[star];
                      final pct = totalRatings > 0 ? count / totalRatings : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$star',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  color: _ratingBarColor(star),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${(pct * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No reviews yet.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
              ),
            )
          else
            ...reviews.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(review: r),
                )),

          const SizedBox(height: 80),
        ],
      );
    });
  }

  Color _ratingBarColor(int star) {
    if (star >= 4) return const Color(0xFF10B981);
    if (star == 3) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final name = review['reviewerName'] as String? ?? '-';
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment'] as String? ?? '';
    final date = review['date'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _ink,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 13,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 13,
                color: _muted,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ABOUT TAB
// ════════════════════════════════════════════════════════════════════════════
void _showCertViewer(BuildContext context, List<String> urls, int initialIndex) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: urls.length,
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: Image.network(urls[i], fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 12, right: 12,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 16, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == initialIndex ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == initialIndex ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ],
      ),
    ),
  );
}

class _AboutTab extends GetView<BookingController> {
  final TechnicianOnlineModel tech;
  const _AboutTab({required this.tech});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ── About / Bio ─────────────────────────────────────────
        _SectionCard(
          title: 'ABOUT',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tech.specialty.isEmpty ? tech.category : tech.specialty} technician '
                'with ${tech.yearsExperience > 0 ? tech.yearsExperience : 1}+ years of experience. '
                'Serves various brands and models. Work guarantee.',
                style: const TextStyle(
                  fontSize: 13,
                  color: _muted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Details ─────────────────────────────────────────────
        _SectionCard(
          title: 'DETAILS',
          child: Column(
            children: [
              _DetailRow(label: 'Service area', value: tech.workshopAddress.isEmpty
                  ? 'Yogyakarta, Sleman'
                  : tech.workshopAddress),
              _DetailRow(label: 'Service method', value: 'Pick-up & return only'),
              _DetailRow(label: 'Experience', value: '${tech.yearsExperience > 0 ? tech.yearsExperience : 1} years'),
              _DetailRow(label: 'Verification', value: 'Certified', isGreen: true),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Certifications ──────────────────────────────────────
        if (tech.accreditations.isNotEmpty || tech.certificationUrls.isNotEmpty)
          _SectionCard(
            title: 'CERTIFICATION',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo tiles (horizontal scroll)
                if (tech.certificationUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tech.certificationUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _showCertViewer(context, tech.certificationUrls, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Image.network(
                                tech.certificationUrls[i],
                                width: 140,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 140,
                                  height: 100,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.broken_image_outlined,
                                      color: _muted),
                                ),
                              ),
                              Positioned(
                                bottom: 6, right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.zoom_in_rounded,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Name chips
                if (tech.accreditations.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tech.accreditations
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 13, color: _blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _blue,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  )
                else if (tech.certificationUrls.isNotEmpty)
                  const Text(
                    'Certificate photos available.',
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
              ],
            ),
          ),

        if (tech.accreditations.isNotEmpty) const SizedBox(height: 14),

        // ── Workshop Location ────────────────────────────────────
        _SectionCard(
          title: 'WORKSHOP LOCATION',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini map
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: tech.lat != null && tech.lng != null
                      ? _WorkshopMap(lat: tech.lat!, lng: tech.lng!)
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined,
                                    size: 32, color: _muted),
                                SizedBox(height: 6),
                                Text(
                                  'Location not set',
                                  style: TextStyle(color: _muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tech.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tech.workshopAddress.isEmpty
                    ? 'Address not filled'
                    : tech.workshopAddress,
                style: const TextStyle(fontSize: 12, color: _muted, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (tech.lat != null && tech.lng != null) {
                          MapsLauncher.navigateTo(
                            lat: tech.lat!,
                            lng: tech.lng!,
                            label: tech.name,
                          );
                        } else if (tech.workshopAddress.isNotEmpty) {
                          MapsLauncher.searchAddress(tech.workshopAddress);
                        } else {
                          Get.snackbar(
                            'Location not available',
                            'Technician has not filled in workshop address',
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 15),
                      label: const Text(
                        'OPEN IN MAPS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: tech.workshopAddress),
                        );
                        Get.snackbar(
                          'Copied',
                          'Address copied to clipboard',
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _muted,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      label: const Text(
                        'COPY ADDRESS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Send a message ───────────────────────────────────────
        ElevatedButton.icon(
          onPressed: controller.openPreChat,
          style: ElevatedButton.styleFrom(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          icon: const Icon(Icons.send_rounded, size: 17),
          label: const Text(
            'Send a message',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen;
  const _DetailRow({required this.label, required this.value, this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isGreen ? const Color(0xFF10B981) : _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workshop Mapbox Widget ─────────────────────────────────────────────────
class _WorkshopMap extends StatefulWidget {
  final double lat;
  final double lng;
  const _WorkshopMap({required this.lat, required this.lng});

  @override
  State<_WorkshopMap> createState() => _WorkshopMapState();
}

class _WorkshopMapState extends State<_WorkshopMap> {
  mapbox.CircleAnnotationManager? _circleManager;

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    await map.gestures.updateSettings(mapbox.GesturesSettings(
      scrollEnabled: false,
      rotateEnabled: false,
      pitchEnabled: false,
      pinchToZoomEnabled: false,
      doubleTapToZoomInEnabled: false,
      doubleTouchToZoomOutEnabled: false,
      quickZoomEnabled: false,
    ));

    _circleManager = await map.annotations.createCircleAnnotationManager();
    await _circleManager?.create(
      mapbox.CircleAnnotationOptions(
        geometry: mapbox.Point(
            coordinates: mapbox.Position(widget.lng, widget.lat)),
        circleRadius: 10.0,
        circleColor: 0xFFEF4444,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      key: ValueKey('workshop_map_${widget.lat}_${widget.lng}'),
      styleUri: mapbox.MapboxStyles.OUTDOORS,
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
            coordinates: mapbox.Position(widget.lng, widget.lat)),
        zoom: 14.0,
      ),
      onMapCreated: _onMapCreated,
    );
  }
}
