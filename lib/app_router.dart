import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/register_organization_screen.dart';
import 'ui/screens/register_member_screen.dart';
import 'ui/screens/main_shell.dart';

import 'ui/screens/create_post_screen.dart';
import 'ui/screens/create_event_screen.dart';
import 'ui/screens/discover_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/edit_profile_screen.dart';
import 'ui/screens/settings/accessibility_settings_screen.dart';
import 'ui/screens/community_screen.dart';

import 'data/models/user_models.dart';
import 'data/models/post_models.dart';
import 'ui/screens/post_details_screen.dart';
import 'ui/screens/event_details_screen.dart';
import 'ui/screens/settings/invite_codes_screen.dart';
import 'ui/screens/notifications_screen.dart';
import 'data/models/event_models.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
      redirect: (context, state) async {
        final authService = context.read<AuthService>();
        final isLoggedIn = await authService.isLoggedIn();
        debugPrint("Welcome Screen redirecting, isLoggedIn: $isLoggedIn");
        if (isLoggedIn) {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register/org',
      builder: (context, state) => const RegisterOrganizationScreen(),
    ),
    GoRoute(
      path: '/register/member',
      builder: (context, state) => const RegisterMemberScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/discover',
          builder: (context, state) => const DiscoverScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/users/:userId',
          builder: (context, state) {
            final userIdStr = state.pathParameters['userId'];
            final userId = int.tryParse(userIdStr ?? '');
            return ProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/event-details',
          builder: (context, state) {
            final event = state.extra as Event;
            return EventDetailsScreen(event: event);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/create_post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/create_event',
      builder: (context, state) => const CreateEventScreen(),
    ),
    GoRoute(
      path: '/settings/accessibility',
      builder: (context, state) => const AccessibilitySettingsScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) {
        final user = state.extra as UserPublic;
        return EditProfileScreen(user: user);
      },
    ),
    GoRoute(
      path: '/post_details',
      builder: (context, state) {
        final post = state.extra as PostPublic;
        return PostDetailsScreen(post: post);
      },
    ),
    GoRoute(
      path: '/invite-codes',
      builder: (context, state) => const InviteCodesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);
