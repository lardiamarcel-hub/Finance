import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/app_repository.dart';
import '../../models/client.dart';
import '../../models/devis_item.dart';
import '../../services/ai_devis_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/collection_extensions.dart';

class AiDevisResult {
  final Client client;
  final List<DevisItem> items;
  AiDevisResult(this.client, this.items);
}

/// Bottom sheet "Décrire avec l'IA" : l'utilisateur écrit son besoin en une
/// phrase, l'IA propose un client + des articles, que le wizard affiche pour
/// vérification avant tout envoi (jamais d'envoi automatique).
Future<AiDevisResult?> showAiDevisSheet(BuildContext context) {
  final repo = context.read<AppRepository>();

  return showModalBottomSheet<AiDevisResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _AiDevisSheetContent(repo: repo),
  );
}

class _AiDevisSheetContent extends StatefulWidget {
  final AppRepository repo;
  const _AiDevisSheetContent({required this.repo});

  @override
  State<_AiDevisSheetContent> createState() => _AiDevisSheetContentState();
}

class _AiDevisSheetContentState extends State<_AiDevisSheetContent> {
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final draft = await AiDevisService.generate(
        description: _descriptionController.text,
        knownClients: widget.repo.clients,
        knownProducts: widget.repo.products,
      );

      final normalizedClientName = draft.clientName.trim().toLowerCase();
      final existingClient = widget.repo.clients
          .where((c) => c.name.trim().toLowerCase() == normalizedClientName)
          .firstOrNull;
      final client = existingClient ??
          await widget.repo.addClient(
            name: draft.clientName,
            phone: draft.clientPhone ?? '',
          );

      final items = draft.items.map((itemDraft) {
        final normalizedItemName = itemDraft.name.trim().toLowerCase();
        final existingProduct = widget.repo.products
            .where((p) => p.name.trim().toLowerCase() == normalizedItemName)
            .firstOrNull;
        if (existingProduct != null) {
          return DevisItem(
            productId: existingProduct.id,
            productName: existingProduct.name,
            unitPrice: existingProduct.price,
            quantity: itemDraft.quantity,
          );
        }
        return DevisItem(
          productId: 'ia-${_uuid.v4()}',
          productName: itemDraft.name,
          unitPrice: itemDraft.unitPrice,
          quantity: itemDraft.quantity,
        );
      }).toList();

      if (!mounted) return;
      Navigator.of(context).pop(AiDevisResult(client, items));
    } on AiDevisException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue. Réessaie, ou remplis le devis à la main.';
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.orangeDark),
              SizedBox(width: 8),
              Text('Décrire ton besoin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "L'IA remplit le client et les articles à ta place. Tu vérifies tout avant d'envoyer.",
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            autofocus: true,
            maxLines: 4,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'Ex : Devis pour Awa Compaoré, 2 sacs de riz et une livraison',
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_errorMessage!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generate,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_isLoading ? 'Génération...' : 'Générer le devis'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nécessite une connexion Internet. Vérifie toujours les prix avant d\'envoyer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
