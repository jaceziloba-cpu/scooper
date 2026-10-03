import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../establishments/domain/school.dart';
import '../../users/domain/school_membership.dart';
import '../../users/domain/user_profile.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static final List<School> _fallbackSchools = const [
    School(
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Lycée Victor Hugo',
      code: 'LVH-75003',
      city: 'Paris',
      address: '27 Rue de Sévigné',
    ),
    School(
      id: '00000000-0000-0000-0000-000000000002',
      name: 'Collège Jules Ferry',
      code: 'CJF-69002',
      city: 'Lyon',
      address: '14 Rue de la Charité',
    ),
    School(
      id: '00000000-0000-0000-0000-000000000003',
      name: 'Lycée Saint-Exupéry',
      code: 'LSE-31000',
      city: 'Toulouse',
      address: '8 Boulevard de Strasbourg',
    ),
  ];

  @override
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        final user = currentUser;
        if (user != null && user.id == userId) {
          final meta = user.userMetadata ?? {};
          final first = meta['first_name'] as String? ??
              meta['given_name'] as String? ??
              '';
          final last = meta['last_name'] as String? ??
              meta['family_name'] as String? ??
              '';
          final roleStr = meta['role'] as String? ?? 'student';
          return UserProfile(
            id: userId,
            email: user.email ?? '',
            firstName: first.isNotEmpty ? first : null,
            lastName: last.isNotEmpty ? last : null,
            role: ScooperRole.fromValue(roleStr),
          );
        }
        return null;
      }
      return UserProfile.fromMap(data);
    } catch (_) {
      final user = currentUser;
      if (user != null && user.id == userId) {
        return UserProfile(
          id: userId,
          email: user.email ?? '',
          role: ScooperRole.student,
        );
      }
      return null;
    }
  }

  @override
  Future<SchoolMembership?> fetchUserMembership(String userId) async {
    try {
      final data = await _client
          .from('school_memberships')
          .select('*, schools(name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return SchoolMembership.fromMap(data);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<School>> fetchSchools() async {
    try {
      final data = await _client.from('schools').select().order('name');
      final list = (data as List).map((m) => School.fromMap(m)).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return _fallbackSchools;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String schoolId,
    String? className,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'role': 'student',
      },
    );

    final user = response.user;
    if (user != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': email.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'date_of_birth': dateOfBirth,
        'role': 'student',
      });

      await _client.from('school_memberships').insert({
        'user_id': user.id,
        'school_id': schoolId,
        'membership_type': 'student',
        'status': 'approved',
        'class_name': className?.trim(),
      });
    }
  }

  @override
  Future<void> signUpTeacher({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    String? phone,
    required String schoolId,
    required String subject,
    required String functionTitle,
    String? professionalInfo,
    String? justificationUrl,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'role': 'teacher',
      },
    );

    final user = response.user;
    if (user != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': email.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'date_of_birth': dateOfBirth,
        'phone': phone?.trim(),
        'role': 'teacher',
      });

      await _client.from('school_memberships').insert({
        'user_id': user.id,
        'school_id': schoolId,
        'membership_type': 'teacher',
        'status': 'pending',
        'subject': subject.trim(),
        'function_title': functionTitle.trim(),
        'justification_url': justificationUrl,
      });
    }
  }

  @override
  Future<void> completeProfileAndMembership({
    required String userId,
    required String email,
    required String role,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    String? phone,
    required String schoolId,
    String? className,
    String? subject,
    String? functionTitle,
    String? justificationUrl,
  }) async {
    final cleanRole = (role == 'teacher') ? 'teacher' : 'student';
    final initialStatus = (cleanRole == 'student') ? 'approved' : 'pending';

    await _client.from('profiles').upsert({
      'id': userId,
      'email': email.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'date_of_birth': dateOfBirth,
      'phone': phone?.trim(),
      'role': cleanRole,
    });

    await _client.from('school_memberships').upsert({
      'user_id': userId,
      'school_id': schoolId,
      'membership_type': cleanRole,
      'status': initialStatus,
      'class_name': className?.trim(),
      'subject': subject?.trim(),
      'function_title': functionTitle?.trim(),
      'justification_url': justificationUrl,
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : SupabaseConfig.oauthRedirectUri,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());

  @override
  Future<void> sendEmailVerification() async {
    final email = currentUser?.email;
    if (email != null && currentUser?.emailConfirmedAt == null) {
      await _client.auth.resend(type: OtpType.signup, email: email);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<List<SchoolMembership>> fetchPendingTeacherRequests(String schoolId) async {
    try {
      final data = await _client
          .from('school_memberships')
          .select('*, profiles(first_name, last_name, email), schools(name)')
          .eq('school_id', schoolId)
          .eq('membership_type', 'teacher')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (data as List).map((m) => SchoolMembership.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> approveTeacherRequest(String membershipId) async {
    await _client.from('school_memberships').update({
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
      'reviewed_by': currentUser?.id,
    }).eq('id', membershipId);
  }

  @override
  Future<void> rejectTeacherRequest(String membershipId, String? reason) async {
    await _client.from('school_memberships').update({
      'status': 'rejected',
      'rejection_reason': reason?.trim(),
      'reviewed_at': DateTime.now().toIso8601String(),
      'reviewed_by': currentUser?.id,
    }).eq('id', membershipId);
  }

  @override
  Future<List<SchoolMembership>> fetchSchoolMembers(String schoolId) async {
    try {
      final data = await _client
          .from('school_memberships')
          .select('*, profiles(first_name, last_name, email), schools(name)')
          .eq('school_id', schoolId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      return (data as List).map((m) => SchoolMembership.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<School>> fetchAllSchoolsAdmin() => fetchSchools();

  @override
  Future<void> createSchool(School school) async {
    await _client.from('schools').insert(school.toMap()..remove('id'));
  }

  @override
  Future<List<UserProfile>> fetchAllUsersAdmin() async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((m) => UserProfile.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }
}
