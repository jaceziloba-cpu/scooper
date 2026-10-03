class School {
  const School({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.country = 'France',
    this.address,
    this.email,
    this.phone,
    this.logoUrl,
    this.status = 'active',
    this.requireJustification = false,
  });

  final String id;
  final String name;
  final String? code;
  final String? city;
  final String country;
  final String? address;
  final String? email;
  final String? phone;
  final String? logoUrl;
  final String status;
  final bool requireJustification;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'city': city,
    'country': country,
    'address': address,
    'email': email,
    'phone': phone,
    'logo_url': logoUrl,
    'status': status,
    'require_justification': requireJustification,
  };

  factory School.fromMap(Map<String, dynamic> map) => School(
    id: map['id'] as String,
    name: map['name'] as String? ?? 'Établissement Sans Nom',
    code: map['code'] as String?,
    city: map['city'] as String?,
    country: map['country'] as String? ?? 'France',
    address: map['address'] as String?,
    email: map['email'] as String?,
    phone: map['phone'] as String?,
    logoUrl: map['logo_url'] as String?,
    status: map['status'] as String? ?? 'active',
    requireJustification: map['require_justification'] as bool? ?? false,
  );
}
