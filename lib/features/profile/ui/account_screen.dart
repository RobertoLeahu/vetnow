import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../app/theme.dart';

({String prefix, String number}) _splitPhone(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return (prefix: '+34', number: '');
  }
  final trimmed = raw.trim();
  if (trimmed.startsWith('+')) {
    final spaceIdx = trimmed.indexOf(' ');
    if (spaceIdx > 0) {
      return (
        prefix: trimmed.substring(0, spaceIdx),
        number: trimmed.substring(spaceIdx + 1).trim(),
      );
    }
    final cut = trimmed.length >= 4 ? 3 : trimmed.length;
    return (
      prefix: trimmed.substring(0, cut),
      number: trimmed.substring(cut),
    );
  }
  return (prefix: '+34', number: trimmed);
}

String? _composePhone(String prefix, String number) {
  final pre = prefix.trim();
  final num = number.trim();
  if (pre.isEmpty && num.isEmpty) return null;
  if (num.isEmpty) return pre.isEmpty ? null : pre;
  return '$pre $num';
}

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _prefixCtrl;
  late final TextEditingController _numberCtrl;

  bool _seeded = false;
  String? _initialPhoneSerialized;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefixCtrl = TextEditingController();
    _numberCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _prefixCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  void _seedFromProfile(String? phoneFromDb) {
    if (_seeded) return;
    final split = _splitPhone(phoneFromDb);
    _prefixCtrl.text = split.prefix;
    _numberCtrl.text = split.number;
    _initialPhoneSerialized = _composePhone(split.prefix, split.number);
    _seeded = true;
  }

  Future<void> _savePhone() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final newSerialized =
        _composePhone(_prefixCtrl.text, _numberCtrl.text);
    if (newSerialized == _initialPhoneSerialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay cambios que guardar')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updatePhone(
            userId: user.id,
            phone: newSerialized,
          );
      ref.invalidate(profileProvider);
      _initialPhoneSerialized = newSerialized;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _ChangePasswordSheetContent(
          onSuccess: () => Navigator.of(sheetCtx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final email = ref.watch(authRepositoryProvider).currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          _seedFromProfile(profile?.phone);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Datos personales',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                child: Text(
                  email.isEmpty ? '—' : email,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _prefixCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Prefijo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _numberCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Número de teléfono',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Cambiar contraseña'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showChangePasswordSheet(context),
              ),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _savePhone,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChangePasswordSheetContent extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const _ChangePasswordSheetContent({required this.onSuccess});

  @override
  ConsumerState<_ChangePasswordSheetContent> createState() =>
      _ChangePasswordSheetContentState();
}

class _ChangePasswordSheetContentState
    extends ConsumerState<_ChangePasswordSheetContent> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final n = _newCtrl.text;
    final c = _confirmCtrl.text;
    if (n.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (n != c) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).updatePassword(n);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada')),
      );
      widget.onSuccess();
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cambiar contraseña',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nueva contraseña'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Confirmar contraseña'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Actualizar contraseña'),
          ),
        ],
      ),
    );
  }
}
