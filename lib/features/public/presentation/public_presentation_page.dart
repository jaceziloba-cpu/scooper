import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class PublicPresentationPage extends StatelessWidget {
  const PublicPresentationPage({required this.controller, super.key});
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
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Présentation de SCOOPER',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'La solution moderne pour la gestion et l’interaction au sein des communautés éducatives.',
                style: TextStyle(fontSize: 18, color: Color(0xFF65736F)),
              ),
              const SizedBox(height: 36),
              const Card(
                elevation: 0,
                color: Color(0xFFE8F5F0),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Color(0xFF196B5B), size: 36),
                      SizedBox(height: 16),
                      Text(
                        'Notre Mission',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF153D35),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'SCOOPER est né du constat que la communication et la validation des rôles au sein des établissements scolaires doivent être rapides, intuitives et rigoureusement sécurisées.',
                        style: TextStyle(color: Color(0xFF50665F), height: 1.5, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Pourquoi choisir SCOOPER ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 20),
              const _FeaturePoint(
                icon: Icons.check_circle_outline_rounded,
                title: 'Authentification & Rôles Sécurisés',
                description: 'Connexion email/mot de passe et Google OAuth. Chaque utilisateur dispose de droits stricts sans fuite d’information.',
              ),
              const SizedBox(height: 16),
              const _FeaturePoint(
                icon: Icons.check_circle_outline_rounded,
                title: 'Validation des Enseignants',
                description: 'Un enseignant demandant à rejoindre une école doit fournir son profil et ses pièces justificatives avant d’être validé par l’administration.',
              ),
              const SizedBox(height: 16),
              const _FeaturePoint(
                icon: Icons.check_circle_outline_rounded,
                title: 'Accès Élèves Immédiat',
                description: 'Les élèves s’inscrivent et accèdent directement à leur espace de cours et emploi du temps sans blocage administratif inutile.',
              ),
              const SizedBox(height: 40),
              Center(
                child: FilledButton.icon(
                  onPressed: () => controller.setPublicTab(PublicTab.register),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF196B5B),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Commencer gratuitement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF196B5B), size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF65736F), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
