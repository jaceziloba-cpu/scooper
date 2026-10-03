import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class PublicFeaturesPage extends StatelessWidget {
  const PublicFeaturesPage({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 80 : 24,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Toutes les fonctionnalités SCOOPER',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Une suite d’outils complète pour fluidifier le quotidien scolaire.',
                style: TextStyle(fontSize: 18, color: Color(0xFF65736F)),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: desktop ? 3 : 1,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: desktop ? 1.3 : 1.8,
                children: const [
                  _FeatureCard(
                    icon: Icons.vpn_key_rounded,
                    title: 'Authentification Multi-Méthodes',
                    description: 'Connexion sécurisée par email/mot de passe ou via Google OAuth en un clic.',
                  ),
                  _FeatureCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Workflow de Validation',
                    description: 'Système d’approbation des enseignants par l’administration de l’école.',
                  ),
                  _FeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Emplois du Temps',
                    description: 'Consultation centralisée des cours et horaires par classe et matière.',
                  ),
                  _FeatureCard(
                    icon: Icons.school_rounded,
                    title: 'Rattachement Établissement',
                    description: 'Association claire des élèves et enseignants à leur établissement.',
                  ),
                  _FeatureCard(
                    icon: Icons.security_rounded,
                    title: 'Protection RLS Supabase',
                    description: 'Sécurité au niveau de la base de données empêchant toute escalade de privilèges.',
                  ),
                  _FeatureCard(
                    icon: Icons.devices_rounded,
                    title: 'Interface Responsive',
                    description: 'Accès fluide sur ordinateurs, tablettes et smartphones.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5EAE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF196B5B), size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF153D35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Color(0xFF65736F), height: 1.4, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
