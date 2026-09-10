class Client {
  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  Client copyWith({String? name, String? phone}) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  /// Première lettre du nom, utilisée comme avatar quand il n'y a pas de photo.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Client.fromMap(Map<String, dynamic> map) => Client(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
