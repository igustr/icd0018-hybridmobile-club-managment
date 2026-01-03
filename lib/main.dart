import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:icd0018_hybridmobile_club_managment/router/router.dart';
import 'package:icd0018_hybridmobile_club_managment/state/notifications/local_notification_service.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  await LocalNotificationService.instance.initialize();
  await LocalNotificationService.instance.requestPermissions();

  // Wait for Firebase Auth to restore the persisted session
  await FirebaseAuth.instance.authStateChanges().first;

  runApp(const ProviderScope(child: ClubManagementApp()));
}

class ClubManagementApp extends StatelessWidget {
  const ClubManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Club Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
