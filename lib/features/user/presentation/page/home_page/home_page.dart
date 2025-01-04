import 'package:aleralarma/features/alarm/presentation/page/alarm_page.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_page.dart';
import 'package:aleralarma/features/chat/presentation/page/chat_page.dart';
import 'package:aleralarma/features/user/presentation/page/home_page/navigation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List<Widget> _pages = const [
    ChatPage(),
    AlarmPage(),
    ChatPage(),
  ];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
            ref.read(navigationProvider.notifier).setIndex(index);
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.login),
              title: const Text("Login"),
              selectedColor: const Color(0xFF6C63FF),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.shield_outlined),
              title: const Text("Alarma"),
              selectedColor: const Color(0xFF6C63FF),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              title: const Text("Chat"),
              selectedColor: const Color(0xFF6C63FF),
            ),
          ],
        ),
      ),
    );
  }
}
