/// Une ligne d'article dans un devis/facture : nom + prix figés au moment de
/// l'ajout (si le prix du produit change plus tard, les anciens devis ne
/// bougent pas).
class DevisItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  DevisItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;

  DevisItem copyWith({int? quantity}) => DevisItem(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory DevisItem.fromMap(Map<String, dynamic> map) => DevisItem(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        unitPrice: (map['unitPrice'] as num).toDouble(),
        quantity: (map['quantity'] as num).toInt(),
      );
}
