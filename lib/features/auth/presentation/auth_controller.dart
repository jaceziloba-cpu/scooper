import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository?.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
  final AuthRepository? _repository;
  StreamSubscription<User?>? _subscription;
  User? _user;
  bool isBusy = false;
  String? errorMessage;
  User? get user => _user;
  Future<void> signIn(String email, String password) => _run(() async {
    await _repository!.signInWithEmail(email, password);
  });
  Future<void> signUp(String email, String password) => _run(() async {
    await _repository!.signUpWithEmail(email, password);
    await _repository.sendEmailVerification();
  });
  Future<void> signInWithGoogle() => _run(() async {
    await _repository!.signInWithGoogle();
  });
  Future<void> resetPassword(String email) =>
      _run(() => _repository!.sendPasswordResetEmail(email));
  Future<void> resendVerification() => _run(_repository!.sendEmailVerification);
  Future<void> signOut() => _run(_repository!.signOut);
  Future<void> _run(Future<void> Function() operation) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await operation();
    } on AuthException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Une erreur est survenue. Réessayez.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
