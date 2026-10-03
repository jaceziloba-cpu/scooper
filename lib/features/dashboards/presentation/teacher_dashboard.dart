import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final profile = controller.profile;
    final membership = controller.membership;
    final name = profile?.fullName ?? 'Enseignant';

    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              title: const Text(
                'scooper • Enseignant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: controller.signOut,
                ),
              ],
            ),
      body: Row(
        children: [
          if (desktop)
            _TeacherSideBar(
              onLogout: controller.signOut,
              teacherName: name,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(desktop ? 48 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (desktop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Espace Enseignant • $name 👨‍🏫',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF153D35),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${membership?.schoolName ?? 'Établissement'} • Matière: ${membership?.subject ?? '-'}',
                                style: const TextStyle(
                                  color: Color(0xFF65736F),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.signOut,
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Se déconnecter'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        _SummaryCard(
                          icon: Icons.verified_rounded,
                          title: 'Statut Enseignant',
                          value: 'Validé',
                          color: Color(0xFFE8F5F0),
                        ),
                        _SummaryCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Mes Cours',
                          value: 'En ligne',
                          color: Color(0xFFEAF0FF),
                        ),
                        _SummaryCard(
                          icon: Icons.groups_rounded,
                          title: 'Élèves',
                          value: 'Accès actif',
                          color: Color(0xFFE8F5F0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 0,
                      color: const Color(0xFFE8F5F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 48,
                              color: Color(0xFF196B5B),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Compte Enseignant Approuvé',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF153D35),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Votre profil professionnel a été vérifié et approuvé par votre établissement. Vous pouvez maintenant gérer vos classes et emplois du temps.',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherSideBar extends StatelessWidget {
  const _TeacherSideBar({required this.onLogout, required this.teacherName});
  final VoidCallback onLogout;
  final String teacherName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF164F43),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_rounded, color: Color(0xFFBDE9D8), size: 28),
              SizedBox(width: 10),
              Text(
                'scooper',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Tableau de bord',
            selected: true,
          ),
          const _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Emploi du temps',
          ),
          const _NavItem(
            icon: Icons.groups_rounded,
            label: 'Mes Classes',
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFBDE9D8)),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: Color(0xFFBDE9D8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A7C69) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: selected ? Colors.white : const Color(0xFFBDE9D8),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFBDE9D8),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5EAE8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF196B5B)),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Color(0xFF65736F))),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF153D35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
