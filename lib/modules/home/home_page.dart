import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildHeroCard(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildCurrentRepair(),
                const SizedBox(height: 32),
                _buildCategories(),
                const SizedBox(height: 32),
                _buildSpecialists(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF1E40AF),
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'South Precinct',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF475569), // Fallback if no image
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
          ), // Placeholder map-like texture
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Simulated map pin
          Positioned(
            top: 40,
            left: 120,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.build, color: Colors.white, size: 16),
            ),
          ),
          // White floating card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Nearby\nTechnicians',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12 active specialists available\nnow',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Explore Map',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for hardware repair...',
                hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0061FF), // Bright Blue
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRepair() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Light blue background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT REPAIR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'MacBook Pro M1 •\nScreen Replacement',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6A00), // Orange
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'IN PROGRESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Repair Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // Dark blue
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryItem(Icons.tv, 'TV & AUDIO'),
            _buildCategoryItem(Icons.laptop, 'COMPUTERS'),
            _buildCategoryItem(Icons.kitchen, 'APPLIANCES'),
            _buildCategoryItem(Icons.directions_car, 'VEHICLES'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF334155), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Specialists',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        _buildSpecialistCard(
          name: 'Marcus Thorne',
          specialty: 'HEAVY APPLIANCES EXPERT',
          rating: '4.9',
          distance: '0.8 km',
          verified: true,
          imageUrl:
              'https://i.pravatar.cc/150?u=a042581f4e29026704d', // Placeholder photo 1
        ),
        const SizedBox(height: 16),
        _buildSpecialistCard(
          name: 'Elena Rodriguez',
          specialty: 'IT & COMPUTING',
          rating: '5.0',
          distance: '1.2 km',
          jobs: '200+ Jobs',
          imageUrl:
              'https://i.pravatar.cc/150?u=a042581f4e29026704e', // Placeholder photo 2
        ),
      ],
    );
  }

  Widget _buildSpecialistCard({
    required String name,
    required String specialty,
    required String rating,
    required String distance,
    bool verified = false,
    String? jobs,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A00),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF64748B),
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (verified) ...[
                      const Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF64748B),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'Pro Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (jobs != null) ...[
                      const Icon(
                        Icons.history,
                        color: Color(0xFF64748B),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        jobs,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'HOME', true),
              _buildNavItem(Icons.history, 'HISTORY', false),
              _buildNavItem(Icons.receipt_long_outlined, 'ORDER', false),
              _buildNavItem(Icons.person_outline, 'PROFILE', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? const Color(0xFF0061FF)
                : const Color(0xFF94A3B8),
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0061FF)
                : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
