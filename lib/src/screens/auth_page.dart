import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/brand_mark.dart';

enum AuthMode { signIn, register }

/// Sign in / create account screen.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.authService});

  /// Injection point for tests; defaults to the real Firebase-backed service.
  final AuthService? authService;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  late final AuthService _auth = widget.authService ?? AuthService();

  AuthMode _mode = AuthMode.register;
  bool _busy = false;
  String? _error;

  bool get _isRegister => _mode == AuthMode.register;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _setMode(AuthMode mode) {
    if (mode == _mode || _busy) return;
    setState(() {
      _mode = mode;
      _error = null;
    });
    // Clears the previous mode's validation errors.
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_busy) return;

    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      if (_isRegister) {
        await _auth.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
      } else {
        await _auth.signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      // On success AuthGate swaps this screen for the home page. Nothing to do.
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
      debugPrint('Unexpected auth error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendResetLink() async {
    final email = _email.text.trim();
    if (Validators.email(email) != null) {
      setState(() => _error = 'Type your email above, then tap "Forgot password?".');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandMark(size: 76)),
                  const SizedBox(height: 20),
                  Text(
                    'iNote',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRegister
                        ? 'Create your account and start capturing ideas.'
                        : 'Welcome back. Sign in to pick up where you left off.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _ModeToggle(mode: _mode, onChanged: _setMode),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: _isRegister
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: AppTextField(
                                    controller: _name,
                                    label: 'Full name',
                                    hint: 'Ada Lovelace',
                                    prefixIcon: Icons.person_outline_rounded,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.words,
                                    autofillHints: const [AutofillHints.name],
                                    validator: Validators.displayName,
                                    enabled: !_busy,
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        AppTextField(
                          controller: _email,
                          label: 'Email',
                          hint: 'you@example.com',
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: Validators.email,
                          enabled: !_busy,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _password,
                          label: 'Password',
                          hint: _isRegister ? 'At least 6 characters' : 'Your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: [
                            _isRegister
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          validator: Validators.password,
                          onFieldSubmitted: (_) => _submit(),
                          enabled: !_busy,
                        ),
                      ],
                    ),
                  ),
                  if (!_isRegister)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _sendResetLink,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  _ErrorBanner(message: _error),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Text(_isRegister ? 'Create account' : 'Sign in'),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secured by Firebase Authentication',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped Sign in / Create account switch.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF241F1F) : const Color(0xFFF5E7E4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _segment(context, 'Sign in', AuthMode.signIn),
          _segment(context, 'Create account', AuthMode.register),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, AuthMode value) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value == mode;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline, animated error message (friendlier than a snackbar for form errors).
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = message;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 20,
                    color: scheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
