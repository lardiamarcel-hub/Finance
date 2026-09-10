import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Avatar rond avec l'initiale du nom (pas de photo obligatoire pour un
/// client : juste nom + téléphone au minimum).
class InitialAvatar extends StatelessWidget {
  final String initial;
  final double radius;

  const InitialAvatar({super.key, required this.initial, this.radius = 26});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.orange.withOpacity(0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.orangeDark,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
