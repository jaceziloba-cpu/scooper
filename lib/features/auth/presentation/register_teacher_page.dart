import 'package:flutter/material.dart';

import 'auth_controller.dart';

class RegisterTeacherPage extends StatefulWidget {
  const RegisterTeacherPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final AuthController controller;
  final VoidCallback onBack;

  @override
  State<RegisterTeacherPage> createState() => _RegisterTeacherPageState();
}

class _RegisterTeacherPageState extends State<RegisterTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _functionTitle = TextEditingController();
  final _professionalInfo = TextEditingController();
  final _justificationUrl = TextEditingController();
  String? _selectedSchoolId;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
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

    return Center(
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: widget.onBack,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Inscription Enseignant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF153D35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Fournissez vos informations professionnelles. Votre demande sera examinée par la direction de l’établissement.',
                      style: TextStyle(color: Color(0xFF65736F), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    if (controller.errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstName,
                            decoration: const InputDecoration(labelText: 'Prénom *'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Prénom requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastName,
                            decoration: const InputDecoration(labelText: 'Nom *'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email professionnelle *',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _password,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe *',
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: (v) => v == null || v.length < 6 ? '6 car. min.' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _confirmPassword,
                            obscureText: !_showPassword,
                            decoration: const InputDecoration(labelText: 'Confirmation *'),
                            validator: (v) => v != _password.text ? 'Différent' : null,
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
                            ),
                          ),
                        ),
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
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSchoolId,
                      decoration: const InputDecoration(
                        labelText: 'Établissement à rejoindre *',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _subject,
                            decoration: const InputDecoration(
                              labelText: 'Matière(s) enseignée(s) *',
                              prefixIcon: Icon(Icons.menu_book_rounded),
                              hintText: 'ex: Mathématiques',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Matière requise' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _functionTitle,
                            decoration: const InputDecoration(
                              labelText: 'Fonction / Titre *',
                              prefixIcon: Icon(Icons.badge_outlined),
                              hintText: 'ex: Prof. Titulaire',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Fonction requise' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _professionalInfo,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Informations complémentaires',
                        hintText: 'Année d’arrivée, référence interne, etc.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _justificationUrl,
                      decoration: const InputDecoration(
                        labelText: 'Justificatif (Lien / Référence document)',
                        prefixIcon: Icon(Icons.attachment_rounded),
                        hintText: 'URL de l’attestation ou du contrat',
                      ),
                    ),
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
                              'Soumettre ma demande Enseignant',
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
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchoolId == null) return;

    await widget.controller.signUpTeacher(
      email: _email.text,
      password: _password.text,
      firstName: _firstName.text,
      lastName: _lastName.text,
      dateOfBirth: _dob.text,
      phone: _phone.text,
      schoolId: _selectedSchoolId!,
      subject: _subject.text,
      functionTitle: _functionTitle.text,
      professionalInfo: _professionalInfo.text,
      justificationUrl: _justificationUrl.text,
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _dob.dispose();
    _phone.dispose();
    _subject.dispose();
    _functionTitle.dispose();
    _professionalInfo.dispose();
    _justificationUrl.dispose();
    super.dispose();
  }
}
