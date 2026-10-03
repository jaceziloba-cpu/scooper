import 'package:flutter/material.dart';

import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/complete_profile_page.dart';
import 'features/dashboards/presentation/auth_loading_screen.dart';
import 'features/dashboards/presentation/school_admin_dashboard.dart';
import 'features/dashboards/presentation/student_dashboard.dart';
import 'features/dashboards/presentation/super_admin_dashboard.dart';
import 'features/dashboards/presentation/teacher_dashboard.dart';
import 'features/dashboards/presentation/teacher_pending_screen.dart';
import 'features/public/presentation/public_navigation_shell.dart';
import 'features/users/domain/user_profile.dart';

class ScooperApp extends StatelessWidget {
  const ScooperApp({
    required this.authController,
    required this.supabaseReady,
    super.key,
  });

  final AuthController authController;
  final bool supabaseReady;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SCOOPER - SaaS Éducatif',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF196B5B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      fontFamily: 'Arial',
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE7E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE7E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF196B5B), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    home: AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        if (authController.isAuthLoading) {
          return const AuthLoadingScreen();
        }

        final user = authController.user;
        if (user == null) {
          return PublicNavigationShell(
            controller: authController,
            supabaseReady: supabaseReady,
          );
        }

        if (authController.isProfileIncomplete) {
          return CompleteProfilePage(controller: authController);
        }

        final role = authController.profile?.role ?? ScooperRole.student;
        final membership = authController.membership;

        return switch (role) {
          ScooperRole.superAdmin => SuperAdminDashboard(controller: authController),
          ScooperRole.schoolAdmin => SchoolAdminDashboard(controller: authController),
          ScooperRole.teacher => membership?.isApproved == true
              ? TeacherDashboard(controller: authController)
              : TeacherPendingScreen(controller: authController),
          ScooperRole.student => StudentDashboard(controller: authController),
        };
      },
    ),
  );
}
