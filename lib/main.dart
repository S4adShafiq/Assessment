import 'dart:async';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth.dart'; // Extracted onboarding/auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/next', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _images = [
    'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=800',
    'https://images.unsplash.com/photo-1550246140-5119ae4790b8?w=800',
    'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopTabs(isExplore: false),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _SearchBar(),
                    ),
                    const _FilterChips(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        itemCount: _images.length,
                        controller: PageController(viewportFraction: 0.92),
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemBuilder: (context, i) =>
                            _DesignerCard(imageUrl: _images[i]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emerging Designers',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF333333),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Explore small businesses and discover unique, one-of-a-kind looks.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F6F6F),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF071424),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Shop Now',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(_images.length, (i) {
                                  final isActive = i == _currentIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: isActive ? 14 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFF1B8FFF)
                                          : const Color(0xFFD8D8D8),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'For You:',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _StaggeredGridSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(selected: 0),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopTabs(isExplore: true),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _SearchBar(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Trending Brands',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF333333),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Loved by the community, picked by us — these brands are changing the game from the ground up.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F6F6F),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: const [
                          _BrandTile(
                            name: "Amanda's Boutique",
                            desc:
                                'A modern designer with a youthful spirit, dedicated to hand-making every piece with care...',
                            imageUrl:
                                'https://randomuser.me/api/portraits/women/44.jpg',
                          ),
                          _BrandTile(
                            name: 'Nike',
                            desc: 'Just Do It',
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/45.jpg',
                          ),
                          _BrandTile(
                            name: 'LOST COINS',
                            desc: '',
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/46.jpg',
                          ),
                          _BrandTile(
                            name: 'Yousaf',
                            desc: 'Wear the mood, not the label.',
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/47.jpg',
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Image(
                            image: NetworkImage(
                              'https://upload.wikimedia.org/wikipedia/commons/6/6a/World_Flag_Map.png',
                            ),
                            width: 60,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Explore the Global Scene >',
                              style: TextStyle(
                                color: Color(0xFF1B8FFF),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(selected: 0),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final bool isExplore;
  const _TopTabs({required this.isExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isExplore) context.go('/next');
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: !isExplore
                          ? const Color(0xFF1B8FFF)
                          : const Color(0xFFF0F0F0),
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 12),
                alignment: Alignment.center,
                child: Text(
                  'For You',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: !isExplore ? Colors.black : const Color(0xFFB4B4B4),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isExplore) context.go('/explore');
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isExplore
                          ? const Color(0xFF1B8FFF)
                          : const Color(0xFFF0F0F0),
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 12),
                alignment: Alignment.center,
                child: Text(
                  'Explore',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isExplore ? Colors.black : const Color(0xFFB4B4B4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFFB4B4B4)),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your product...',
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: Color(0xFFB4B4B4),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildChip('For You', true),
          const SizedBox(width: 8),
          _buildChip('Men', false),
          const SizedBox(width: 8),
          _buildChip('Women', false),
          const SizedBox(width: 8),
          _buildChip('Jackets', false),
          const SizedBox(width: 8),
          _buildChip('Shoes', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3293FF) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF7A7A7A),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _DesignerCard extends StatelessWidget {
  final String imageUrl;
  const _DesignerCard({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8B8B),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 380,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredGridSection extends StatelessWidget {
  const _StaggeredGridSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _ProductBox(
                      height: 200,
                      imageUrl:
                          'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400',
                      title: 'Box Fit Minecraft Tee',
                      price: 'R4 999.99',
                    ),
                    SizedBox(height: 12),
                    _ProductBox(
                      height: 260,
                      imageUrl:
                          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
                      title: 'Colour Between...',
                      price: 'R16 999.99',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: const [
                    _ProductBox(
                      height: 260,
                      imageUrl:
                          'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400',
                      title: 'Box Fit Minecraft Tee',
                      price: 'R4 999.99',
                    ),
                    SizedBox(height: 12),
                    _ProductBox(
                      height: 200,
                      imageUrl:
                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
                      title: 'A-H-D Oversized Tee',
                      price: 'R899.99',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _FullWidthShoeCard(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _ProductBox(
                      height: 240,
                      imageUrl:
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
                      title: '"No Breeze" Wind Br...',
                      price: 'R16 999.99',
                    ),
                    SizedBox(height: 12),
                    _PromoCard(
                      title: 'Exclusively\non Swéy...',
                      height: 120,
                      color: Color(0xFF007BFF),
                    ),
                    SizedBox(height: 12),
                    _ProductBox(
                      height: 200,
                      imageUrl:
                          'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400',
                      title: '"No Breeze" Wind Br...',
                      price: 'R16 999.99',
                    ),
                    SizedBox(height: 12),
                    _PromoCard(
                      title: 'Grab the best!',
                      height: 120,
                      color: Color(0xFF007BFF),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: const [
                    _ProductBox(
                      height: 240,
                      imageUrl:
                          'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=400',
                      title: '"No Breeze" Wind Br...',
                      price: 'R16 999.99',
                    ),
                    SizedBox(height: 12),
                    _ProductBox(
                      height: 480,
                      imageUrl:
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
                      title: '',
                      price: '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductBox extends StatelessWidget {
  final double height;
  final String imageUrl;
  final String title;
  final String price;

  const _ProductBox({
    required this.height,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: title.isEmpty
          ? const SizedBox.shrink()
          : Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
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

class _FullWidthShoeCard extends StatelessWidget {
  const _FullWidthShoeCard();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/women/2.jpg',
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Nike - Off White Air Prestos [Virgil Abloah 2019]',
                style: TextStyle(
                  color: Color(0xFF909090),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Text(
              'R4 999.99',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final double height;
  final Color color;

  const _PromoCard({
    required this.title,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.arrow_outward, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final String name;
  final String desc;
  final String imageUrl;
  const _BrandTile({
    required this.name,
    required this.desc,
    required this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF222222),
                  ),
                ),
                if (desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6F6F6F),
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'More',
              style: TextStyle(
                color: Color(0xFF1B8FFF),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selected;
  const _BottomNavBar({required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarIcon(
            icon: Icons.storefront,
            label: 'Shop',
            selected: selected == 0,
          ),
          _NavBarIcon(
            icon: Icons.shopping_cart_outlined,
            label: 'Cart',
            selected: selected == 1,
          ),
          _NavBarIcon(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: selected == 2,
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected ? const Color(0xFF1B8FFF) : const Color(0xFFB4B4B4),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1B8FFF) : const Color(0xFFB4B4B4),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
