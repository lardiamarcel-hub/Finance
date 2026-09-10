import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ai_config.dart';
import '../models/client.dart';
import '../models/product.dart';

class AiDevisException implements Exception {
  final String message;
  AiDevisException(this.message);

  @override
  String toString() => message;
}

class AiDevisItemDraft {
  final String name;
  final int quantity;
  final double unitPrice;

  AiDevisItemDraft({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}

class AiDevisDraft {
  final String clientName;
  final String? clientPhone;
  final List<AiDevisItemDraft> items;

  AiDevisDraft({
    required this.clientName,
    required this.clientPhone,
    required this.items,
  });
}

/// Transforme une phrase en français ("Devis pour Awa, 2 sacs de riz et une
/// livraison") en client + articles structurés, via l'API gratuite Google
/// Gemini. Ne fait jamais rien d'autre que proposer un brouillon : c'est
/// toujours à l'utilisateur de vérifier et d'envoyer.
class AiDevisService {
  static bool get isAvailable => geminiApiKey.isNotEmpty;

  static Future<AiDevisDraft> generate({
    required String description,
    required List<Client> knownClients,
    required List<Product> knownProducts,
    String model = defaultAiModel,
  }) async {
    if (!isAvailable) {
      throw AiDevisException("L'assistant IA n'est pas disponible sur cette version de l'app.");
    }
    if (description.trim().isEmpty) {
      throw AiDevisException('Décris le devis avant de générer.');
    }

    final prompt = _buildPrompt(
      description: description,
      knownClients: knownClients,
      knownProducts: knownProducts,
    );

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey',
    );

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': {
              'type': 'OBJECT',
              'properties': {
                'clientName': {'type': 'STRING'},
                'clientPhone': {'type': 'STRING'},
                'items': {
                  'type': 'ARRAY',
                  'items': {
                    'type': 'OBJECT',
                    'properties': {
                      'name': {'type': 'STRING'},
                      'quantity': {'type': 'INTEGER'},
                      'unitPrice': {'type': 'NUMBER'},
                    },
                    'required': ['name', 'quantity', 'unitPrice'],
                  },
                },
              },
              'required': ['clientName', 'items'],
            },
          },
        }),
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiDevisException('Pas de connexion Internet. Réessaie plus tard, ou remplis le devis à la main.');
    }

    if (response.statusCode != 200) {
      throw AiDevisException('Le service IA est indisponible pour le moment (code ${response.statusCode}).');
    }

    late Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AiDevisException("Réponse inattendue de l'IA. Réessaie, ou remplis le devis à la main.");
    }

    final candidates = body['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw AiDevisException("L'IA n'a pas compris ce besoin. Reformule ou remplis le devis à la main.");
    }

    final parts = (candidates.first as Map<String, dynamic>)['content']?['parts'] as List?;
    final text = parts?.isNotEmpty == true ? parts!.first['text'] as String? : null;
    if (text == null) {
      throw AiDevisException("L'IA n'a rien renvoyé. Réessaie, ou remplis le devis à la main.");
    }

    Map<String, dynamic> draft;
    try {
      draft = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw AiDevisException("Réponse de l'IA illisible. Réessaie, ou remplis le devis à la main.");
    }

    final clientName = (draft['clientName'] as String?)?.trim() ?? '';
    if (clientName.isEmpty) {
      throw AiDevisException('Indique au moins le nom du client dans ta description.');
    }

    final rawItems = draft['items'] as List? ?? [];
    final items = rawItems
        .map((raw) {
          final map = raw as Map<String, dynamic>;
          final name = (map['name'] as String?)?.trim() ?? '';
          if (name.isEmpty) return null;
          final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
          final unitPrice = (map['unitPrice'] as num?)?.toDouble() ?? 0;
          return AiDevisItemDraft(
            name: name,
            quantity: quantity < 1 ? 1 : quantity,
            unitPrice: unitPrice < 0 ? 0 : unitPrice,
          );
        })
        .whereType<AiDevisItemDraft>()
        .toList();

    if (items.isEmpty) {
      throw AiDevisException('Décris au moins un article ou service dans ta description.');
    }

    return AiDevisDraft(
      clientName: clientName,
      clientPhone: (draft['clientPhone'] as String?)?.trim(),
      items: items,
    );
  }

  static String _buildPrompt({
    required String description,
    required List<Client> knownClients,
    required List<Product> knownProducts,
  }) {
    final clientsList = knownClients.map((c) => c.name).join(', ');
    final productsList = knownProducts.map((p) => '${p.name} (${p.price.round()} FCFA)').join(', ');

    return '''
Tu aides un petit commerçant au Burkina Faso à préparer un devis à partir d'une description en français, parfois familière ou abrégée.

Clients déjà connus (réutilise le nom EXACT si l'un d'eux correspond) : ${clientsList.isEmpty ? 'aucun' : clientsList}
Produits/services déjà connus avec leur prix habituel en FCFA (réutilise ce prix si l'article correspond) : ${productsList.isEmpty ? 'aucun' : productsList}

Description du besoin :
"""
$description
"""

Extrais un client et une liste d'articles/services avec quantité et prix unitaire en FCFA.
Règles :
- Si un article correspond à un produit connu, utilise son prix exact.
- Sinon, propose un prix réaliste pour le Burkina Faso en FCFA (jamais 0, jamais vide).
- Si aucune quantité n'est précisée pour un article, utilise 1.
- Si aucun numéro de téléphone n'est donné pour le client, laisse clientPhone vide.
Réponds uniquement avec les données demandées, sans texte autour.
''';
  }
}
