import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/profile.dart';

class OnboardingRepository {
  String _key(UserRole role, String userId) =>
      'onboarding_${role.name}_$userId';

  Future<bool> isCompleted(UserRole role, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(role, userId)) ?? false;
  }

  Future<void> markCompleted(UserRole role, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(role, userId), true);
  }

  Future<void> reset(UserRole role, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(role, userId));
  }
}
