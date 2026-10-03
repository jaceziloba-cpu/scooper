import 'package:flutter/material.dart';

import 'auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.controller,
    required this.supabaseReady,
    this.initialForgotPassword = false,
    super.key,
  });

  final AuthController controller;
  final bool supabaseReady;
  final bool initialForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _isResettingPassword = false;

  @override
  void initState() {
    super.initState();
    _isResettingPassword = widget.initialForgotPassword;
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final controller = widget.controller;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: desktop ? 64 : 24,
          vertical: 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE5EAE8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF196B5B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'scooper',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF164F43),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isResettingPassword
                          ? 'Mot de passe oublié'
                          : 'Se connecter',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF153D35),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isResettingPassword
                          ? 'Saisissez votre e-mail pour recevoir un lien de réinitialisation.'
                          : 'Connectez-vous avec vos identifiants pour retrouver votre espace.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF65736F),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!widget.supabaseReady)
                      const _MessageCard(
                        icon: Icons.cloud_off_outlined,
                        message: 'Le service est temporairement indisponible.',
                      ),
                    if (controller.errorMessage != null)
                      _MessageCard(
                        icon: Icons.info_outline_rounded,
                        message: controller.errorMessage!,
                        error: true,
                      ),
                    if (controller.successMessage != null)
                      _MessageCard(
                        icon: Icons.check_circle_outline_rounded,
                        message: controller.successMessage!,
                        error: false,
                      ),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: _isResettingPassword
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Saisissez une adresse email valide'
                              : null,
                    ),
                    if (!_isResettingPassword) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _showPassword ? 'Masquer' : 'Afficher',
                            onPressed: () => setState(
                              () => _showPassword = !_showPassword,
                            ),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.length < 6
                                ? '6 caractères minimum'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed:
                          !widget.supabaseReady || controller.isBusy
                              ? null
                              : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF196B5B),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: controller.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isResettingPassword
                                  ? 'Envoyer le lien'
                                  : 'Se connecter',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    if (!_isResettingPassword) ...[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed:
                            !widget.supabaseReady || controller.isBusy
                                ? null
                                : controller.signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        icon: const Text(
                          'G',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        label: const Text('Continuer avec Google'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isResettingPassword = !_isResettingPassword;
                            });
                          },
                          child: Text(
                            _isResettingPassword
                                ? 'Retour à la connexion'
                                : 'Mot de passe oublié ?',
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.setPublicTab(PublicTab.register),
                          child: const Text('Créer un compte'),
                        ),
                      ],
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
    if (_isResettingPassword) {
      await widget.controller.resetPassword(_email.text);
    } else {
      await widget.controller.signIn(_email.text, _password.text);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    this.error = false,
  });

  final IconData icon;
  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error
        ? const Color(0xFFC62828)
        : const Color(0xFF196B5B);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
