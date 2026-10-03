import 'package:flutter/material.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../users/domain/role_request.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    final name =
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        'Utilisateur';
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              title: const Text(
                'scooper',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: [_logoutButton()],
            ),
      body: Row(
        children: [
          if (desktop) _SideBar(onLogout: controller.signOut),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(desktop ? 48 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (desktop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tableau de bord',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF153D35),
                            ),
                          ),
                          _logoutButton(),
                        ],
                      )
                    else
                      const Text(
                        'Tableau de bord',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF153D35),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Bonjour $name, voici votre espace.',
                      style: const TextStyle(
                        color: Color(0xFF65736F),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RoleRequestCard(controller: controller),
                    const SizedBox(height: 32),
                    const Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _SummaryCard(
                          icon: Icons.calendar_month_rounded,
                          label: 'Emploi du temps',
                          value: 'À venir',
                          color: Color(0xFFE4F4EE),
                        ),
                        _SummaryCard(
                          icon: Icons.groups_rounded,
                          label: 'Équipe',
                          value: 'À configurer',
                          color: Color(0xFFEAF0FF),
                        ),
                        _SummaryCard(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          value: 'Aucune nouvelle',
                          color: Color(0xFFFFF2DF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _WelcomeCard(email: user.email ?? ''),
                        ),
                        if (desktop) const SizedBox(width: 18),
                        if (desktop)
                          const Expanded(flex: 2, child: _NextStepCard()),
                      ],
                    ),
                    if (user.emailConfirmedAt == null) ...[
                      const SizedBox(height: 18),
                      _VerificationCard(
                        onResend: controller.resendVerification,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() => OutlinedButton.icon(
    onPressed: controller.signOut,
    icon: const Icon(Icons.logout_rounded, size: 18),
    label: const Text('Se déconnecter'),
  );
}

class _SideBar extends StatelessWidget {
  const _SideBar({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Container(
    width: 250,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF164F43),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'scooper',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 54),
        const _NavItem(
          icon: Icons.dashboard_rounded,
          label: 'Tableau de bord',
          selected: true,
        ),
        const _NavItem(
          icon: Icons.calendar_month_rounded,
          label: 'Emploi du temps',
        ),
        const _NavItem(icon: Icons.groups_rounded, label: 'Équipe'),
        const _NavItem(
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
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
  Widget build(BuildContext context) => Container(
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 230,
    child: Card(
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
            const SizedBox(height: 18),
            Text(label, style: const TextStyle(color: Color(0xFF65736F))),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF153D35),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFE8F5F0),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.waving_hand_rounded,
            color: Color(0xFF196B5B),
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bienvenue dans Scooper',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF153D35),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Votre espace est prêt. Commencez par configurer votre établissement pour inviter votre équipe et organiser vos journées.',
            style: TextStyle(color: Color(0xFF50665F), height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            email,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF196B5B),
            ),
          ),
        ],
      ),
    ),
  );
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaine étape',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF153D35),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Configurez votre établissement pour débloquer les fonctionnalités de votre équipe.',
            style: TextStyle(color: Color(0xFF65736F), height: 1.5),
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(
            value: .2,
            minHeight: 8,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
    ),
  );
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.onResend});
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(
        Icons.mark_email_unread_outlined,
        color: Color(0xFFB36B00),
      ),
      title: const Text('Vérifiez votre adresse email'),
      subtitle: const Text('Un lien de confirmation vous a été envoyé.'),
      trailing: TextButton(onPressed: onResend, child: const Text('Renvoyer')),
    ),
  );
}

class _RoleRequestCard extends StatefulWidget {
  const _RoleRequestCard({required this.controller});
  final AuthController controller;

  @override
  State<_RoleRequestCard> createState() => _RoleRequestCardState();
}

class _RoleRequestCardState extends State<_RoleRequestCard> {
  RequestedRole _selectedRole = RequestedRole.teacher;

  @override
  Widget build(BuildContext context) {
    final request = widget.controller.roleRequest;
    if (widget.controller.isRoleLoading && request == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: LinearProgressIndicator(),
        ),
      );
    }
    if (request != null) return _statusCard(request);
    return Card(
      color: const Color(0xFFF0F7F4),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dites-nous qui vous êtes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF153D35),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre demande sera vérifiée par l’administration. Le choix ci-dessous ne donne aucun accès supplémentaire tout seul.',
              style: TextStyle(color: Color(0xFF50665F), height: 1.45),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<RequestedRole>(
              key: ValueKey(_selectedRole),
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Votre rôle',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: RequestedRole.values
                  .map(
                    (role) =>
                        DropdownMenuItem(value: role, child: Text(role.label)),
                  )
                  .toList(),
              onChanged: widget.controller.isBusy
                  ? null
                  : (role) => setState(() => _selectedRole = role!),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: widget.controller.isBusy
                    ? null
                    : () => widget.controller.requestRole(_selectedRole),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Envoyer ma demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(RoleRequest request) {
    final approved = request.isApproved;
    final color = approved ? const Color(0xFF196B5B) : const Color(0xFF9A6500);
    return Card(
      color: approved ? const Color(0xFFE8F5F0) : const Color(0xFFFFF5E3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
        ),
        leading: Icon(
          approved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
          color: color,
          size: 30,
        ),
        title: Text(
          approved
              ? 'Rôle validé : ${request.requestedRole.label}'
              : 'Demande en attente : ${request.requestedRole.label}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF153D35),
          ),
        ),
        subtitle: Text(
          approved
              ? 'Vos accès seront activés par le serveur.'
              : 'L’administration doit valider votre rôle avant l’accès aux fonctionnalités dédiées.',
          style: const TextStyle(color: Color(0xFF50665F)),
        ),
      ),
    );
  }
}
