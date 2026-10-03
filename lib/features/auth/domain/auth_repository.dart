import 'package:supabase_flutter/supabase_flutter.dart';

import '../../users/domain/role_request.dart';

abstract interface class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<RoleRequest?> getRoleRequest();
  Future<void> submitRoleRequest(RequestedRole role);
}
