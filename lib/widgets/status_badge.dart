import 'package:flutter/material.dart';

import '../models/devis.dart';
import '../utils/app_theme.dart';

/// Statut représenté uniquement par une couleur + un pictogramme, jamais par
/// du texte technique (principe de conception n°10).
class StatusBadge extends StatelessWidget {
  final DevisStatus status;
  final double size;

  const StatusBadge({super.key, required this.status, this.size = 16});

  Color get _color {
    switch (status) {
      case DevisStatus.enAttente:
        return AppColors.amber;
      case DevisStatus.accepte:
        return AppColors.green;
      case DevisStatus.refuse:
        return AppColors.red;
    }
  }

  IconData get _icon {
    switch (status) {
      case DevisStatus.enAttente:
        return Icons.hourglass_top_rounded;
      case DevisStatus.accepte:
        return Icons.check_circle_rounded;
      case DevisStatus.refuse:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      child: Icon(_icon, color: Colors.white, size: size * 1.3),
    );
  }
}

String statusLabel(DevisStatus status, {required bool isPaid}) {
  switch (status) {
    case DevisStatus.enAttente:
      return 'En attente';
    case DevisStatus.accepte:
      return isPaid ? 'Payé' : 'Accepté';
    case DevisStatus.refuse:
      return 'Refusé';
  }
}
