import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/money_text.dart';
import '../../widgets/new_client_sheet.dart';
import '../../widgets/status_badge.dart';
import '../catalog/catalog_screen.dart';
import '../clients/client_detail_screen.dart';
import '../clients/clients_list_screen.dart';
import '../devis/devis_detail_screen.dart';
import '../devis/devis_wizard_screen.dart';
import '../sales/sales_summary_screen.dart';
import '../settings/settings_screen.dart';

/// Écran d'accueil : les devis/factures récents, et les 2 actions
/// principales bien visibles ("Nouveau devis", "Nouveau client").
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final recent = repo.devisSortedByDateDesc;

    return Scaffold(
      appBar: AppBar(
        title: Text(repo.company.name.isEmpty ? 'Devis Sap Sap' : repo.company.name),
        actions: [
          IconTapButton(
            icon: Icons.people_alt_rounded,
            label: 'Clients',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ClientsListScreen())),
          ),
          IconTapButton(
            icon: Icons.inventory_2_rounded,
            label: 'Produits',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CatalogScreen())),
          ),
          IconTapButton(
            icon: Icons.bar_chart_rounded,
            label: 'Ventes',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SalesSummaryScreen())),
          ),
          IconTapButton(
            icon: Icons.settings_rounded,
            label: 'Réglages',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: BigActionButton(
                    icon: Icons.add_circle_rounded,
                    label: 'Nouveau devis',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const DevisWizardScreen())),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: BigActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Nouveau client',
                    color: AppColors.green,
                    onTap: () async {
                      final client = await showNewClientSheet(context);
                      if (client != null && context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: client.id)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: recent.isEmpty
                ? const _EmptyHome()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final devis = recent[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DevisDetailScreen(devisId: devis.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                StatusBadge(status: devis.status),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        devis.clientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        formatDateShortFr(devis.createdAt),
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                MoneyText(amount: devis.total, fontSize: 17),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textMuted),
            SizedBox(height: 14),
            Text(
              'Aucun devis pour l\'instant.\nTouche "Nouveau devis" pour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
