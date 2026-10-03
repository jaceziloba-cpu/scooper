import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 80 : 24,
              vertical: desktop ? 80 : 40,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF164F43), Color(0xFF24826D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🎓 La plateforme SaaS pour les établissements scolaires',
                            style: TextStyle(
                              color: Color(0xFFBDE9D8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Pilotez votre établissement scolaire en toute simplicité.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 46 : 32,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SCOOPER rassemble la gestion des élèves, la validation des enseignants et les informations scolaires au même endroit avec une sécurité et une fluidité optimales.',
                          style: TextStyle(
                            color: const Color(0xFFD3F1E6),
                            fontSize: desktop ? 18 : 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            FilledButton.icon(
                              onPressed: () => controller.setPublicTab(PublicTab.register),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFBDE9D8),
                                foregroundColor: const Color(0xFF164F43),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              icon: const Icon(Icons.rocket_launch_rounded),
                              label: const Text('Rejoindre SCOOPER'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => controller.setPublicTab(PublicTab.presentation),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              icon: const Icon(Icons.play_circle_outline_rounded),
                              label: const Text('Découvrir SCOOPER'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (desktop) ...[
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 360,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 90,
                              color: Color(0xFFBDE9D8),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'SCOOPER SaaS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Espace Élèves • Enseignants • Direction',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Features Summary Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 80 : 24,
              vertical: 60,
            ),
            child: Column(
              children: [
                const Text(
                  'Une plateforme conçue pour chaque profil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF153D35),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Découvrez les fonctionnalités adaptées aux élèves, enseignants et administrateurs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF65736F)),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: const [
                    _RoleCard(
                      icon: Icons.school_rounded,
                      title: 'Élèves',
                      description:
                          'Accès instantané à l’espace de classe, emploi du temps et informations publiques de leur établissement.',
                      badge: 'Validation automatique',
                    ),
                    _RoleCard(
                      icon: Icons.person_search_rounded,
                      title: 'Enseignants',
                      description:
                          'Inscription sécurisée soumise à la vérification et validation par la direction de l’établissement.',
                      badge: 'Validation par l’école',
                    ),
                    _RoleCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Administration',
                      description:
                          'Gestion centrale des validations, des membres, des classes et du paramétrage de l’établissement.',
                      badge: 'Espace sécurisé',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5EAE8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF196B5B), size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF196B5B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Color(0xFF196B5B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF65736F),
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
