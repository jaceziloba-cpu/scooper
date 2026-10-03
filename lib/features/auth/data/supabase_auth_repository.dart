import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../users/domain/role_request.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(email: email.trim(), password: password);
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
    final email = _client.auth.currentUser?.email;
    if (email != null && _client.auth.currentUser?.emailConfirmedAt == null) {
      await _client.auth.resend(type: OtpType.signup, email: email);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<RoleRequest?> getRoleRequest() async {
    final result = await _client
        .from('role_requests')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return result == null ? null : RoleRequest.fromMap(result);
  }

  @override
  Future<void> submitRoleRequest(RequestedRole role) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Utilisateur non connecté.');
    await _client.from('role_requests').insert({
      'user_id': user.id,
      'requested_role': role.value,
    });
  }
}
