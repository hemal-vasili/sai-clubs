import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  static const destinations = [
    _Destination(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      path: '/home',
    ),
    _Destination(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      path: '/discover',
    ),
    _Destination(
      label: 'Events',
      icon: Icons.event_outlined,
      activeIcon: Icons.event_rounded,
      path: '/events',
    ),
    _Destination(
      label: 'Clubs',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      path: '/clubs',
    ),
    _Destination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      path: '/profile',
    ),
  ];

  int getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final index = destinations.indexWhere(
      (destination) => location == destination.path ||
          location.startsWith('${destination.path}/'),
    );

    return index == -1 ? 0 : index;
  }

  void navigate(BuildContext context, int index) {
    context.go(destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final selectedIndex = getCurrentIndex(context);

    // ─────────────────────────────────────────────
    // MOBILE
    // ─────────────────────────────────────────────

    if (width < 700) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const _Brand(
            compact: true,
          ),
          actions: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            navigate(context, index);
          },
          destinations: destinations.map(
            (destination) {
              return NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(
                  destination.activeIcon,
                ),
                label: destination.label,
              );
            },
          ).toList(),
        ),
      );
    }

    // ─────────────────────────────────────────────
    // DESKTOP / TABLET
    // ─────────────────────────────────────────────

    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            selectedIndex: selectedIndex,
            onSelected: (index) {
              navigate(context, index);
            },
          ),
          Expanded(
            child: Column(
              children: [
                const _DesktopHeader(),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// DESKTOP SIDEBAR
// ═══════════════════════════════════════════════════

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(
              alpha: 0.35,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // BRAND
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: _Brand(),
            ),

            const SizedBox(height: 36),

            // NAVIGATION
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount: AppShell.destinations.length,
                itemBuilder: (context, index) {
                  final destination =
                      AppShell.destinations[index];

                  final selected =
                      selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 6,
                    ),
                    child: ListTile(
                      selected: selected,
                      selectedTileColor:
                          colors.primary.withValues(
                        alpha: 0.10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        selected
                            ? destination.activeIcon
                            : destination.icon,
                        color: selected
                            ? colors.primary
                            : null,
                      ),
                      title: Text(
                        destination.label,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      onTap: () => onSelected(index),
                    ),
                  );
                },
              ),
            ),

            // FOOTER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sai University',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// DESKTOP HEADER
// ═══════════════════════════════════════════════════

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(
              alpha: 0.35,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),

          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          const SizedBox(width: 12),

          // Temporary profile icon.
          // We will connect this to the real user profile.
          CircleAvatar(
            radius: 19,
            backgroundColor: colors.primary,
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// BRAND
// ═══════════════════════════════════════════════════

class _Brand extends StatelessWidget {
  final bool compact;

  const _Brand({
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(
              compact ? 11 : 12,
            ),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          'SaiClubs',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// NAVIGATION DESTINATION
// ═══════════════════════════════════════════════════

class _Destination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _Destination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}