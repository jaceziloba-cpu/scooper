enum RequestedRole {
  admin('admin', 'Administrateur de l’école', 'Gestion de l’établissement'),
  teacher('teacher', 'Enseignant', 'Cours, classes et emploi du temps'),
  parent('parent', 'Parent', 'Suivi de la scolarité'),
  student('student', 'Élève', 'Emploi du temps et informations');

  const RequestedRole(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  static RequestedRole? fromValue(String? value) =>
      RequestedRole.values.where((role) => role.value == value).firstOrNull;
}

class RoleRequest {
  const RoleRequest({
    required this.id,
    required this.requestedRole,
    required this.status,
    required this.createdAt,
    this.reviewNote,
  });

  factory RoleRequest.fromMap(Map<String, dynamic> map) => RoleRequest(
    id: map['id'] as String,
    requestedRole:
        RequestedRole.fromValue(map['requested_role'] as String?) ??
        RequestedRole.student,
    status: map['status'] as String? ?? 'pending',
    createdAt: DateTime.parse(map['created_at'] as String),
    reviewNote: map['review_note'] as String?,
  );

  final String id;
  final RequestedRole requestedRole;
  final String status;
  final DateTime createdAt;
  final String? reviewNote;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}
