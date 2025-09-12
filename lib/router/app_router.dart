import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pavo_flutter/features/auth/providers/auth_provider.dart';
import 'package:pavo_flutter/features/auth/screens/sign_in_screen.dart';
import 'package:pavo_flutter/features/auth/screens/sign_up_screen.dart';
import 'package:pavo_flutter/features/dashboard/screens/dashboard_screen.dart';
import 'package:pavo_flutter/features/photos/screens/photos_screen.dart';
import 'package:pavo_flutter/features/videos/screens/videos_screen.dart';
import 'package:pavo_flutter/features/documents/screens/documents_screen.dart';
import 'package:pavo_flutter/features/media/movies/screens/movies_screen.dart';
import 'package:pavo_flutter/features/media/tv_shows/screens/tv_shows_screen.dart';
import 'package:pavo_flutter/features/media/music/screens/music_screen.dart';
import 'package:pavo_flutter/features/media/audiobooks/screens/audiobooks_screen.dart';
import 'package:pavo_flutter/features/settings/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/signin' || 
                         state.matchedLocation == '/signup';
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/signin';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            redirect: (_, __) => '/photos',
          ),
          GoRoute(
            path: '/photos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PhotosScreen(),
            ),
          ),
          GoRoute(
            path: '/videos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideosScreen(),
            ),
          ),
          GoRoute(
            path: '/documents',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentsScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoviesScreen(),
            ),
          ),
          GoRoute(
            path: '/tv-shows',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TVShowsScreen(),
            ),
          ),
          GoRoute(
            path: '/music',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MusicScreen(),
            ),
          ),
          GoRoute(
            path: '/audiobooks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AudiobooksScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});