import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../establishments/domain/school.dart';
import '../../users/domain/school_membership.dart';
import '../../users/domain/user_profile.dart';
import '../domain/auth_repository.dart';

enum PublicTab { home, presentation, features, schools, login, register, forgotPassword }

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    final repo = _repository;
    if (repo != null) {
      _subscription = repo.authStateChanges.listen((user) {
        _handleUserChanged(user);
      });
      final current = repo.currentUser;
      if (current != null) {
        _handleUserChanged(current);
      } else {
        isAuthLoading = false;
        notifyListeners();
      }
    } else {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  final AuthRepository? _repository;
  StreamSubscription<User?>? _subscription;

  User? _user;
  UserProfile? _profile;
  SchoolMembership? _membership;
  List<School> _schools = [];

  bool isAuthLoading = true;
  bool isBusy = false;
  bool isProfileIncomplete = false;
  String? errorMessage;
  String? successMessage;

  PublicTab _publicTab = PublicTab.home;
  PublicTab get publicTab => _publicTab;

  User? get user => _user;
  UserProfile? get profile => _profile;
  SchoolMembership? get membership => _membership;
  List<School> get schools => _schools;

  void setPublicTab(PublicTab tab) {
    _publicTab = tab;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  Future<void> loadSchools() async {
    final repo = _repository;
    if (repo == null) return;
    try {
      _schools = await repo.fetchSchools();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> reloadUserData() async {
    if (_user != null) {
      await _handleUserChanged(_user);
    }
  }

  Future<void> _handleUserChanged(User? user) async {
    _user = user;
    if (user == null) {
      _profile = null;
      _membership = null;
      isProfileIncomplete = false;
      isAuthLoading = false;
      notifyListeners();
      return;
    }

    isAuthLoading = true;
    notifyListeners();

    final repo = _repository;
    if (repo == null) {
      isAuthLoading = false;
      notifyListeners();
      return;
    }

    try {
      await loadSchools();
      _profile = await repo.fetchProfile(user.id);
      _membership = await repo.fetchUserMembership(user.id);

      if (_profile == null || !_profile!.isProfileComplete || _membership == null) {
        isProfileIncomplete = true;
      } else {
        isProfileIncomplete = false;
      }
    } catch (_) {
      isProfileIncomplete = true;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.signInWithEmail(email, password);
  });

  Future<void> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String schoolId,
    String? className,
  }) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.signUpStudent(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      schoolId: schoolId,
      className: className,
    );
    successMessage = 'Votre compte élève a été créé avec succès !';
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
  }) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.signUpTeacher(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      phone: phone,
      schoolId: schoolId,
      subject: subject,
      functionTitle: functionTitle,
      professionalInfo: professionalInfo,
      justificationUrl: justificationUrl,
    );
    successMessage =
        'Votre demande a été transmise à l’administration de votre établissement. Vous pourrez accéder à votre espace après validation.';
  });

  Future<void> completeProfileAndMembership({
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
  }) => _run(() async {
    final repo = _repository;
    final currentUser = _user;
    if (currentUser == null || repo == null) throw const AuthException('Non connecté');
    await repo.completeProfileAndMembership(
      userId: currentUser.id,
      email: currentUser.email ?? '',
      role: role,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      phone: phone,
      schoolId: schoolId,
      className: className,
      subject: subject,
      functionTitle: functionTitle,
      justificationUrl: justificationUrl,
    );
    await reloadUserData();
  });

  Future<void> signInWithGoogle() => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.signInWithGoogle();
  });

  Future<void> resetPassword(String email) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.sendPasswordResetEmail(email);
    successMessage = 'Un e-mail de réinitialisation a été envoyé à $email.';
  });

  Future<void> resendVerification() => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.sendEmailVerification();
  });

  Future<void> signOut() => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.signOut();
    _publicTab = PublicTab.home;
  });

  Future<List<SchoolMembership>> getPendingTeacherRequests(String schoolId) async {
    final repo = _repository;
    if (repo == null) return [];
    return repo.fetchPendingTeacherRequests(schoolId);
  }

  Future<void> approveTeacherRequest(String membershipId) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.approveTeacherRequest(membershipId);
    successMessage = 'Enseignant validé avec succès.';
  });

  Future<void> rejectTeacherRequest(String membershipId, String? reason) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.rejectTeacherRequest(membershipId, reason);
    successMessage = 'Demande de l’enseignant refusée.';
  });

  Future<List<SchoolMembership>> getSchoolMembers(String schoolId) async {
    final repo = _repository;
    if (repo == null) return [];
    return repo.fetchSchoolMembers(schoolId);
  }

  Future<List<School>> getAllSchoolsAdmin() async {
    final repo = _repository;
    if (repo == null) return [];
    return repo.fetchAllSchoolsAdmin();
  }

  Future<void> createSchoolAdmin(School school) => _run(() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.createSchool(school);
    await loadSchools();
    successMessage = 'Établissement créé avec succès.';
  });

  Future<List<UserProfile>> getAllUsersAdmin() async {
    final repo = _repository;
    if (repo == null) return [];
    return repo.fetchAllUsersAdmin();
  }

  Future<void> _run(Future<void> Function() operation) async {
    isBusy = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      await operation();
    } on AuthException catch (error) {
      errorMessage = _friendlyError(error);
    } catch (e) {
      errorMessage = 'Une erreur est survenue (${e.toString()}). Réessayez.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  String _friendlyError(AuthException error) {
    final message = error.message.toLowerCase();
    if (error.code == 'validation_failed' || message.contains('provider')) {
      return 'La connexion Google n’est pas encore activée. Activez Google dans Supabase > Authentication > Providers.';
    }
    return switch (error.code) {
      'invalid_credentials' => 'Email ou mot de passe incorrect.',
      'email_exists' => 'Cette adresse email est déjà utilisée.',
      'weak_password' => 'Le mot de passe doit contenir au moins 6 caractères.',
      'invalid_email' => 'Adresse email invalide.',
      'user_not_found' => 'Aucun compte ne correspond à cette adresse.',
      'over_email_send_rate_limit' =>
        'Trop de demandes. Réessayez dans quelques minutes.',
      _ => error.message,
    };
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
