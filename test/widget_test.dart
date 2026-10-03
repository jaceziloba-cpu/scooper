import 'package:flutter_test/flutter_test.dart';
import 'package:scooper/app.dart';
import 'package:scooper/features/auth/presentation/auth_controller.dart';

void main() {
  testWidgets('affiche l’écran de connexion Supabase', (tester) async {
    final controller = AuthController(null);
    await tester.pumpWidget(
      ScooperApp(authController: controller, supabaseReady: false),
    );
    expect(find.text('Bon retour 👋'), findsOneWidget);
    expect(
      find.textContaining('service est temporairement indisponible'),
      findsOneWidget,
    );
    controller.dispose();
  });
}
