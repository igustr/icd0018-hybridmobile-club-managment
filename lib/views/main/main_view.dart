import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/authentication_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/user_id_provider.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("User is logged in!$userId"),
            ElevatedButton(
              onPressed: () {
                ref.read(authenticationProvider.notifier).logOut();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
