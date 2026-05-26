import 'package:flutter/widgets.dart';
import 'app_localizations.dart';
import '../shared/models/pet.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension PetSpeciesL10n on PetSpecies {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PetSpecies.dog => l10n.speciesDog,
        PetSpecies.cat => l10n.speciesCat,
        PetSpecies.rabbit => l10n.speciesRabbit,
        PetSpecies.hamster => l10n.speciesHamster,
        PetSpecies.bird => l10n.speciesBird,
        PetSpecies.reptile => l10n.speciesReptile,
        PetSpecies.ferret => l10n.speciesFerret,
        PetSpecies.other => l10n.speciesOther,
      };
}

String formatAppointmentDurationLabel(int minutes, AppLocalizations l10n) {
  if (minutes < 60) return l10n.durationMinutes(minutes);
  if (minutes == 60) return l10n.durationOneHour;
  if (minutes == 90) return l10n.durationOneHourThirty;
  if (minutes == 120) return l10n.durationTwoHours;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutes(h, m);
}

List<String> weekdayNames(AppLocalizations l10n) => [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];
