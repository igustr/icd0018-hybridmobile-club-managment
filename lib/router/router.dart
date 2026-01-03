import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Views
import 'package:icd0018_hybridmobile_club_managment/views/components/animations/club_animation.dart';
import 'package:icd0018_hybridmobile_club_managment/views/welcome/welcome_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/authentication/register/register_view.dart';
import '../views/authentication/login/login_view.dart';
import '../views/home/home_view.dart';

// Auth pages that logged-in users should be redirected away from
const _authRoutes = ['/', '/login', '/register'];

// Protected pages that require authentication
const _protectedRoutes = ['/home'];

/// Listenable that notifies when Firebase auth state changes
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authStateNotifier = AuthStateNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authStateNotifier,
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final currentPath = state.uri.path;

    // If logged in and trying to access auth pages, redirect to home
    if (isLoggedIn && _authRoutes.contains(currentPath)) {
      return '/home';
    }

    // If not logged in and trying to access protected pages, redirect to welcome
    if (!isLoggedIn && _protectedRoutes.contains(currentPath)) {
      return '/';
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (context, state) => const WelcomeView(),
    ),

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterView(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
  ],

  // Error message
  errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: ClubAnimation(
            type: ClubAnimationType.dataNotFound,
            title: 'Page not found',
            subtitle: state.uri.path,
          ),
        ),
      ),
);
