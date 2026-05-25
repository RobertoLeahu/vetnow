import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String dateLocaleCode(Locale locale) =>
    locale.languageCode == 'en' ? 'en' : 'es';

/// Short weekday letters for calendar header (Mon–Sun order in UI).
String weekdayLetters(Locale locale) =>
    locale.languageCode == 'en' ? 'S,M,T,W,T,F,S' : 'D,L,M,X,J,V,S';

DateFormat dateFormat(String pattern, Locale locale) =>
    DateFormat(pattern, dateLocaleCode(locale));

/// "d MMMM" / "MMMM d" style for booking continue button.
String monthDayPattern(Locale locale) =>
    locale.languageCode == 'en' ? 'MMMM d' : "d 'de' MMMM";

/// Full date with weekday for summary rows.
String weekdayMonthDayPattern(Locale locale) =>
    locale.languageCode == 'en' ? 'EEEE, MMMM d' : "EEEE d 'de' MMMM";

/// Appointment booked success body pattern.
String appointmentAtPattern(Locale locale) =>
    locale.languageCode == 'en'
        ? "MMMM d 'at' HH:mm"
        : "d 'de' MMMM 'a las' HH:mm";

/// Card subtitle: EEE d MMM · HH:mm
String appointmentCardPattern(Locale locale) =>
    locale.languageCode == 'en' ? 'EEE MMM d · HH:mm' : 'EEE d MMM · HH:mm';

/// Search upcoming slot: "d 'de' MMMM" vs "MMMM d"
String searchSlotDatePattern(Locale locale) =>
    locale.languageCode == 'en' ? 'MMMM d' : "d 'de' MMMM";

/// Clinic home today header.
String todayHeaderPattern(Locale locale) =>
    locale.languageCode == 'en' ? 'EEEE, MMMM d' : "EEEE, d 'de' MMMM";

/// Patient visit detail.
String visitDetailPattern(Locale locale) =>
    locale.languageCode == 'en'
        ? "MMMM d, yyyy · HH:mm"
        : "d 'de' MMMM 'de' yyyy · HH:mm";

String visitShortDatePattern(Locale locale) =>
    locale.languageCode == 'en' ? 'MMM d, yyyy' : 'd MMM yyyy';

String lastAppointmentPattern(Locale locale) =>
    locale.languageCode == 'en' ? 'MMM d, yyyy' : 'd MMM yyyy';
