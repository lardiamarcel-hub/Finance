import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../services/share_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/collection_extensions.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/money_text.dart';
import '../../widgets/status_badge.dart';
import '../devis/devis_detail_screen.dart';

/// Fiche client : coordonnées, appel/WhatsApp en un tap, et tout
/// l'historique de ses devis/factures.
class ClientDetailScreen extends StatelessWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final client = repo.clients.where((c) => c.id == clientId).firstOrNull;

    if (client == null) {
      return const Scaffold(body: Center(child: Text('Client introuvable.')));
    }

    final history = repo.devisForClient(clientId);
    final totalPurchases = repo.totalPurchasesForClient(clientId);

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: InitialAvatar(initial: client.initial, radius: 40)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              client.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          if (client.phone.isNotEmpty)
            Center(
              child: Text(client.phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
            ),
          const SizedBox(height: 20),
          if (client.phone.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ShareService.callPhone(client.phone),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Appeler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ShareService.openWhatsAppChat(phone: client.phone),
                    icon: const Icon(Icons.chat_rounded, color: AppColors.green),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Total des achats', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                MoneyText(amount: totalPurchases, fontSize: 26, color: AppColors.green),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Aucun devis pour ce client pour l\'instant.',
                  style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...history.map(
              (devis) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DevisDetailScreen(devisId: devis.id)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          StatusBadge(status: devis.status),
                          const SizedBox(width: 12),
                          Expanded(child: Text(formatDateShortFr(devis.createdAt))),
                          MoneyText(amount: devis.total, fontSize: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
