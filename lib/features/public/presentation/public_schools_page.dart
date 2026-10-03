import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../establishments/domain/school.dart';

class PublicSchoolsPage extends StatefulWidget {
  const PublicSchoolsPage({required this.controller, super.key});
  final AuthController controller;

  @override
  State<PublicSchoolsPage> createState() => _PublicSchoolsPageState();
}

class _PublicSchoolsPageState extends State<PublicSchoolsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadSchools();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final schools = widget.controller.schools;

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
                'Établissements SCOOPER',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF153D35),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Consultez la liste des établissements utilisant la plateforme SCOOPER.',
                style: TextStyle(fontSize: 18, color: Color(0xFF65736F)),
              ),
              const SizedBox(height: 36),
              if (schools.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schools.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final school = schools[index];
                    return _SchoolTile(school: school, controller: widget.controller);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolTile extends StatelessWidget {
  const _SchoolTile({required this.school, required this.controller});
  final School school;
  final AuthController controller;

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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF196B5B),
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        school.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF153D35),
                        ),
                      ),
                      if (school.code != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF196B5B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            school.code!,
                            style: const TextStyle(
                              color: Color(0xFF196B5B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${school.address ?? ''} ${school.city ?? ''} ${school.country}',
                    style: const TextStyle(color: Color(0xFF65736F), fontSize: 14),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => controller.setPublicTab(PublicTab.register),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF196B5B),
              ),
              icon: const Icon(Icons.school_rounded, size: 18),
              label: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
  }
}
