import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ClinicHomeScreen extends ConsumerWidget {
  const ClinicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Panel clínica')),
      body: Center(
        child: Text(
          'Bienvenido, ${profile?.fullName ?? ''}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
