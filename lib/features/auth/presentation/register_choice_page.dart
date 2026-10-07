import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'register_student_page.dart';
import 'register_teacher_page.dart';

class RegisterChoicePage extends StatefulWidget {
  const RegisterChoicePage({
    required this.controller,
    required this.supabaseReady,
    super.key,
  });

  final AuthController controller;
  final bool supabaseReady;

  @override
  State<RegisterChoicePage> createState() => _RegisterChoicePageState();
}

class _RegisterChoicePageState extends State<RegisterChoicePage> {
  String? _selectedRole; // 'student' or 'teacher'

  @override
  Widget build(BuildContext context) {
    if (_selectedRole == 'student') {
      return RegisterStudentPage(
        controller: widget.controller,
        onBack: () => setState(() => _selectedRole = null),
      );
    }
    if (_selectedRole == 'teacher') {
      return RegisterTeacherPage(
        controller: widget.controller,
        onBack: () => setState(() => _selectedRole = null),
      );
    }

    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Center(
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
              side: const BorderSide(color: Color(0xFFE5EAE8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Créer un compte SCOOPER',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF153D35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choisissez votre rôle pour accéder à l’inscription adaptée.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF65736F)),
                  ),
                  const SizedBox(height: 32),
                  _RoleChoiceCard(
                    title: 'Élève',
                    description:
                        'Accès immédiat au tableau de bord élève, à vos cours et emploi du temps.',
                    badgeText: 'Validation automatique',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF196B5B),
                    onTap: () => setState(() => _selectedRole = 'student'),
                  ),
                  const SizedBox(height: 16),
                  _RoleChoiceCard(
                    title: 'Enseignant',
                    description:
                        'Inscription soumise à la vérification et validation par l’établissement.',
                    badgeText: 'Validation par l’école',
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF007A87),
                    onTap: () => setState(() => _selectedRole = 'teacher'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDE7E3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Color(0xFF196B5B),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Administrateur d’établissement',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF153D35),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ce compte est créé et validé par SCOOPER. Ne créez pas un compte public : connectez-vous avec les identifiants transmis par votre établissement.',
                                style: TextStyle(
                                  color: Color(0xFF65736F),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              TextButton(
                                onPressed: () => widget.controller.setPublicTab(PublicTab.login),
                                child: const Text('Accéder à la connexion établissement'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Vous avez déjà un compte ?',
                        style: TextStyle(color: Color(0xFF65736F)),
                      ),
                      TextButton(
                        onPressed: () =>
                            widget.controller.setPublicTab(PublicTab.login),
                        child: const Text('Se connecter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  const _RoleChoiceCard({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final String badgeText;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          color: color.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF65736F),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
