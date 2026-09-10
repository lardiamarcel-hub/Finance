import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/big_action_button.dart';
import 'devis_detail_screen.dart';

/// Confirmation visuelle simple et immédiate après l'envoi d'un devis
/// (principe de conception n°10 : une grande coche verte, pas de texte).
class DevisSentScreen extends StatelessWidget {
  final String devisId;

  const DevisSentScreen({super.key, required this.devisId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 90),
              ),
              const SizedBox(height: 28),
              const Text(
                'Devis envoyé !',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              BigActionButton(
                icon: Icons.description_rounded,
                label: 'Voir le devis',
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => DevisDetailScreen(devisId: devisId)),
                  );
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
