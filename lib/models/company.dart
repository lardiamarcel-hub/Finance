class Company {
  final String name;
  final String phone;
  final String city;
  final String? logoPath;

  const Company({
    this.name = '',
    this.phone = '',
    this.city = '',
    this.logoPath,
  });

  bool get isConfigured => name.trim().isNotEmpty;

  Company copyWith({
    String? name,
    String? phone,
    String? city,
    String? logoPath,
  }) {
    return Company(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'city': city,
        'logoPath': logoPath,
      };

  factory Company.fromMap(Map<String, dynamic> map) => Company(
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        city: map['city'] as String? ?? '',
        logoPath: map['logoPath'] as String?,
      );
}
