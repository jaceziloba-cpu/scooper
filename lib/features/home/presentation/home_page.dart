import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.controller, super.key});
  final AuthController controller;
  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    final displayName =
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scooper'),
        actions: [
          IconButton(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour${displayName == null ? '' : ' $displayName'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              user.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Card(
              child: ListTile(
                leading: Icon(Icons.apartment),
                title: Text('Votre établissement'),
                subtitle: Text(
                  'La gestion multi-tenant sera activée après configuration de votre établissement.',
                ),
              ),
            ),
            if (user.emailConfirmedAt == null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mark_email_unread_outlined),
                  title: const Text('Vérifiez votre email'),
                  subtitle: const Text(
                    'Un email de vérification a été envoyé à votre adresse.',
                  ),
                  trailing: TextButton(
                    onPressed: controller.resendVerification,
                    child: const Text('Renvoyer'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
