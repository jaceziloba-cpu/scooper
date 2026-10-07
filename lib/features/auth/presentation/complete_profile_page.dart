import 'package:flutter/material.dart';

import 'auth_controller.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({required this.controller, super.key});
  final AuthController controller;

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _className = TextEditingController();
  final _subject = TextEditingController();
  final _functionTitle = TextEditingController();
  final _justificationUrl = TextEditingController();

  String _role = 'student'; // 'student' or 'teacher'
  String? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.user;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      _firstName.text = meta['first_name'] as String? ??
          meta['given_name'] as String? ??
          '';
      _lastName.text = meta['last_name'] as String? ??
          meta['family_name'] as String? ??
          '';
    }

    widget.controller.loadSchools().then((_) {
      if (mounted && widget.controller.schools.isNotEmpty) {
        setState(() {
          _selectedSchoolId = widget.controller.schools.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final controller = widget.controller;
    final schools = controller.schools;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Complétez votre profil SCOOPER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: controller.signOut,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 64 : 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE5EAE8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_pin_rounded, color: Color(0xFF196B5B), size: 32),
                          SizedBox(width: 12),
                          Text(
                            'Finaliser votre profil',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF153D35),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pour accéder à votre espace, veuillez renseigner votre établissement et vos informations.',
                        style: TextStyle(color: Color(0xFF65736F), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      if (controller.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      const Text(
                        'Vous êtes :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'student',
                            label: Text('Élève'),
                            icon: Icon(Icons.school_rounded),
                          ),
                          ButtonSegment(
                            value: 'teacher',
                            label: Text('Enseignant'),
                            icon: Icon(Icons.badge_rounded),
                          ),
                        ],
                        selected: {_role},
                        onSelectionChanged: (val) => setState(() => _role = val.first),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstName,
                              decoration: const InputDecoration(
                                labelText: 'Prénom *',
                                hintText: 'ex. John',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Prénom requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastName,
                              decoration: const InputDecoration(
                                labelText: 'Nom *',
                                hintText: 'ex. Dupont',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dob,
                              decoration: const InputDecoration(
                                labelText: 'Date de naissance',
                                prefixIcon: Icon(Icons.cake_outlined),
                                hintText: 'JJ/MM/AAAA — ex. 15/04/2008',
                              ),
                            ),
                          ),
                          if (_role == 'teacher') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSchoolId,
                        decoration: const InputDecoration(
                          labelText: 'Établissement *',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        items: schools.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(s.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedSchoolId = val),
                        validator: (v) => v == null ? 'Sélectionnez une école' : null,
                      ),
                      const SizedBox(height: 14),
                      if (_role == 'student')
                        TextFormField(
                          controller: _className,
                          decoration: const InputDecoration(
                            labelText: 'Classe / niveau',
                            prefixIcon: Icon(Icons.class_outlined),
                            hintText: 'ex: Terminale S',
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subject,
                                decoration: const InputDecoration(
                                  labelText: 'Matière enseignée *',
                                  prefixIcon: Icon(Icons.menu_book_rounded),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Matière requise' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _functionTitle,
                                decoration: const InputDecoration(
                                  labelText: 'Fonction *',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Fonction requise' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _justificationUrl,
                          decoration: const InputDecoration(
                            labelText: 'Justificatif (Lien / Référence)',
                            prefixIcon: Icon(Icons.attachment_rounded),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: controller.isBusy ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF196B5B),
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: controller.isBusy
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Enregistrer et continuer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchoolId == null) return;

    await widget.controller.completeProfileAndMembership(
      role: _role,
      firstName: _firstName.text,
      lastName: _lastName.text,
      dateOfBirth: _dob.text,
      phone: _phone.text,
      schoolId: _selectedSchoolId!,
      className: _className.text,
      subject: _subject.text,
      functionTitle: _functionTitle.text,
      justificationUrl: _justificationUrl.text,
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _phone.dispose();
    _className.dispose();
    _subject.dispose();
    _functionTitle.dispose();
    _justificationUrl.dispose();
    super.dispose();
  }
}
