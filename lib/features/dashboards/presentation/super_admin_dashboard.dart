import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../establishments/domain/school.dart';
import '../../users/domain/user_profile.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({required this.controller, super.key});
  final AuthController controller;

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<School> _schools = [];
  List<UserProfile> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSuperAdminData();
  }

  Future<void> _loadSuperAdminData() async {
    setState(() => _loading = true);
    final schools = await widget.controller.getAllSchoolsAdmin();
    final users = await widget.controller.getAllUsersAdmin();
    if (mounted) {
      setState(() {
        _schools = schools;
        _users = users;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super Administration SCOOPER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadSuperAdminData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: widget.controller.signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.domain_rounded),
              text: 'Établissements (${_schools.length})',
            ),
            Tab(
              icon: const Icon(Icons.people_alt_rounded),
              text: 'Tous les Utilisateurs (${_users.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSchoolDialog,
        backgroundColor: const Color(0xFF196B5B),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer un établissement'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _SchoolsAdminListView(schools: _schools),
                _UsersAdminListView(users: _users),
              ],
            ),
    );
  }

  void _showCreateSchoolDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Établissement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom de l’école *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'Code établissement'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'Ville'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await widget.controller.createSchoolAdmin(
                School(
                  id: '',
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim().isNotEmpty ? codeCtrl.text.trim() : null,
                  city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null,
                ),
              );
              await _loadSuperAdminData();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF196B5B)),
            child: const Text('Créer'),
          ),
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

class _SchoolsAdminListView extends StatelessWidget {
  const _SchoolsAdminListView({required this.schools});
  final List<School> schools;

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return const Center(child: Text('Aucun établissement enregistré.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: schools.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final school = schools[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE5EAE8)),
          ),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFE8F5F0),
            child: Icon(Icons.account_balance_rounded, color: Color(0xFF196B5B)),
          ),
          title: Text(school.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${school.code ?? 'Pas de code'} • ${school.city ?? 'France'}'),
        );
      },
    );
  }
}

class _UsersAdminListView extends StatelessWidget {
  const _UsersAdminListView({required this.users});
  final List<UserProfile> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final u = users[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE5EAE8)),
          ),
          leading: CircleAvatar(
            child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U'),
          ),
          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${u.email} • Rôle: ${u.role.label}'),
        );
      },
    );
  }
}
