import 'package:flutter/material.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/presentation/register_choice_page.dart';
import 'public_features_page.dart';
import 'public_home_page.dart';
import 'public_presentation_page.dart';
import 'public_schools_page.dart';

class PublicNavigationShell extends StatelessWidget {
  const PublicNavigationShell({
    required this.controller,
    required this.supabaseReady,
    super.key,
  });

  final AuthController controller;
  final bool supabaseReady;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _PublicNavBar(controller: controller, desktop: desktop),
      ),
      endDrawer: desktop ? null : _PublicDrawer(controller: controller),
      body: _buildCurrentTabContent(context),
      bottomNavigationBar: desktop ? _PublicFooter() : null,
    );
  }

  Widget _buildCurrentTabContent(BuildContext context) {
    return switch (controller.publicTab) {
      PublicTab.home => PublicHomePage(controller: controller),
      PublicTab.presentation => PublicPresentationPage(controller: controller),
      PublicTab.features => PublicFeaturesPage(controller: controller),
      PublicTab.schools => PublicSchoolsPage(controller: controller),
      PublicTab.login => LoginPage(
        controller: controller,
        supabaseReady: supabaseReady,
      ),
      PublicTab.register => RegisterChoicePage(
        controller: controller,
        supabaseReady: supabaseReady,
      ),
      PublicTab.forgotPassword => LoginPage(
        controller: controller,
        supabaseReady: supabaseReady,
        initialForgotPassword: true,
      ),
    };
  }
}

class _PublicNavBar extends StatelessWidget {
  const _PublicNavBar({required this.controller, required this.desktop});

  final AuthController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5EAE8))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: () => controller.setPublicTab(PublicTab.home),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF196B5B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'scooper',
                    style: TextStyle(
                      color: Color(0xFF164F43),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (desktop)
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavTabButton(
                        label: 'Accueil',
                        selected: controller.publicTab == PublicTab.home,
                        onTap: () => controller.setPublicTab(PublicTab.home),
                      ),
                      _NavTabButton(
                        label: 'Présentation',
                        selected: controller.publicTab == PublicTab.presentation,
                        onTap: () => controller.setPublicTab(PublicTab.presentation),
                      ),
                      _NavTabButton(
                        label: 'Fonctionnalités',
                        selected: controller.publicTab == PublicTab.features,
                        onTap: () => controller.setPublicTab(PublicTab.features),
                      ),
                      _NavTabButton(
                        label: 'Établissements',
                        selected: controller.publicTab == PublicTab.schools,
                        onTap: () => controller.setPublicTab(PublicTab.schools),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () => controller.setPublicTab(PublicTab.login),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF196B5B),
                          side: const BorderSide(color: Color(0xFF196B5B)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () => controller.setPublicTab(PublicTab.register),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF196B5B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF196B5B) : const Color(0xFF50665F),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _PublicDrawer extends StatelessWidget {
  const _PublicDrawer({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(Icons.school_rounded, color: Color(0xFF196B5B), size: 30),
                  SizedBox(width: 10),
                  Text(
                    'scooper',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF164F43),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Accueil'),
              selected: controller.publicTab == PublicTab.home,
              onTap: () {
                Navigator.pop(context);
                controller.setPublicTab(PublicTab.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Présentation'),
              selected: controller.publicTab == PublicTab.presentation,
              onTap: () {
                Navigator.pop(context);
                controller.setPublicTab(PublicTab.presentation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.featured_play_list_outlined),
              title: const Text('Fonctionnalités'),
              selected: controller.publicTab == PublicTab.features,
              onTap: () {
                Navigator.pop(context);
                controller.setPublicTab(PublicTab.features);
              },
            ),
            ListTile(
              leading: const Icon(Icons.domain_rounded),
              title: const Text('Établissements'),
              selected: controller.publicTab == PublicTab.schools,
              onTap: () {
                Navigator.pop(context);
                controller.setPublicTab(PublicTab.schools);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.setPublicTab(PublicTab.login);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Se connecter'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.setPublicTab(PublicTab.register);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF196B5B),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF153D35),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: const [
          Text(
            '© 2026 SCOOPER - SaaS Éducatif. Tous droits réservés.',
            style: TextStyle(color: Color(0xFFBDE9D8), fontSize: 13),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mentions légales',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              SizedBox(width: 16),
              Text(
                'Confidentialité',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
