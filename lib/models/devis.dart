import 'devis_item.dart';

/// Les 3 seuls statuts visibles par l'utilisateur (représentés par des
/// couleurs/pictogrammes dans l'interface, jamais par du texte technique).
enum DevisStatus { enAttente, accepte, refuse }

class Devis {
  final String id;
  final String clientId;
  final String clientName;
  final List<DevisItem> items;
  final DateTime createdAt;
  final DevisStatus status;

  /// false = devis, true = facture (un devis accepté devient une facture).
  final bool isInvoice;

  /// Renseigné quand la facture est marquée payée.
  final DateTime? paidAt;

  Devis({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.createdAt,
    this.status = DevisStatus.enAttente,
    this.isInvoice = false,
    this.paidAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  bool get isPaid => paidAt != null;

  Devis copyWith({
    List<DevisItem>? items,
    DevisStatus? status,
    bool? isInvoice,
    DateTime? paidAt,
  }) {
    return Devis(
      id: id,
      clientId: clientId,
      clientName: clientName,
      items: items ?? this.items,
      createdAt: createdAt,
      status: status ?? this.status,
      isInvoice: isInvoice ?? this.isInvoice,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'items': items.map((i) => i.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'isInvoice': isInvoice,
        'paidAt': paidAt?.toIso8601String(),
      };

  factory Devis.fromMap(Map<String, dynamic> map) => Devis(
        id: map['id'] as String,
        clientId: map['clientId'] as String,
        clientName: map['clientName'] as String,
        items: (map['items'] as List)
            .map((i) => DevisItem.fromMap(Map<String, dynamic>.from(i)))
            .toList(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        status: DevisStatus.values.byName(map['status'] as String),
        isInvoice: map['isInvoice'] as bool? ?? false,
        paidAt: map['paidAt'] == null
            ? null
            : DateTime.parse(map['paidAt'] as String),
      );
}
