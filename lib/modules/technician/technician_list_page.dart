import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TechnicianListPage extends StatelessWidget {
  const TechnicianListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildCategoryFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 10),
                  const _TechnicianCard(
                    name: 'Marcus Thorne',
                    specialty: 'HEAVY APPLIANCES EXPERT',
                    rating: '4.9',
                    distance: '0.8 km',
                    isVerified: true,
                    imageUrl: 'https://i.pravatar.cc/300?u=marcus',
                  ),
                  const SizedBox(height: 16),
                  const _TechnicianCard(
                    name: 'Elena Rodriguez',
                    specialty: 'IT & COMPUTING',
                    rating: '5.0',
                    distance: '1.2 km',
                    isVerified: false,
                    jobs: '200+ Jobs',
                    imageUrl: 'https://i.pravatar.cc/300?u=elena_rodriguez',
                  ),
                  const SizedBox(height: 16),
                  const _TechnicianCard(
                    name: 'Julian Vance',
                    specialty: 'SMART HOME SYSTEMS',
                    rating: '4.8',
                    distance: '2.5 km',
                    isVerified: true,
                    imageUrl: 'https://i.pravatar.cc/300?u=julian',
                  ),
                  const SizedBox(height: 16),
                  const _TechnicianCard(
                    name: 'Sarah Chen',
                    specialty: 'MOBILE DEVICE REPAIR',
                    rating: '4.7',
                    distance: '3.1 km',
                    isVerified: true,
                    imageUrl: 'https://i.pravatar.cc/300?u=sarah',
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            splashRadius: 24,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Available Technicians',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search professional...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Laptop', 'TV', 'HVAC', 'Smartphone', 'Audio'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String distance;
  final String imageUrl;
  final bool isVerified;
  final String? jobs;

  const _TechnicianCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.isVerified,
    this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0061FF)),
                        const SizedBox(width: 4),
                        const Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'VIEW PROFILE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'BOOK NOW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.0,
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
