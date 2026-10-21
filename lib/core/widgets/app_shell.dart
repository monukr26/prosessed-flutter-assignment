import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';

/// Authenticated navigation shell providing a bottom navigation bar
/// with Home, Cart (with live badge), and Profile tabs.
///
/// Uses [ShellRoute] child widget pattern — the [child] is the currently
/// active tab's screen.
class AppShell extends ConsumerWidget {
  /// The currently active tab screen rendered by the ShellRoute.
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Maps a router location to a bottom-nav index.
  @visibleForTesting
  static int locationToIndex(String location) {
    if (location.startsWith(AppRoutes.cart)) return 1;
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0; // Home / product details
  }

  /// Maps a bottom-nav index tap to the correct GoRouter path.
  @visibleForTesting
  static void onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.cart);
      case 2:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = locationToIndex(location);
    final totalQuantity = ref.watch(
      cartNotifierProvider.select((s) => s.totalQuantity),
    );
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 768;

    if (isWideScreen) {
      // Tablet / wide layout: NavigationRail on the left
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => onTabTapped(context, i),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primary,
                size: 22,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: totalQuantity > 0,
                    label: Text(
                      totalQuantity > 99 ? '99+' : '$totalQuantity',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: totalQuantity > 0,
                    label: Text(
                      totalQuantity > 99 ? '99+' : '$totalQuantity',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
                  label: const Text('Cart'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone layout: Bottom navigation bar
    return Scaffold(
      body: child,
      bottomNavigationBar: _ShopSphereBottomNav(
        selectedIndex: selectedIndex,
        totalQuantity: totalQuantity,
        onTap: (i) => onTabTapped(context, i),
      ),
    );
  }
}

/// Premium minimalist bottom navigation bar following Direction A design spec.
///
/// - White navigation surface.
/// - Deep indigo selected state [AppColors.primary] (#4338CA).
/// - Muted gray unselected icons and labels.
/// - Subtle top border, restrained shadow.
/// - Clean outline icons.
/// - Safe-area-aware layout.
class _ShopSphereBottomNav extends StatelessWidget {
  final int selectedIndex;
  final int totalQuantity;
  final ValueChanged<int> onTap;

  const _ShopSphereBottomNav({
    required this.selectedIndex,
    required this.totalQuantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navSurface = isDark ? const Color(0xFF1E293B) : Colors.white;
    final topBorderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;
    final unselectedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF9CA3AF);

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final navHeight = (60.0 * textScale).clamp(60.0, 76.0);

    return Container(
      decoration: BoxDecoration(
        color: navSurface,
        border: Border(top: BorderSide(color: topBorderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navHeight,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                unselectedColor: unselectedColor,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag_rounded,
                label: 'Cart',
                badgeCount: totalQuantity,
                unselectedColor: unselectedColor,
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                unselectedColor: unselectedColor,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual bottom-nav tab item with animated selected icon & label.
class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
  final Color unselectedColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional cart badge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Badge(
                  key: ValueKey('badge_${index}_$isSelected'),
                  isLabelVisible: badgeCount > 0,
                  label: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    size: 22,
                    color: isSelected ? AppColors.primary : unselectedColor,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : unselectedColor,
                  letterSpacing: isSelected ? 0.1 : 0.0,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
