import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({required this.controller, super.key});
  final AuthController controller;

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final controller = widget.controller;
    final profile = controller.profile;
    final membership = controller.membership;
    final name = profile?.fullName ?? 'Élève';

    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              title: const Text(
                'scooper • Élève',
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
            _StudentSideBar(
              onLogout: controller.signOut,
              studentName: name,
              selectedIndex: _selectedIndex,
              onSectionSelected: _selectSection,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(desktop ? 48 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _selectedIndex == 0
                    ? Column(
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
                                'Bonjour, $name 👋',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF153D35),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Espace Élève • ${membership?.schoolName ?? 'Établissement'} ${membership?.className != null ? '(${membership!.className})' : ''}',
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
                          icon: Icons.calendar_month_rounded,
                          title: 'Emploi du temps',
                          value: 'Disponible',
                          color: Color(0xFFE8F5F0),
                        ),
                        _SummaryCard(
                          icon: Icons.class_rounded,
                          title: 'Ma Classe',
                          value: 'Inscrit(e)',
                          color: Color(0xFFEAF0FF),
                        ),
                        _SummaryCard(
                          icon: Icons.verified_user_rounded,
                          title: 'Statut Compte',
                          value: 'Approuvé',
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
                              Icons.school_rounded,
                              size: 48,
                              color: Color(0xFF196B5B),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bienvenue dans votre espace Élève SCOOPER',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF153D35),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Votre compte est prêt. Vous avez accès directement à vos informations scolaires.',
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
                      )
                    : _buildSelectedSection(
                        context,
                        profile: profile,
                        membership: membership,
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectSection,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Planning',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
    );
  }

  void _selectSection(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildSelectedSection(
    BuildContext context, {
    required dynamic profile,
    required dynamic membership,
  }) {
    if (_selectedIndex == 1) {
      return _StudentTimetable(
        schoolName: membership?.schoolName,
        className: membership?.className,
      );
    }

    return _StudentProfileView(profile: profile, membership: membership);
  }
}

class _StudentSideBar extends StatelessWidget {
  const _StudentSideBar({
    required this.onLogout,
    required this.studentName,
    required this.selectedIndex,
    required this.onSectionSelected,
  });
  final VoidCallback onLogout;
  final String studentName;
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;

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
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Tableau de bord',
            selected: selectedIndex == 0,
            onTap: () => onSectionSelected(0),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Emploi du temps',
            selected: selectedIndex == 1,
            onTap: () => onSectionSelected(1),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Mon Profil',
            selected: selectedIndex == 2,
            onTap: () => onSectionSelected(2),
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
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
        onTap: onTap,
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

class _StudentTimetable extends StatelessWidget {
  const _StudentTimetable({this.schoolName, this.className});

  final String? schoolName;
  final String? className;

  @override
  Widget build(BuildContext context) {
    const lessons = [
      ('08:00', 'Mathématiques', 'Salle A12', Color(0xFFE8F5F0)),
      ('10:00', 'Français', 'Salle B04', Color(0xFFEAF0FF)),
      ('14:00', 'Sciences', 'Laboratoire', Color(0xFFFFF3E0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mon emploi du temps',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF153D35),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${schoolName ?? 'Mon établissement'}${className == null ? '' : ' • $className'}',
          style: const TextStyle(color: Color(0xFF65736F)),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.today_rounded, color: Color(0xFF196B5B)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Aujourd’hui',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Exporter'),
                    ),
                  ],
                ),
                const Divider(height: 28),
                for (final lesson in lessons)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: lesson.$4,
                      child: Text(
                        lesson.$1.substring(0, 2),
                        style: const TextStyle(
                          color: Color(0xFF153D35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      lesson.$2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(lesson.$3),
                    trailing: Text(
                      lesson.$1,
                      style: const TextStyle(
                        color: Color(0xFF196B5B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _FeatureNotice(
          icon: Icons.notifications_active_outlined,
          title: 'Les changements seront signalés ici',
          message: 'Votre emploi du temps reste consultable hors ligne. Une mise à jour sera synchronisée dès que la connexion revient.',
        ),
      ],
    );
  }
}

class _StudentProfileView extends StatelessWidget {
  const _StudentProfileView({required this.profile, required this.membership});

  final dynamic profile;
  final dynamic membership;

  @override
  Widget build(BuildContext context) {
    final fullName = profile?.fullName ?? 'Élève';
    final email = profile?.email ?? 'Adresse non disponible';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mon profil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF153D35),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Vos informations personnelles et scolaires',
          style: TextStyle(color: Color(0xFF65736F)),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFE8F5F0),
                  child: Text(
                    fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF196B5B),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Color(0xFF65736F))),
                const Divider(height: 32),
                _ProfileLine(icon: Icons.school_outlined, label: 'Établissement', value: membership?.schoolName ?? 'Non renseigné'),
                _ProfileLine(icon: Icons.class_outlined, label: 'Classe', value: membership?.className ?? 'Non renseignée'),
                _ProfileLine(icon: Icons.verified_user_outlined, label: 'Statut', value: 'Compte approuvé'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: const Color(0xFF196B5B)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF65736F))),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}

class _FeatureNotice extends StatelessWidget {
  const _FeatureNotice({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFFF7F9F8),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF196B5B)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(message),
        ),
      );
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
