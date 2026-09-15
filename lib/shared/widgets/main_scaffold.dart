import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// MainScaffold is used as the shell for the bottom-navigation routes.
/// The [child] is provided by GoRouter's ShellRoute.
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  // Ordered list matching _navItems below (skip the FAB slot at index 2)
  static const _routes = [
    '/home',
    '/wallet',
    null,          // FAB slot — handled separately
    '/history',
    '/charts',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _selectedIndex(location);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: child,
      floatingActionButton: _CentralFAB(
        onTap: () => context.push('/add-transaction'),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) return; // FAB handled above
          final route = _routes[index];
          if (route != null) context.go(route);
        },
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/wallet')) return 1;
    if (location.startsWith('/history')) return 3;
    if (location.startsWith('/charts')) return 4;
    return 0; // home is default
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet,
        label: 'Wallet'),
    _NavItem(icon: Icons.add, activeIcon: Icons.add, label: ''), // FAB slot
    _NavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'History'),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Charts'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        border: const Border(
          top: BorderSide(color: Color(0xFF00E5FF), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;

              // FAB placeholder — leave space for the centred FAB
              if (idx == 2) {
                return const Expanded(child: SizedBox.shrink());
              }

              final isActive = currentIndex == idx;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(idx),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          key: ValueKey(isActive),
                          color: isActive
                              ? const Color(0xFF00E5FF)
                              : Colors.white38,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF00E5FF)
                              : Colors.white38,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item data class ───────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

// ── Central FAB ───────────────────────────────────────────────────────────────
class _CentralFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _CentralFAB({required this.onTap});

  @override
  State<_CentralFAB> createState() => _CentralFABState();
}

class _CentralFABState extends State<_CentralFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.88).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF0097A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
    );
  }
}
