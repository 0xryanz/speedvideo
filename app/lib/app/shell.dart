import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/utils/responsive.dart';
import 'tv_nav_rail.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isTv(context)) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            TvNavRail(
              currentIndex: navigationShell.currentIndex,
              onSelected: _select,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_fire_department_outlined),
            selectedIcon: const Icon(Icons.local_fire_department_rounded),
            label: context.l10n.newHot,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.l10n.myNetflix,
          ),
        ],
      ),
    );
  }
}
