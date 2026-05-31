import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_client.dart';
import '../../shared/models/profile.dart';
import 'onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(),
);

/// When true, the hub screen should launch the tour even if already completed.
final forceOnboardingProvider = StateProvider<bool>((ref) => false);

Future<bool> shouldShowOnboarding(WidgetRef ref, UserRole role) async {
  if (ref.read(forceOnboardingProvider)) return true;

  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;

  final completed = await ref
      .read(onboardingRepositoryProvider)
      .isCompleted(role, userId);
  return !completed;
}

Future<void> completeOnboarding(WidgetRef ref, UserRole role) async {
  ref.read(forceOnboardingProvider.notifier).state = false;

  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  await ref.read(onboardingRepositoryProvider).markCompleted(role, userId);
}

Future<void> replayOnboarding(WidgetRef ref, UserRole role) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  await ref.read(onboardingRepositoryProvider).reset(role, userId);
  ref.read(forceOnboardingProvider.notifier).state = true;
}
