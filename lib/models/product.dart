class Product {
  final String id;
  final String name;
  final double price;
  final String? photoPath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.photoPath,
  });

  Product copyWith({String? name, double? price, String? photoPath}) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'photoPath': photoPath,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        photoPath: map['photoPath'] as String?,
      );
}
