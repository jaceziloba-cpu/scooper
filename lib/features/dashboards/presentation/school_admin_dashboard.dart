import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../users/domain/school_membership.dart';

class SchoolAdminDashboard extends StatefulWidget {
  const SchoolAdminDashboard({required this.controller, super.key});
  final AuthController controller;

  @override
  State<SchoolAdminDashboard> createState() => _SchoolAdminDashboardState();
}

class _SchoolAdminDashboardState extends State<SchoolAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SchoolMembership> _pendingRequests = [];
  List<SchoolMembership> _schoolMembers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _loading = true);
    final schoolId = widget.controller.membership?.schoolId;
    if (schoolId != null) {
      final pending =
          await widget.controller.getPendingTeacherRequests(schoolId);
      final members = await widget.controller.getSchoolMembers(schoolId);
      if (mounted) {
        setState(() {
          _pendingRequests = pending;
          _schoolMembers = members;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membership = widget.controller.membership;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administration • ${membership?.schoolName ?? 'Établissement'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAdminData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: widget.controller.signOut,
            tooltip: 'Se déconnecter',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person_search_rounded),
              text: 'Demandes Enseignants (${_pendingRequests.length})',
            ),
            Tab(
              icon: const Icon(Icons.groups_rounded),
              text: 'Membres (${_schoolMembers.length})',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _TeacherRequestsView(
                  requests: _pendingRequests,
                  onApprove: (id) async {
                    await widget.controller.approveTeacherRequest(id);
                    await _loadAdminData();
                  },
                  onReject: (id, reason) async {
                    await widget.controller.rejectTeacherRequest(id, reason);
                    await _loadAdminData();
                  },
                ),
                _SchoolMembersView(members: _schoolMembers),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _TeacherRequestsView extends StatelessWidget {
  const _TeacherRequestsView({
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  final List<SchoolMembership> requests;
  final Function(String id) onApprove;
  final Function(String id, String? reason) onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline_rounded,
                size: 64, color: Color(0xFF196B5B)),
            SizedBox(height: 16),
            Text(
              'Aucune demande d’enseignant en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF153D35),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Toutes les demandes ont été traitées.',
              style: TextStyle(color: Color(0xFF65736F)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
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
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5F0),
                      child: Icon(Icons.person_rounded,
                          color: Color(0xFF196B5B)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.userFullName ?? req.userEmail ?? 'Enseignant',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF153D35),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${req.subject ?? 'Matière non spécifiée'} • ${req.functionTitle ?? 'Enseignant'}',
                            style: const TextStyle(
                              color: Color(0xFF65736F),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5E3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'En attente',
                        style: TextStyle(
                          color: Color(0xFF9A6500),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (req.justificationUrl != null &&
                    req.justificationUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.attachment_rounded,
                          size: 16, color: Color(0xFF196B5B)),
                      const SizedBox(width: 6),
                      Text(
                        'Justificatif fourni : ${req.justificationUrl}',
                        style: const TextStyle(
                          color: Color(0xFF196B5B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(context, req.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Refuser'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => onApprove(req.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF196B5B),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Accepter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String membershipId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser la demande d’enseignant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Indiquez un motif de refus (optionnel mais recommandé) :'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Motif de refus',
                hintText: 'ex: Pièce justificative non valide',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReject(membershipId, reasonCtrl.text);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Confirmer le refus'),
          ),
        ],
      ),
    );
  }
}

class _SchoolMembersView extends StatelessWidget {
  const _SchoolMembersView({required this.members});
  final List<SchoolMembership> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(child: Text('Aucun membre enregistré.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = members[index];
        final isTeacher = member.membershipType == MembershipType.teacher;
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE5EAE8)),
          ),
          leading: CircleAvatar(
            backgroundColor: isTeacher
                ? const Color(0xFFE8F5F0)
                : const Color(0xFFEAF0FF),
            child: Icon(
              isTeacher ? Icons.badge_rounded : Icons.school_rounded,
              color: isTeacher
                  ? const Color(0xFF196B5B)
                  : const Color(0xFF2962FF),
            ),
          ),
          title: Text(
            member.userFullName ?? member.userEmail ?? 'Membre',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isTeacher
                ? 'Enseignant (${member.subject ?? 'Toutes matières'})'
                : 'Élève (${member.className ?? 'Général'})',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Actif',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
