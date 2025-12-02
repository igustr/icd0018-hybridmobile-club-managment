import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Views
import 'package:icd0018_hybridmobile_club_managment/views/welcome/welcome_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/authentication/register/register_view.dart';
import '../views/authentication/login/login_view.dart';
import '../views/home/home_view.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
      child: Text(
        'Page not found: ${state.uri.path}',
        style: const TextStyle(fontSize: 18, color: Colors.red),
      ),
    ),
  ),
);
