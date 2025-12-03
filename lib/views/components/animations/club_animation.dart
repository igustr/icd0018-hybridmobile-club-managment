import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum ClubAnimationType { loading, error, empty, dataNotFound }

class ClubAnimation extends StatelessWidget {
  const ClubAnimation({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.size = 220,
    this.repeat,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final ClubAnimationType type;
  final String? title;
  final String? subtitle;
  final double size;
  final bool? repeat;
  final EdgeInsets padding;

  String get _assetPath {
    switch (type) {
      case ClubAnimationType.loading:
        return 'assets/animations/club_loading.json';
      case ClubAnimationType.error:
        return 'assets/animations/club_error.json';
      case ClubAnimationType.empty:
        return 'assets/animations/club_empty.json';
      case ClubAnimationType.dataNotFound:
        return 'assets/animations/club_not_found.json';
    }
  }

  bool get _shouldRepeat => repeat ?? type == ClubAnimationType.loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            _assetPath,
            height: size,
            width: size,
            repeat: _shouldRepeat,
          ),
          if (title != null) ...[
            Text(
              title!,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (subtitle != null)
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
