import 'package:supabase_flutter/supabase_flutter.dart';

import '../../establishments/domain/school.dart';
import '../../users/domain/school_membership.dart';
import '../../users/domain/user_profile.dart';

abstract interface class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserProfile?> fetchProfile(String userId);
  Future<SchoolMembership?> fetchUserMembership(String userId);
  Future<List<School>> fetchSchools();

  Future<void> signInWithEmail(String email, String password);

  Future<void> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String schoolId,
    String? className,
  });

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
  });

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
  });

  Future<void> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> signOut();

  // School Admin methods
  Future<List<SchoolMembership>> fetchPendingTeacherRequests(String schoolId);
  Future<void> approveTeacherRequest(String membershipId);
  Future<void> rejectTeacherRequest(String membershipId, String? reason);
  Future<List<SchoolMembership>> fetchSchoolMembers(String schoolId);

  // Super Admin methods
  Future<List<School>> fetchAllSchoolsAdmin();
  Future<void> createSchool(School school);
  Future<List<UserProfile>> fetchAllUsersAdmin();
}
