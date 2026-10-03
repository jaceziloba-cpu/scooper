enum ScooperRole {
  student('student', 'Élève'),
  teacher('teacher', 'Enseignant'),
  schoolAdmin('school_admin', 'Administrateur d’établissement'),
  superAdmin('super_admin', 'Super Administrateur');

  const ScooperRole(this.value, this.label);
  final String value;
  final String label;

  static ScooperRole fromValue(String? value) =>
      ScooperRole.values.firstWhere(
        (r) => r.value == value,
        orElse: () => ScooperRole.student,
      );
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phone,
    this.role = ScooperRole.student,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? phone;
  final ScooperRole role;
  final String? avatarUrl;
  final DateTime? createdAt;

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) return email;
    return '$first $last'.trim();
  }

  bool get isProfileComplete =>
      (firstName != null && firstName!.trim().isNotEmpty) ||
      (lastName != null && lastName!.trim().isNotEmpty);

  Map<String, Object?> toMap() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'date_of_birth': dateOfBirth,
    'phone': phone,
    'role': role.value,
    'avatar_url': avatarUrl,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as String,
    email: map['email'] as String? ?? '',
    firstName: map['first_name'] as String?,
    lastName: map['last_name'] as String?,
    dateOfBirth: map['date_of_birth'] as String?,
    phone: map['phone'] as String?,
    role: ScooperRole.fromValue(map['role'] as String?),
    avatarUrl: map['avatar_url'] as String?,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'] as String)
        : null,
  );
}
