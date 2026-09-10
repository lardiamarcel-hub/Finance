import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../widgets/big_action_button.dart';

/// Étape 4 : choisir comment envoyer le devis. Trois gros boutons, une
/// seule action possible à la fois.
class SendStep extends StatelessWidget {
  final bool isSending;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onSendSms;
  final VoidCallback onDownloadPdf;

  const SendStep({
    super.key,
    required this.isSending,
    required this.onSendWhatsApp,
    required this.onSendSms,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (isSending) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.orange),
            SizedBox(height: 16),
            Text('Préparation du document...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.send_rounded, size: 48, color: AppColors.orangeDark),
          const SizedBox(height: 12),
          const Text(
            'Le devis est prêt.\nComment veux-tu l\'envoyer ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 28),
          BigActionButton(
            icon: Icons.chat_rounded,
            label: 'Envoyer par WhatsApp',
            color: AppColors.green,
            onTap: onSendWhatsApp,
          ),
          const SizedBox(height: 16),
          BigActionButton(
            icon: Icons.sms_rounded,
            label: 'Envoyer par SMS',
            color: AppColors.orange,
            onTap: onSendSms,
          ),
          const SizedBox(height: 16),
          BigActionButton(
            icon: Icons.download_rounded,
            label: 'Télécharger en PDF',
            color: AppColors.orangeDark,
            onTap: onDownloadPdf,
          ),
        ],
      ),
    );
  }
}
