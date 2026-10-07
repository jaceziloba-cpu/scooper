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

      // Profil incomplet seulement si absent ou champs obligatoires vides.
      // Un membership null n'est pas bloquant si le profil est déjà complet
      // (ex : tables pas encore migrées, ou RLS temporairement restrictive).
      if (_profile == null || !_profile!.isProfileComplete) {
        isProfileIncomplete = true;
      } else {
        isProfileIncomplete = false;
      }
    } catch (e) {
      debugPrint('[AuthController] Erreur chargement profil: $e');
      // En cas d'erreur réseau/RLS, on ne bloque pas un utilisateur
      // déjà authentifié dont on a pu lire le profil.
      isProfileIncomplete = (_profile == null || !(_profile?.isProfileComplete ?? false));
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
    String? dateOfBirth,
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
    } on PostgrestException catch (error) {
      debugPrint('[AuthController] Erreur base de données: $error');
      errorMessage = _friendlyPostgrestError(error);
    } catch (e) {
      debugPrint('[AuthController] Erreur inattendue: $e');
      errorMessage = _friendlyErrorUnknown(e);
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
    // Erreurs de transport (réseau / CORS / serveur injoignable) remontées
    // par le SDK sans code d'erreur : message clair au lieu du texte brut.
    if (error.code == null && _looksLikeNetworkError(message)) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion internet et que le domaine du site est autorisé (CORS) dans Supabase > Authentication > URL Configuration.';
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

  String _friendlyErrorUnknown(Object error) {
    final detail = error.toString();
    final msg = detail.toLowerCase();
    if (msg.contains('cors') ||
        msg.contains('failed to fetch') ||
        msg.contains('fetch failed') ||
        msg.contains('typeerror') ||
        msg.contains('networkerror') ||
        msg.contains('clientexception') ||
        msg.contains('requestexception') ||
        msg.contains('timeout') ||
        msg.contains('unreachable') ||
        msg.contains('connection refused') ||
        msg.contains('dns')) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion internet et que le domaine du site est autorisé (CORS) dans Supabase > Authentication > URL Configuration.';
    }
    if (msg.contains('platformexception') ||
        msg.contains('localstorage') ||
        msg.contains('indexeddb') ||
        msg.contains('securityerror') ||
        msg.contains('cookie')) {
      return 'Votre navigateur bloque le stockage local (cookies / données de site). Autorisez les cookies et les données de site pour ce domaine puis réessayez.';
    }
    if (msg.contains('unauthorized') ||
        msg.contains('invalid api key') ||
        msg.contains('apikey') ||
        msg.contains('statuscode: 401') ||
        msg.contains('http 401')) {
      return 'Clé API Supabase invalide ou non autorisée. Vérifiez SupabaseConfig (publishableKey).';
    }
    if (msg.contains('redirect_uri') ||
        msg.contains('invalid_state') ||
        msg.contains('bad_oauth') ||
        msg.contains('pkce') ||
        msg.contains('oauth') ||
        msg.contains('callback')) {
      return 'La connexion a échoué. Vérifiez les URLs de redirection autorisées dans Supabase (Authentication > URL Configuration) et dans Google Cloud.';
    }
    if (msg.contains('email') || msg.contains('password')) {
      return 'Email ou mot de passe incorrect.';
    }
    // Dernier recours : on garde un message compréhensible mais on expose le
    // détail technique (tronqué) pour permettre le diagnostic réel.
    final shortDetail = detail.length > 220 ? detail.substring(0, 220) : detail;
    return 'Une erreur est survenue. Veuillez réessayer. ($shortDetail)';
  }

  /// Transforme une erreur PostgreSQL/PostgREST en message clair et adapté à
  /// l'utilisateur, en évitant d'exposer du SQL brut.
  String _friendlyPostgrestError(PostgrestException error) {
    final code = error.code?.toUpperCase() ?? '';
    final raw = '${error.message} ${error.details ?? ''}'.toLowerCase();

    // Colonne ou table introuvable => schéma Supabase désynchronisé
    // (ex : "column profiles.date_of_birth does not exist" - PGRST204).
    if (code == 'PGRST204' || code == 'PGRST205' ||
        raw.contains('does not exist') ||
        raw.contains('relation ') && raw.contains('does not exist')) {
      return 'Le schéma de la base de données ne correspond pas à la version de '
          'l’application. Contactez l’administrateur pour appliquer les dernières '
          'migrations Supabase, puis réessayez.';
    }
    // RLS : action refusée par une politique de sécurité.
    if (code == '42501' || raw.contains('row-level security') ||
        raw.contains('permission denied') ||
        raw.contains('new row violates row-level security')) {
      return 'Vous n’avez pas l’autorisation d’effectuer cette action avec ce '
          'profil. Vérifiez vos informations ou contactez l’administration de '
          'l’établissement.';
    }
    // Contrainte unique (doublon).
    if (code == '23505' || raw.contains('duplicate key')) {
      return 'Un enregistrement avec ces informations existe déjà. Vérifiez les '
          'données saisies ou contactez l’administration.';
    }
    // Clé étrangère invalide (ex : établissement inexistant).
    if (code == '23503' || raw.contains('foreign key')) {
      return 'L’élément sélectionné (établissement, classe…) est introuvable. '
          'Rechargez la page puis réessayez.';
    }
    if (code == 'P0001' || raw.contains('modification du rôle')) {
      return 'Vous ne pouvez pas modifier votre rôle d’utilisateur. '
          'Contactez l’administration de l’établissement.';
    }
    if (code == '23514' || raw.contains('check constraint')) {
      return 'Une valeur saisie n’est pas valide. Vérifiez les champs du formulaire.';
    }
    if (code == '22P02' || raw.contains('invalid input value')) {
      return 'Une valeur saisie n’a pas le bon format. Vérifiez vos champs.';
    }
    if (raw.contains('does not match row')) {
      return 'Cette opération échoue à cause d’une règle de sécurité (RLS). '
          'Contactez l’administrateur.';
    }
    // Message lisible, sans détails SQL brut.
    return 'Une erreur est survenue lors de l’enregistrement de vos données. '
        'Veuillez réessayer. Si le problème persiste, contactez l’administrateur.';
  }

  bool _looksLikeNetworkError(String message) =>
      message.contains('failed to fetch') ||
      message.contains('fetch failed') ||
      message.contains('clientexception') ||
      message.contains('typeerror') ||
      message.contains('cors') ||
      message.contains('network') ||
      message.contains('socketexception') ||
      message.contains('connection') ||
      message.contains('timeout');

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
