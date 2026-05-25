import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
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
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Rellena todos los campos');
      return;
    }
    if (!_privacyAccepted || !_termsAccepted) {
      setState(
        () => _error = 'Debes aceptar la política de privacidad y los términos',
      );
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
      if (mounted) context.go('/auth-resolve');
    } catch (e) {
      setState(() => _error = 'Error al registrarse: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.role == UserRole.clinic
                    ? 'Registro de clínica'
                    : 'Registro de propietario',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre completo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),
              _ConsentRow(
                value: _privacyAccepted,
                onChanged: (v) =>
                    setState(() => _privacyAccepted = v ?? false),
                linkText: 'Política de Privacidad',
                onLinkTap: () => context.push('/profile/settings/privacy'),
              ),
              const SizedBox(height: 8),
              _ConsentRow(
                value: _termsAccepted,
                onChanged: (v) =>
                    setState(() => _termsAccepted = v ?? false),
                linkText: 'Términos y Condiciones',
                onLinkTap: () => context.push('/profile/settings/terms'),
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
                      : const Text('Crear cuenta'),
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
  final String linkText;
  final VoidCallback onLinkTap;

  const _ConsentRow({
    required this.value,
    required this.onChanged,
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
                const TextSpan(text: 'He leído y acepto la '),
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
