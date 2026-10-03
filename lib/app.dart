import 'package:flutter/material.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

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
    title: 'Scooper',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D6D)),
      useMaterial3: true,
    ),
    home: AnimatedBuilder(
      animation: authController,
      builder: (context, _) => authController.user == null
          ? LoginPage(controller: authController, supabaseReady: supabaseReady)
          : HomePage(controller: authController),
    ),
  );
}
