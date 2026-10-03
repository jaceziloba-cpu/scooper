import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class TeacherPendingScreen extends StatelessWidget {
  const TeacherPendingScreen({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final membership = controller.membership;
    final profile = controller.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Validation Enseignant en attente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: controller.signOut,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 64 : 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFFFE0B2)),
              ),
              color: const Color(0xFFFFF8E1),
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0C2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: Color(0xFFB78103),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'En attente de validation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Votre demande a été transmise à l’administration de votre établissement${membership?.schoolName != null ? ' (${membership!.schoolName})' : ''}.\nVous pourrez acceder à votre espace enseignant après validation.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6D4C41),
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Enseignant',
                            value: profile?.fullName ?? profile?.email ?? '-',
                          ),
                          const Divider(height: 16),
                          _InfoRow(
                            label: 'Matière',
                            value: membership?.subject ?? 'Non spécifié',
                          ),
                          const Divider(height: 16),
                          _InfoRow(
                            label: 'Fonction',
                            value: membership?.functionTitle ?? 'Enseignant',
                          ),
                          const Divider(height: 16),
                          _InfoRow(
                            label: 'Statut',
                            value: '⏳ En attente de validation',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: controller.reloadUserData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Vérifier mon statut'),
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          onPressed: controller.signOut,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4037),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Se déconnecter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8D6E63),
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
