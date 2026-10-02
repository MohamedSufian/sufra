import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/sufra_logo.dart';
import 'auth.dart';

/// Email + password, sign in or create an account. Pops with true once signed in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _creating = false;
  var _busy = false;
  var _showPassword = false;
  String? _message;
  var _messageIsError = true;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final auth = ref.read(authServiceProvider);
    if (auth == null) {
      setState(() => _message = l10n.demoMode);
      return;
    }
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final outcome = _creating
          ? await auth.signUp(_email.text, _password.text)
          : await auth.signIn(_email.text, _password.text);
      if (!mounted) return;
      if (outcome == AuthOutcome.signedIn) {
        context.pop(true);
        return;
      }
      setState(() {
        _busy = false;
        _creating = false;
        _messageIsError = false;
        _message = l10n.authCheckEmail;
      });
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _messageIsError = true;
        _message = switch (e.problem) {
          AuthProblem.invalidCredentials => l10n.authInvalidCredentials,
          AuthProblem.emailNotConfirmed => l10n.authEmailNotConfirmed,
          AuthProblem.userExists => l10n.authUserExists,
          AuthProblem.weakPassword => l10n.authWeakPassword,
          AuthProblem.network => l10n.authFailed,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demo = ref.watch(authServiceProvider) == null;

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Center(child: SufraLogo(size: 64, color: AppColors.coral, cutColor: null)),
            const SizedBox(height: 16),
            Text(
              _creating ? l10n.signUpTitle : l10n.signIn,
              textAlign: TextAlign.center,
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.signInBenefit,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.mail_outline_rounded)),
              validator: (v) => _emailPattern.hasMatch((v ?? '').trim()) ? null : l10n.emailInvalid,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: !_showPassword,
              textDirection: TextDirection.ltr,
              autofillHints: [_creating ? AutofillHints.newPassword : AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _showPassword ? l10n.hidePassword : l10n.showPassword,
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                ),
              ),
              validator: (v) => (v ?? '').length < 8 ? l10n.passwordTooShort : null,
            ),
            if (_message != null || demo) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _messageIsError || demo ? context.sufra.softAccent : AppColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _message ?? l10n.demoMode,
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy || demo ? null : _submit,
              child: _busy
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(_creating ? l10n.signUpTitle : l10n.signIn),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _creating = !_creating;
                        _message = null;
                      }),
              child: Text(_creating ? l10n.haveAccount : l10n.noAccount),
            ),
          ],
        ),
      ),
    );
  }
}
