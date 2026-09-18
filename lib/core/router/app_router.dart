import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_shell.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/home/home_page.dart';
import '../../features/events/events_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',

  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  redirect: (context, state) {
    final session =
        Supabase.instance.client.auth.currentSession;

    final loggedIn = session != null;

    final isAuthPage =
        state.uri.path == '/login' ||
        state.uri.path == '/signup';

    // User is not logged in.
    // Keep them on authentication pages.
    if (!loggedIn && !isAuthPage) {
      return '/login';
    }

    // User is already logged in.
    // Don't allow them back into login/signup.
    if (loggedIn && isAuthPage) {
      return '/home';
    }

    return null;
  },

  routes: [
    // -------------------------
    // AUTH
    // -------------------------

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginPage();
      },
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) {
        return const SignupPage();
      },
    ),

    // -------------------------
    // MAIN APP
    // -------------------------

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return const HomePage();
            },
          ),

        GoRoute(
          path: '/discover',
          builder: (context, state) {
            return const PlaceholderPage(
              title: 'Discover',
              icon: Icons.explore_rounded,
            );
          },
        ),

        GoRoute(
          path: '/events',
          builder: (context, state) {
            return const EventsPage();
          },
        ),

        GoRoute(
          path: '/clubs',
          builder: (context, state) {
            return const PlaceholderPage(
              title: 'My Clubs',
              icon: Icons.groups_rounded,
            );
          },
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) {
            return const ProfilePage();
            },
          ),
        ],
      ),
    ],
  );

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'This section is coming together.',
          ),
        ],
      ),
    );
  }
}