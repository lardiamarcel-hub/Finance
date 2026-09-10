import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/new_client_sheet.dart';
import 'client_detail_screen.dart';

/// Carnet de clients : nom + téléphone + total des achats. Un tap ouvre
/// toute l'histoire de ce client.
class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final clients = repo.clientsSortedByName;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes clients')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.orange,
        onPressed: () async {
          final client = await showNewClientSheet(context);
          if (client != null && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: client.id)),
            );
          }
        },
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
      body: clients.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pas encore de client.\nTouche le bouton + pour en ajouter un.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final client = clients[index];
                final totalPurchases = repo.totalPurchasesForClient(client.id);
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: client.id)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          InitialAvatar(initial: client.initial),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                if (client.phone.isNotEmpty)
                                  Text(client.phone, style: const TextStyle(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          if (totalPurchases > 0)
                            Text(
                              formatFcfa(totalPurchases),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
