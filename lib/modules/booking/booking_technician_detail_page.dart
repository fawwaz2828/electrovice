import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/booking_model.dart';
import 'booking_controller.dart';

class BookingTechnicianDetailPage extends GetView<BookingController> {
  const BookingTechnicianDetailPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);
  static const Color _card = Colors.white;
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF737B8C);
  static const Color _chip = Color(0xFFDDE8FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final CustomerTechnicianDetail tech = controller.technicianData;

          return Column(
            children: [
              _TopBar(title: 'Technician Details'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(tech: tech),
                      const SizedBox(height: 14),
                      _TitleRow(title: 'ACCREDITATIONS'),
                      const SizedBox(height: 10),
                      _AccreditationsCard(items: tech.accreditations),
                      const SizedBox(height: 14),
                      _GuaranteeCard(text: tech.guaranteeText),
                      const SizedBox(height: 14),
                      _TitleRow(title: 'SERVICE ESTIMATES', trailing: Icons.payments_outlined),
                      const SizedBox(height: 10),
                      _EstimateCard(estimates: tech.estimates),
                      const SizedBox(height: 14),
                      _LocationCard(
                        title: tech.workshopName,
                        subtitle: tech.workshopAddress,
                      ),
                      const SizedBox(height: 14),
                      const _SectionHeader(
                        title: 'USER REVIEWS',
                        actionLabel: 'See All',
                      ),
                      const SizedBox(height: 10),
                      ...tech.reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      const Expanded(
                        child: _FooterHint(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () => Get.toNamed(AppRoutes.createOrder),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'BOOK NOW',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: BookingTechnicianDetailPage._ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.tech});

  final CustomerTechnicianDetail tech;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BookingTechnicianDetailPage._card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _AvatarCard(imageUrl: tech.avatarUrl),
          const SizedBox(height: 14),
          Text(
            tech.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: BookingTechnicianDetailPage._chip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tech.specialty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF325081),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${tech.yearsExperience}+',
                  label: 'YEARS EXP.',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  value: '${tech.successRate}%',
                  label: 'SUCCESS',
                  valueColor: const Color(0xFF8A5A20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  value: tech.rating.toStringAsFixed(1),
                  icon: Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFD9E4F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const _AvatarFallback(),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF3F5E9B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.verified, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF10151C),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Color(0xFFB8C1D4), size: 54),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    this.label,
    this.icon,
    this.valueColor = BookingTechnicianDetailPage._ink,
  });

  final String value;
  final String? label;
  final IconData? icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          if (icon != null)
            const Icon(Icons.star, size: 16, color: Color(0xFF3654FF))
          else
            Text(
              label!,
              style: const TextStyle(
                color: BookingTechnicianDetailPage._muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, this.trailing});

  final String title;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BookingTechnicianDetailPage._ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Icon(trailing, color: BookingTechnicianDetailPage._muted, size: 18),
      ],
    );
  }
}

class _AccreditationsCard extends StatelessWidget {
  const _AccreditationsCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                items[index],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _GuaranteeCard extends StatelessWidget {
  const _GuaranteeCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6DCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Secure Service Guarantee',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: BookingTechnicianDetailPage._muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimates});

  final List<ServiceEstimate> estimates;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: estimates
            .map(
              (estimate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        estimate.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      estimate.priceLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: BookingTechnicianDetailPage._muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        Text(
          actionLabel,
          style: const TextStyle(
            color: Color(0xFF3654FF),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final CustomerReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1D2430),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.author,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: List.generate(
                  review.rating,
                  (_) => const Icon(
                    Icons.star,
                    size: 14,
                    color: Color(0xFF3654FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(
              color: BookingTechnicianDetailPage._muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterHint extends StatelessWidget {
  const _FooterHint();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, color: BookingTechnicianDetailPage._muted),
        SizedBox(height: 4),
        Text(
          'DETAILS',
          style: TextStyle(
            color: BookingTechnicianDetailPage._muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
