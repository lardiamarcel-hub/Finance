import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../models/devis.dart';
import '../../models/devis_item.dart';
import '../../services/pdf_service.dart';
import '../../services/share_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/money_text.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/status_badge.dart';

/// Détail d'un devis/facture, avec les actions possibles selon son statut :
/// accepter, refuser, marquer payé, modifier les quantités, renvoyer.
class DevisDetailScreen extends StatefulWidget {
  final String devisId;

  const DevisDetailScreen({super.key, required this.devisId});

  @override
  State<DevisDetailScreen> createState() => _DevisDetailScreenState();
}

class _DevisDetailScreenState extends State<DevisDetailScreen> {
  bool _isBusy = false;

  Future<void> _withBusy(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resend(Devis devis) async {
    final repo = context.read<AppRepository>();
    final client = repo.clients.firstWhere((c) => c.id == devis.clientId);
    final bytes = await PdfService.generateDevisPdf(
      devis: devis,
      company: repo.company,
      client: client,
    );
    final file = await ShareService.savePdfToDevice(
      bytes,
      '${devis.isInvoice ? 'facture' : 'devis'}_${devis.id.substring(0, 8)}.pdf',
    );
    await ShareService.sharePdf(
      file,
      subject: '${devis.isInvoice ? 'Facture' : 'Devis'} pour ${devis.clientName}',
    );
  }

  Future<void> _shareReceipt(Devis devis) async {
    final repo = context.read<AppRepository>();
    final client = repo.clients.firstWhere((c) => c.id == devis.clientId);
    final bytes = await PdfService.generateReceiptPdf(
      devis: devis,
      company: repo.company,
      client: client,
    );
    final file = await ShareService.savePdfToDevice(
      bytes,
      'recu_${devis.id.substring(0, 8)}.pdf',
    );
    await ShareService.sharePdf(file, subject: 'Reçu de paiement pour ${devis.clientName}');
  }

  Future<void> _editItems(Devis devis) async {
    final repo = context.read<AppRepository>();
    final items = [...devis.items];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final total = items.fold<double>(0, (sum, i) => sum + i.total);
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Modifier les quantités',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                QuantityStepper(
                                  value: item.quantity,
                                  onChanged: (q) => setSheetState(
                                    () => items[index] = item.copyWith(quantity: q),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nouveau total',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                              MoneyText(amount: total, fontSize: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              await repo.updateDevisItems(devis.id, items);
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            child: const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final devis = repo.devisById(widget.devisId);

    if (devis == null) {
      return const Scaffold(body: Center(child: Text('Ce devis n\'existe plus.')));
    }

    final docLabel = devis.isInvoice ? 'Facture' : 'Devis';

    return Scaffold(
      appBar: AppBar(title: Text(docLabel)),
      body: _isBusy
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              devis.clientName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ),
                          StatusBadge(status: devis.status, size: 14),
                          const SizedBox(width: 8),
                          Text(statusLabel(devis.status, isPaid: devis.isPaid)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDateFr(devis.createdAt),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const Divider(height: 28),
                      ...devis.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.productName}  x${item.quantity}'),
                              ),
                              MoneyText(amount: item.total, fontSize: 16),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          MoneyText(amount: devis.total, fontSize: 24),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildActions(devis),
              ],
            ),
    );
  }

  List<Widget> _buildActions(Devis devis) {
    final actions = <Widget>[];

    if (devis.status == DevisStatus.enAttente) {
      actions.addAll([
        BigActionButton(
          icon: Icons.check_circle_rounded,
          label: 'Ce devis est accepté',
          color: AppColors.green,
          onTap: () => _withBusy(() => context.read<AppRepository>().acceptDevisAsInvoice(devis.id)),
        ),
        const SizedBox(height: 12),
        BigActionButton(
          icon: Icons.cancel_rounded,
          label: 'Refusé / annulé',
          color: AppColors.red,
          onTap: () => _withBusy(() => context.read<AppRepository>().refuseDevis(devis.id)),
        ),
      ]);
    } else if (devis.status == DevisStatus.accepte && !devis.isPaid) {
      actions.add(
        BigActionButton(
          icon: Icons.payments_rounded,
          label: 'Marquer payé',
          color: AppColors.green,
          onTap: () => _withBusy(() => context.read<AppRepository>().markDevisAsPaid(devis.id)),
        ),
      );
    } else if (devis.isPaid) {
      actions.add(
        BigActionButton(
          icon: Icons.receipt_long_rounded,
          label: 'Partager le reçu',
          color: AppColors.green,
          onTap: () => _withBusy(() => _shareReceipt(devis)),
        ),
      );
    } else if (devis.status == DevisStatus.refuse) {
      actions.add(
        BigActionButton(
          icon: Icons.check_circle_rounded,
          label: 'Finalement accepté',
          color: AppColors.green,
          onTap: () => _withBusy(() => context.read<AppRepository>().acceptDevisAsInvoice(devis.id)),
        ),
      );
    }

    actions.add(const SizedBox(height: 20));

    final secondaryButtons = <Widget>[];
    if (!devis.isPaid) {
      secondaryButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editItems(devis),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Modifier'),
          ),
        ),
      );
      secondaryButtons.add(const SizedBox(width: 12));
    }
    secondaryButtons.add(
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _withBusy(() => _resend(devis)),
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Renvoyer'),
        ),
      ),
    );
    actions.add(Row(children: secondaryButtons));

    return actions;
  }
}
