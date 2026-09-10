import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Gros bouton icône + texte, pensé pour être touché facilement avec le
/// pouce. Utilisé partout où l'app propose une action principale.
class BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;

  const BigActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.orange,
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: foreground),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icône ronde simple (pour la barre du haut : clients, catalogue, etc.)
class IconTapButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const IconTapButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.orangeDark),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
