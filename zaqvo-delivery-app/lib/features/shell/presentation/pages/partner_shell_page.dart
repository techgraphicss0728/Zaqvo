import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_delivery_app/shared/widgets/partner_bottom_nav_bar.dart';

class PartnerShellPage extends StatelessWidget {
  const PartnerShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: PartnerBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
