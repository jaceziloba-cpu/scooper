enum MembershipType {
  student('student', 'Élève'),
  teacher('teacher', 'Enseignant'),
  schoolAdmin('school_admin', 'Administrateur');

  const MembershipType(this.value, this.label);
  final String value;
  final String label;

  static MembershipType fromValue(String? value) =>
      MembershipType.values.firstWhere(
        (m) => m.value == value,
        orElse: () => MembershipType.student,
      );
}

enum MembershipStatus {
  pending('pending', 'En attente'),
  approved('approved', 'Approuvé'),
  rejected('rejected', 'Refusé'),
  suspended('suspended', 'Suspendu');

  const MembershipStatus(this.value, this.label);
  final String value;
  final String label;

  static MembershipStatus fromValue(String? value) =>
      MembershipStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => MembershipStatus.pending,
      );
}

class SchoolMembership {
  const SchoolMembership({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.membershipType,
    required this.status,
    this.schoolName,
    this.userFullName,
    this.userEmail,
    this.className,
    this.subject,
    this.functionTitle,
    this.justificationUrl,
    this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  final String id;
  final String userId;
  final String schoolId;
  final MembershipType membershipType;
  final MembershipStatus status;
  final String? schoolName;
  final String? userFullName;
  final String? userEmail;
  final String? className;
  final String? subject;
  final String? functionTitle;
  final String? justificationUrl;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  bool get isApproved => status == MembershipStatus.approved;
  bool get isPending => status == MembershipStatus.pending;
  bool get isRejected => status == MembershipStatus.rejected;

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'school_id': schoolId,
    'membership_type': membershipType.value,
    'status': status.value,
    'class_name': className,
    'subject': subject,
    'function_title': functionTitle,
    'justification_url': justificationUrl,
    'rejection_reason': rejectionReason,
  };

  factory SchoolMembership.fromMap(Map<String, dynamic> map) =>
      SchoolMembership(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        schoolId: map['school_id'] as String,
        membershipType: MembershipType.fromValue(
          map['membership_type'] as String?,
        ),
        status: MembershipStatus.fromValue(map['status'] as String?),
        schoolName: map['schools']?['name'] as String? ?? map['school_name'] as String?,
        userFullName: map['profiles'] != null
            ? '${map['profiles']['first_name'] ?? ''} ${map['profiles']['last_name'] ?? ''}'.trim()
            : map['user_full_name'] as String?,
        userEmail: map['profiles']?['email'] as String? ?? map['user_email'] as String?,
        className: map['class_name'] as String?,
        subject: map['subject'] as String?,
        functionTitle: map['function_title'] as String?,
        justificationUrl: map['justification_url'] as String?,
        requestedAt: map['requested_at'] != null
            ? DateTime.tryParse(map['requested_at'] as String)
            : (map['created_at'] != null
                ? DateTime.tryParse(map['created_at'] as String)
                : null),
        reviewedAt: map['reviewed_at'] != null
            ? DateTime.tryParse(map['reviewed_at'] as String)
            : null,
        reviewedBy: map['reviewed_by'] as String?,
        rejectionReason: map['rejection_reason'] as String?,
      );
}
