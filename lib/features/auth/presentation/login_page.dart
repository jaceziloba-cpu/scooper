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
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final controller = widget.controller;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) const Expanded(flex: 5, child: _BrandPanel()),
            Expanded(
              flex: desktop ? 4 : 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 64 : 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!desktop) ...[
                            const _ScooperMark(compact: true),
                            const SizedBox(height: 28),
                          ],
                          Text(
                            _createAccount
                                ? 'Créer votre espace'
                                : 'Bon retour 👋',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF153D35),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _createAccount
                                ? 'Organisez votre établissement avec une équipe toujours synchronisée.'
                                : 'Connectez-vous pour retrouver votre espace Scooper.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF65736F),
                                  height: 1.45,
                                ),
                          ),
                          const SizedBox(height: 30),
                          if (!widget.supabaseReady)
                            const _MessageCard(
                              icon: Icons.cloud_off_outlined,
                              message:
                                  'Le service est temporairement indisponible.',
                            ),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Adresse email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? 'Saisissez une adresse email valide'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
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
                          if (controller.errorMessage != null) ...[
                            const SizedBox(height: 14),
                            _MessageCard(
                              icon: Icons.info_outline_rounded,
                              message: controller.errorMessage!,
                              error: true,
                            ),
                          ],
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed:
                                !widget.supabaseReady || controller.isBusy
                                ? null
                                : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                            ),
                            child: controller.isBusy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _createAccount
                                        ? 'Créer mon compte'
                                        : 'Se connecter',
                                  ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed:
                                !widget.supabaseReady || controller.isBusy
                                ? null
                                : controller.signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
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
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _createAccount
                                    ? 'Vous avez déjà un compte ?'
                                    : 'Nouveau sur Scooper ?',
                                style: const TextStyle(
                                  color: Color(0xFF65736F),
                                ),
                              ),
                              TextButton(
                                onPressed: widget.supabaseReady
                                    ? () => setState(
                                        () => _createAccount = !_createAccount,
                                      )
                                    : null,
                                child: Text(
                                  _createAccount
                                      ? 'Se connecter'
                                      : 'Créer un compte',
                                ),
                              ),
                            ],
                          ),
                          if (!_createAccount)
                            Center(
                              child: TextButton(
                                onPressed: widget.supabaseReady
                                    ? _forgotPassword
                                    : null,
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(56),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [Color(0xFF164F43), Color(0xFF24826D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ScooperMark(),
        const Spacer(),
        const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFFBDE9D8),
          size: 36,
        ),
        const SizedBox(height: 20),
        Text(
          'Votre établissement,\nplus simple à piloter.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Emploi du temps, équipe et informations importantes réunis dans un seul espace.',
          style: TextStyle(color: Color(0xFFD3F1E6), fontSize: 17, height: 1.5),
        ),
        const SizedBox(height: 44),
        const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFFBDE9D8)),
            SizedBox(width: 10),
            Text(
              'Pensé pour les équipes éducatives',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const Spacer(),
        const Text(
          'SCOOPER  •  ESPACE ÉTABLISSEMENT',
          style: TextStyle(
            color: Color(0xFFBDE9D8),
            letterSpacing: 1.2,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _ScooperMark extends StatelessWidget {
  const _ScooperMark({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 42 : 48,
        height: compact ? 42 : 48,
        decoration: BoxDecoration(
          color: compact ? const Color(0xFF196B5B) : const Color(0xFFBDE9D8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.school_rounded,
          color: compact ? Colors.white : const Color(0xFF164F43),
          size: compact ? 23 : 27,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        'scooper',
        style: TextStyle(
          color: compact ? const Color(0xFF164F43) : Colors.white,
          fontSize: compact ? 25 : 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
    ],
  );
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
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
