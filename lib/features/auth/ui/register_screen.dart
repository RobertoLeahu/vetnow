import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/l10n_ext.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../../../features/clinic_panel/providers/clinic_panel_provider.dart';
import '../../../shared/models/profile.dart';
import '../../../app/theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _privacyAccepted = false;
  bool _termsAccepted = false;

  bool get _canSubmit => _privacyAccepted && _termsAccepted && !_loading;

  Future<void> _register() async {
    final l10n = context.l10n;
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.fillAllFields);
      return;
    }
    if (!_privacyAccepted || !_termsAccepted) {
      setState(() => _error = l10n.registerMustAcceptLegal);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now().toUtc();
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            fullName: _nameCtrl.text.trim(),
            role: widget.role,
            privacyAcceptedAt: now,
            termsAcceptedAt: now,
          );
      ref.invalidate(profileProvider);
      await ref.read(profileProvider.future);
      if (widget.role == UserRole.clinic) {
        ref.invalidate(myClinicProvider);
      }
      if (mounted) context.go('/auth-resolve');
    } on RegisterException catch (e) {
      final message = switch (e.failure) {
        RegisterFailure.emailAlreadyExists => l10n.registerEmailAlreadyExists,
        RegisterFailure.emailExistsWrongPassword =>
          l10n.registerEmailExistsWrongPassword,
      };
      setState(() => _error = message);
    } catch (e) {
      setState(() => _error = l10n.registerError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.role == UserRole.clinic
                    ? l10n.registerClinicTitle
                    : l10n.registerOwnerTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.fullName),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
              const SizedBox(height: 24),
              _ConsentRow(
                value: _privacyAccepted,
                onChanged: (v) =>
                    setState(() => _privacyAccepted = v ?? false),
                consentPrefix: l10n.consentPrefix,
                linkText: l10n.privacyPolicyLink,
                onLinkTap: () => context.push('/legal/privacy'),
              ),
              const SizedBox(height: 8),
              _ConsentRow(
                value: _termsAccepted,
                onChanged: (v) =>
                    setState(() => _termsAccepted = v ?? false),
                consentPrefix: l10n.consentPrefix,
                linkText: l10n.termsAndConditionsLink,
                onLinkTap: () => context.push('/legal/terms'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _register : null,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.createAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String consentPrefix;
  final String linkText;
  final VoidCallback onLinkTap;

  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.consentPrefix,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(value: value, onChanged: onChanged),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: [
                TextSpan(text: consentPrefix),
                TextSpan(
                  text: linkText,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
