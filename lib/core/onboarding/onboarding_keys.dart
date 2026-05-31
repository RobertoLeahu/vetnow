import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerOnboardingKeys {
  final searchBar = GlobalKey();
  final nearby = GlobalKey();
  final bottomNav = GlobalKey();
}

class ClinicOnboardingKeys {
  final dashboard = GlobalKey();
  final quickAccess = GlobalKey();
  final bottomNav = GlobalKey();
}

final ownerOnboardingKeysProvider = Provider<OwnerOnboardingKeys>(
  (ref) => OwnerOnboardingKeys(),
);

final clinicOnboardingKeysProvider = Provider<ClinicOnboardingKeys>(
  (ref) => ClinicOnboardingKeys(),
);
