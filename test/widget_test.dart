import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scooper/app.dart';
import 'package:scooper/features/auth/presentation/auth_controller.dart';

void main() {
  testWidgets('ouvre la navigation publique sans rediriger automatiquement vers login', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = AuthController(null);
    await tester.pumpWidget(
      ScooperApp(authController: controller, supabaseReady: true),
    );
    await tester.pumpAndSettle();

    // Verify public navigation elements
    expect(find.text('Pilotez votre établissement scolaire en toute simplicité.'), findsOneWidget);
    expect(find.text('Rejoindre SCOOPER'), findsWidgets);

    controller.dispose();
  });

  testWidgets('affiche l’écran de connexion lors de la sélection du tab login', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = AuthController(null);
    await tester.pumpWidget(
      ScooperApp(authController: controller, supabaseReady: false),
    );

    controller.setPublicTab(PublicTab.login);
    await tester.pumpAndSettle();

    expect(find.text('Se connecter'), findsWidgets);
    expect(find.text('Continuer avec Google'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('l’écran de choix de rôle affiche uniquement Élève et Enseignant', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = AuthController(null);
    await tester.pumpWidget(
      ScooperApp(authController: controller, supabaseReady: true),
    );

    controller.setPublicTab(PublicTab.register);
    await tester.pumpAndSettle();

    expect(find.text('Élève'), findsWidgets);
    expect(find.text('Enseignant'), findsWidgets);
    expect(find.text('Super Administrateur'), findsNothing);

    controller.dispose();
  });
}
