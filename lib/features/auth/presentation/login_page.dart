import 'package:flutter/material.dart';
import 'auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.controller,
    required this.supabaseReady,
    super.key,
  });
  final AuthController controller;
  final bool supabaseReady;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final fields = <Widget>[
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || !value.contains('@') ? 'Email invalide' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: Icon(Icons.lock_outline),
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.length < 6 ? '6 caractères minimum' : null,
      ),
      if (controller.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            controller.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: !widget.supabaseReady || controller.isBusy ? null : _submit,
        child: Text(_createAccount ? 'Créer le compte' : 'Se connecter'),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: !widget.supabaseReady || controller.isBusy
            ? null
            : controller.signInWithGoogle,
        icon: const Icon(Icons.login),
        label: const Text('Continuer avec Google'),
      ),
      TextButton(
        onPressed: widget.supabaseReady
            ? () => setState(() => _createAccount = !_createAccount)
            : null,
        child: Text(_createAccount ? 'J’ai déjà un compte' : 'Créer un compte'),
      ),
      if (!_createAccount)
        TextButton(
          onPressed: widget.supabaseReady ? _forgotPassword : null,
          child: const Text('Mot de passe oublié ?'),
        ),
    ];
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.school_rounded, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    'Scooper',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _createAccount
                        ? 'Créer votre espace'
                        : 'Bienvenue dans votre espace',
                    textAlign: TextAlign.center,
                  ),
                  if (!widget.supabaseReady)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Supabase n’est pas disponible. Vérifiez la configuration du projet.',
                          ),
                        ),
                      ),
                    ),
                  ...fields,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_createAccount) {
      await widget.controller.signUp(_email.text, _password.text);
    } else {
      await widget.controller.signIn(_email.text, _password.text);
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.isNotEmpty) {
      await widget.controller.resetPassword(_email.text);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
