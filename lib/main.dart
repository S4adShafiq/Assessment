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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/next', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
      GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),
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
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/men/33.jpg',
    'https://randomuser.me/api/portraits/men/34.jpg',
    'https://randomuser.me/api/portraits/men/35.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Tabs
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: Row(
                children: [
                  _TabButton(
                    label: 'For You',
                    selected: true,
                    onTap: () {},
                  ),
                  _TabButton(
                    label: 'Explore',
                    selected: false,
                    onTap: () => context.go('/explore'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _SearchBar(),
            ),
            // Swipable Card
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: _images.length,
                controller: PageController(viewportFraction: 0.92),
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) => _DesignerCard(imageUrl: _images[i]),
              ),
            ),
            // Dots
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentIndex ? const Color(0xFF1B8FFF) : const Color(0xFFD8D8D8),
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
            // Title & Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emerging Designers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Explore small businesses and discover unique, one-of-a-kind looks.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 150,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Shop Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // For You Section (bottom cards)
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Text('For You:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _ProductCard(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(selected: 0),
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
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: Row(
                children: [
                  _TabButton(
                    label: 'For You',
                    selected: false,
                    onTap: () => context.go('/next'),
                  ),
                  _TabButton(
                    label: 'Explore',
                    selected: true,
                    onTap: () {},
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _SearchBar(),
            ),
            // Trending Brands
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Trending Brands',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Loved by the community, picked by us — these brands are changing the game from the ground up.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _BrandTile(
                    name: "Amanda's Boutique",
                    desc: 'A modern designer with a youthful spirit, dedicated to hand-making every piece with care...',
                    imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
                  ),
                  _BrandTile(
                    name: 'Nike',
                    desc: 'Just Do It',
                    imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
                  ),
                  _BrandTile(
                    name: 'LOST COINS',
                    desc: '',
                    imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
                  ),
                  _BrandTile(
                    name: 'Yousaf',
                    desc: 'Wear the mood, not the label.',
                    imageUrl: 'https://randomuser.me/api/portraits/men/47.jpg',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Image(
                        image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/6/6a/World_Flag_Map.png'),
                        width: 48,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Explore the Global Scene',
                          style: TextStyle(
                            color: Color(0xFF1B8FFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(selected: 0),
    );
  }
}

// Helper widgets for UI structure
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: selected ? Colors.black : const Color(0xFFB4B4B4),
              ),
            ),
            const SizedBox(height: 2),
            if (selected)
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8FFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFFB4B4B4)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your product...',
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: Color(0xFFB4B4B4),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFFB4B4B4)),
              onPressed: () {},
            ),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  width: 180,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 18,
              child: const Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3E3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_bag, size: 32, color: Color(0xFF1B8FFF)),
          ),
          const SizedBox(height: 8),
          const Text('Product', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final String name;
  final String desc;
  final String imageUrl;
  const _BrandTile({required this.name, required this.desc, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                if (desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF6F6F6F))),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('More', style: TextStyle(color: Color(0xFF1B8FFF), fontWeight: FontWeight.w700)),
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
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarIcon(icon: Icons.storefront, label: 'Shop', selected: selected == 0),
          _NavBarIcon(icon: Icons.shopping_cart, label: 'Cart', selected: false),
          _NavBarIcon(icon: Icons.person, label: 'Profile', selected: false),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _NavBarIcon({required this.icon, required this.label, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: selected ? const Color(0xFF1B8FFF) : const Color(0xFFB4B4B4), size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1B8FFF) : const Color(0xFFB4B4B4),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
