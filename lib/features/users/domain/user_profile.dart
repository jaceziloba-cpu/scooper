enum UserRole { superAdmin, establishmentAdmin, teacher, parent, student }

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.establishmentId,
  });
  final String uid;
  final String email;
  final UserRole role;
  final String? establishmentId;
  Map<String, Object?> toMap() => {
    'uid': uid,
    'email': email,
    'role': role.name,
    'establishmentId': establishmentId,
  };
  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile(
    uid: map['uid']! as String,
    email: map['email']! as String,
    role: UserRole.values.byName(map['role']! as String),
    establishmentId: map['establishmentId'] as String?,
  );
}
