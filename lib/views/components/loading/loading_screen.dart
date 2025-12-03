import 'package:flutter/material.dart';
import 'package:icd0018_hybridmobile_club_managment/views/components/animations/club_animation.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Loading your club data...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClubAnimation(
          type: ClubAnimationType.loading,
          title: message,
          size: 180,
        ),
      ),
    );
  }
}
