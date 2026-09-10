import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_repository.dart';
import '../models/client.dart';

/// Bottom sheet réutilisable "Nouveau client" (nom + téléphone seulement).
/// Retourne le client créé, ou null si annulé.
Future<Client?> showNewClientSheet(BuildContext context) {
  final repo = context.read<AppRepository>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  return showModalBottomSheet<Client>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nouveau client',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Nom du client'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Numéro de téléphone'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final client = await repo.addClient(
                  name: name,
                  phone: phoneController.text.trim(),
                );
                if (sheetContext.mounted) Navigator.of(sheetContext).pop(client);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
    },
  );
}
