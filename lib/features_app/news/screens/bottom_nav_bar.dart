import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      selectedItemColor: const Color.fromARGB(255, 112, 29, 29),
      unselectedItemColor: const Color.fromARGB(255, 18, 17, 17).withAlpha(100),
      iconSize: 30,
      onTap: (int selectedIndex) {
        if (selectedIndex == 0) {
          GoRouter.of(context).go('/main-news');
        } else if (selectedIndex == 1) {
          GoRouter.of(context).go('/profile');
        } else if (selectedIndex == 2) {
          GoRouter.of(context).go('/favorite');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.favorite),
        //   label: 'Favorite',
        // ),
      ],
    );
  }
}
