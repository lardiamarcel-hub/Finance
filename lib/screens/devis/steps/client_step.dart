import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/app_repository.dart';
import '../../../models/client.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/initial_avatar.dart';
import '../../../widgets/new_client_sheet.dart';

/// Étape 1 : choisir un client existant, ou en créer un nouveau en 2 champs
/// (nom + téléphone) sans quitter l'écran.
class ClientStep extends StatelessWidget {
  final Client? selectedClient;
  final ValueChanged<Client> onSelect;

  const ClientStep({super.key, required this.selectedClient, required this.onSelect});

  Future<void> _openNewClientSheet(BuildContext context) async {
    final client = await showNewClientSheet(context);
    if (client != null) onSelect(client);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final clients = repo.clientsSortedByName;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: OutlinedButton.icon(
            onPressed: () => _openNewClientSheet(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Nouveau client'),
          ),
        ),
        Expanded(
          child: clients.isEmpty
              ? const _EmptyClients()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    final selected = client.id == selectedClient?.id;
                    return Material(
                      color: selected ? AppColors.orange.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onSelect(client),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? AppColors.orange : Colors.grey.shade200,
                              width: selected ? 2 : 1,
                            ),
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
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (client.phone.isNotEmpty)
                                      Text(
                                        client.phone,
                                        style: const TextStyle(color: AppColors.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.orange),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyClients extends StatelessWidget {
  const _EmptyClients();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Pas encore de client.\nAjoute-en un pour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
