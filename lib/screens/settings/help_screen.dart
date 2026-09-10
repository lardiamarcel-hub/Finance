import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

/// Petit écran d'aide illustré, pour les nouveaux utilisateurs : les
/// gestes essentiels de l'app, sans texte dense.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: Icons.add_circle_rounded,
        title: 'Crée un devis',
        text: 'Touche "Nouveau devis" sur l\'écran d\'accueil, puis suis les étapes une par une.',
      ),
      (
        icon: Icons.people_alt_rounded,
        title: 'Choisis ou ajoute un client',
        text: 'Un tap sur un client existant, ou "Nouveau client" avec juste son nom et son numéro.',
      ),
      (
        icon: Icons.auto_awesome_rounded,
        title: "Ou décris ton besoin à l'IA",
        text: 'Sur l\'étape Client, touche l\'étoile ✨ en haut, écris ta demande en une phrase : l\'IA remplit le client et les articles. Vérifie toujours avant d\'envoyer.',
      ),
      (
        icon: Icons.add_shopping_cart_rounded,
        title: 'Ajoute des articles',
        text: 'Choisis dans ta liste de produits, ou crée-en un nouveau. Utilise +/- pour la quantité.',
      ),
      (
        icon: Icons.chat_rounded,
        title: 'Envoie-le',
        text: 'Par WhatsApp, par SMS, ou télécharge le PDF. Ton client reçoit un document propre.',
      ),
      (
        icon: Icons.check_circle_rounded,
        title: 'Suis le statut',
        text: 'Jaune = en attente, vert = accepté ou payé, rouge = refusé. Tout se voit d\'un coup d\'œil.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Comment ça marche')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(step.icon, color: AppColors.orangeDark, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(step.text, style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
