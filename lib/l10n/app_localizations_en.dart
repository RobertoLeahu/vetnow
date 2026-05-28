// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginWelcome => 'Welcome 👋';

  @override
  String get loginSubtitle => 'Sign in to VetNow';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginNoAccountRegister => 'Don\'t have an account? Sign up';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerClinicTitle => 'Clinic registration';

  @override
  String get registerOwnerTitle => 'Owner registration';

  @override
  String get fullName => 'Full name';

  @override
  String get fillAllFields => 'Fill in all fields';

  @override
  String get registerMustAcceptLegal =>
      'You must accept the privacy policy and terms';

  @override
  String registerError(String error) {
    return 'Registration error: $error';
  }

  @override
  String get registerEmailAlreadyExists =>
      'This email is already registered. Sign in or use a different email.';

  @override
  String get registerEmailExistsWrongPassword =>
      'This email already exists but the password does not match. Use the correct password or reset access in Supabase.';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get termsAndConditionsLink => 'Terms and Conditions';

  @override
  String get consentPrefix => 'I have read and accept the ';

  @override
  String get roleSelectorTitle => 'How will you use VetNow?';

  @override
  String get selectYourProfile => 'Select your profile';

  @override
  String get roleOwnerTitle => 'I\'m a pet owner';

  @override
  String get roleOwnerSubtitle =>
      'I look for clinics and book appointments for my pet';

  @override
  String get roleClinicTitle => 'I\'m a clinic';

  @override
  String get roleClinicSubtitle => 'I manage my schedule and receive bookings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get personalization => 'Personalization';

  @override
  String get privacyAndPolicy => 'Privacy policy';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get signOut => 'Sign out';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String signOutError(String error) {
    return 'Error signing out: $error';
  }

  @override
  String get deleteAccountConfirmBody =>
      'This will delete your personal data and sign you out. It cannot be undone.\n\nDo you want to continue?';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String deleteAccountError(String error) {
    return 'Could not delete account: $error';
  }

  @override
  String get appVersionLabel => 'App version: 5.271.0';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get enabled => 'On';

  @override
  String get disabled => 'Off';

  @override
  String get language => 'Language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get profileTitle => 'Profile';

  @override
  String get myPets => 'My pets';

  @override
  String get myAppointments => 'My appointments';

  @override
  String get notifications => 'Notifications';

  @override
  String get saved => 'Saved';

  @override
  String favoritesLoadError(String error) {
    return 'Error loading favorites: $error';
  }

  @override
  String get noSavedClinicsTitle => 'You haven\'t saved any clinics';

  @override
  String get noSavedClinicsSubtitle =>
      'When you save clinics with the heart icon, they\'ll appear here';

  @override
  String get findClinics => 'Find clinics';

  @override
  String get personalData => 'Personal details';

  @override
  String get emailAddress => 'Email address';

  @override
  String get phonePrefix => 'Prefix';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get changePassword => 'Change password';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get noChangesToSave => 'No changes to save';

  @override
  String get dataSaved => 'Data saved';

  @override
  String saveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get updatePassword => 'Update password';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get navSearch => 'Search';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navPets => 'Pets';

  @override
  String get navProfile => 'Profile';

  @override
  String get navClinicHome => 'Home';

  @override
  String get navClinicAgenda => 'Schedule';

  @override
  String get navClinicPatients => 'Patients';

  @override
  String get navMyClinic => 'My clinic';

  @override
  String get welcomeToVetNow => 'Welcome to VetNow';

  @override
  String welcomeToVetNowName(String name) {
    return 'Welcome to VetNow, $name!';
  }

  @override
  String get searchHintNameCityAddress => 'Search by name, city, or address';

  @override
  String get searchClinicsNearMe => 'Search clinics near me';

  @override
  String get allSpecialties => 'All';

  @override
  String get favoriteClinics => 'Favorite clinics';

  @override
  String get noFavoriteClinicsTitle => 'You don\'t have favorite clinics yet';

  @override
  String get noFavoriteClinicsSubtitle =>
      'Browse and tap the heart on any clinic to add it here.';

  @override
  String get upcomingAppointments => 'Upcoming appointments';

  @override
  String get noScheduledAppointmentsTitle =>
      'You have no scheduled appointments';

  @override
  String get noScheduledAppointmentsSubtitle =>
      'Book an appointment and it will appear here.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get locationDisabledTitle => 'Location disabled';

  @override
  String get locationDisabledMessage =>
      'Turn on location services on your device to see nearby clinics.';

  @override
  String get locationPermissionTitle => 'Location permission required';

  @override
  String get locationPermissionMessage =>
      'To show you the nearest clinics we need access to your location. Enable it in the app settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String locationFetchError(String error) {
    return 'Could not get your location: $error';
  }

  @override
  String get errorLocationTimeout =>
      'We could not get your location in time. Please try again.';

  @override
  String get errorLocationUnavailable =>
      'We could not access your location right now. Check your device settings and try again.';

  @override
  String get errorLocationPermissionDenied =>
      'Location permission is required to show nearby clinics.';

  @override
  String get errorNetwork =>
      'It looks like you\'re offline. Check your connection and try again.';

  @override
  String get errorTimeout => 'This action took too long. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorServer =>
      'There was a server problem. Please try again in a few minutes.';

  @override
  String get errorNotFound => 'We could not find the requested information.';

  @override
  String get errorValidation => 'Please review the data and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get searchClinicsTitle => 'Search clinics';

  @override
  String get searchHintShort => 'Name, city, or address';

  @override
  String get searchTypeToSeeResults => 'Type to see matching clinics';

  @override
  String searchNoClinicsForQuery(String query) {
    return 'No clinics for \"$query\"';
  }

  @override
  String get searchTryAnotherQuery => 'Try another name, city, or address';

  @override
  String get clinicNotFound => 'Clinic not found';

  @override
  String get aboutUs => 'About us';

  @override
  String get specialties => 'Specialties';

  @override
  String get clinicNoSpecialtiesConfigured =>
      'This clinic has no specialties configured';

  @override
  String get bookAppointment => 'Book appointment';

  @override
  String get selectSpecialty => 'Select specialty';

  @override
  String get nearbyClinicsTitle => 'Nearby clinics';

  @override
  String get viewOnMap => 'View on map';

  @override
  String noClinicsWithinRadius(String km) {
    return 'No clinics within $km km';
  }

  @override
  String get nearbyTryOtherSpecialty =>
      'Try another specialty or widen the search radius.';

  @override
  String get nearbyNeedsGps =>
      'Clinics need a registered GPS location to appear here.';

  @override
  String nearbyClinicsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clinics near you',
      one: '1 clinic near you',
    );
    return '$_temp0';
  }

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get petFilterLabel => 'Pet';

  @override
  String get allPets => 'All pets';

  @override
  String get petsLoadError => 'Could not load pets';

  @override
  String tabScheduled(int count) {
    return 'Scheduled ($count)';
  }

  @override
  String tabCompleted(int count) {
    return 'Completed ($count)';
  }

  @override
  String tabCancelled(int count) {
    return 'Cancelled ($count)';
  }

  @override
  String get noCompletedAppointmentsTitle =>
      'You have no completed appointments';

  @override
  String get completedAppointmentsSubtitle =>
      'Your visit history will appear here.';

  @override
  String get noCancelledAppointmentsTitle =>
      'You have no cancelled appointments';

  @override
  String get statusDone => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancelAppointment => 'Cancel appointment';

  @override
  String get cancelAppointmentConfirm =>
      'Are you sure you want to cancel this appointment?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get deleteAppointment => 'Delete appointment';

  @override
  String get deleteAppointmentConfirm =>
      'This appointment will be removed from your history. It cannot be undone.';

  @override
  String get yesDelete => 'Yes, delete';

  @override
  String get delete => 'Delete';

  @override
  String deleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get bookAppointmentTitle => 'Book appointment';

  @override
  String bookingError(String error) {
    return 'Booking error: $error';
  }

  @override
  String get appointmentBookedTitle => 'Appointment booked!';

  @override
  String appointmentBookedBody(String date) {
    return '$date';
  }

  @override
  String get viewMyAppointments => 'View my appointments';

  @override
  String get clinicNoAppointmentsYetTitle =>
      'This clinic does not accept appointments yet';

  @override
  String get clinicNoSchedulesSubtitle =>
      'The clinic has not set its opening hours yet.';

  @override
  String get back => 'Back';

  @override
  String get noSlotsThatDay => 'No time slots available that day';

  @override
  String get chooseAnotherDate => 'Choose another date';

  @override
  String get selectTime => 'Select a time';

  @override
  String get bookingPetQuestion => 'Which pet is the appointment for?';

  @override
  String get noPetsRegistered => 'You have no registered pets';

  @override
  String get addPet => 'Add pet';

  @override
  String get appointmentSummary => 'Appointment summary';

  @override
  String get clinicLabel => 'Clinic';

  @override
  String get specialtyLabel => 'Specialty';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get petLabel => 'Pet';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String bookingContinueWithDate(String date) {
    return 'Continue with $date';
  }

  @override
  String get weekdayLetters => 'S,M,T,W,T,F,S';

  @override
  String get myPetsTitle => 'My pets';

  @override
  String get noPetsYetTitle => 'You haven\'t added any pets yet';

  @override
  String get noPetsYetSubtitle => 'Add your pet to manage their appointments';

  @override
  String get uploadingPhoto => 'Uploading photo…';

  @override
  String get tapToAddPhoto => 'Tap to add or change photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removeProfilePhoto => 'Remove profile photo';

  @override
  String get editPetTooltip => 'Edit pet';

  @override
  String get deletePetTitle => 'Delete pet';

  @override
  String deletePetConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get newPet => 'New pet';

  @override
  String get editPet => 'Edit pet';

  @override
  String get nameRequired => 'Name *';

  @override
  String get nameRequiredError => 'Name is required';

  @override
  String get species => 'Species';

  @override
  String get breedOptional => 'Breed (optional)';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get birthDateOptional => 'Date of birth (optional)';

  @override
  String get savePet => 'Save pet';

  @override
  String get ageLessThanOneMonth => 'Less than 1 month';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get ageOneYear => '1 year';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get speciesDog => 'Dog';

  @override
  String get speciesCat => 'Cat';

  @override
  String get speciesRabbit => 'Rabbit';

  @override
  String get speciesHamster => 'Hamster';

  @override
  String get speciesBird => 'Bird';

  @override
  String get speciesReptile => 'Reptile';

  @override
  String get speciesFerret => 'Ferret';

  @override
  String get speciesOther => 'Other';

  @override
  String get myClinicFallback => 'My clinic';

  @override
  String get today => 'Today';

  @override
  String get completeYourProfile => 'Complete your profile';

  @override
  String get completeProfileBannerBody =>
      'Owners will be able to find you when you complete your clinic details.';

  @override
  String get complete => 'Complete';

  @override
  String get todayPatients => 'Today\'s patients';

  @override
  String get pendingYourConfirmation => 'Awaiting your confirmation';

  @override
  String appointmentsAwaitingConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appointments awaiting confirmation',
      one: '1 appointment awaiting confirmation',
    );
    return '$_temp0';
  }

  @override
  String get acceptOrRejectFromAgenda => 'Accept or decline from the schedule';

  @override
  String get activitySummary => 'Activity summary';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get manageYourAppointments => 'Manage your appointments';

  @override
  String get medicalRecords => 'Medical records';

  @override
  String get confirmedAppointmentsToday => 'confirmed appointments today';

  @override
  String get noAppointmentsTodayEnjoy =>
      'No appointments today. Enjoy your day.';

  @override
  String get nextAppointment => 'Next appointment';

  @override
  String get nextAppointments => 'Upcoming appointments';

  @override
  String get viewFullAgenda => 'View full schedule';

  @override
  String get showMore => 'Show more';

  @override
  String get appointmentsOverview => 'Overview of your appointments';

  @override
  String get viewAgenda => 'View schedule';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get statConfirmed => 'Confirmed';

  @override
  String get statCompleted => 'Completed';

  @override
  String get toConfirm => 'Pending confirmation';

  @override
  String confirmedPatientsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count confirmed patients today',
      one: '1 confirmed patient today',
    );
    return '$_temp0';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String cancelledThisWeek(int count) {
    return '$count cancelled this week';
  }

  @override
  String cancelledToday(int count) {
    return '$count cancelled today';
  }

  @override
  String totalAwaitingConfirmation(int count) {
    return '$count total awaiting your confirmation';
  }

  @override
  String get noConfirmedPatientsToday =>
      'No patients with a confirmed appointment today.';

  @override
  String get agendaTitle => 'Schedule';

  @override
  String get clinicProfileNotFound => 'Clinic profile not found.';

  @override
  String get dateFilter => 'Date';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get allAppointments => 'All appointments';

  @override
  String tabPending(int count) {
    return 'Pending ($count)';
  }

  @override
  String tabConfirmedCount(int count) {
    return 'Confirmed ($count)';
  }

  @override
  String get noPendingAppointments => 'No pending appointments';

  @override
  String get newBookingsAppearHere => 'New bookings will appear here.';

  @override
  String get noConfirmedAppointments => 'No confirmed appointments';

  @override
  String get noCompletedAppointmentsClinic => 'No completed appointments';

  @override
  String get noCancelledAppointmentsClinic => 'No cancelled appointments';

  @override
  String get confirmAppointment => 'Confirm appointment';

  @override
  String get confirmAppointmentBody =>
      'Confirm this appointment? The owner will see the updated status.';

  @override
  String get yesConfirm => 'Yes, confirm';

  @override
  String get confirm => 'Confirm';

  @override
  String get denyAppointment => 'Decline appointment';

  @override
  String get denyAppointmentBody =>
      'The appointment will be cancelled and the owner will see the change.';

  @override
  String get yesDeny => 'Yes, decline';

  @override
  String get deny => 'Decline';

  @override
  String get markAsDoneTitle => 'Mark as completed';

  @override
  String get markAsDoneBody => 'Mark this appointment as completed?';

  @override
  String get yesMark => 'Yes, mark';

  @override
  String get markAsDone => 'Mark as completed';

  @override
  String get deleteAppointmentClinicBody =>
      'This appointment will be removed from history. It cannot be undone.';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsLoadError => 'Could not load patients.';

  @override
  String get noPatientsYetTitle => 'No patients yet';

  @override
  String get noPatientsYetSubtitle =>
      'Owners who book appointments will appear here.';

  @override
  String get searchPatientByName => 'Search patient by name';

  @override
  String noResultsForQuery(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get tryAnotherName => 'Try another name.';

  @override
  String lastAppointment(String date) {
    return 'Last appointment · $date';
  }

  @override
  String get petsTitle => 'Pets';

  @override
  String get petsLoadErrorClinic => 'Could not load pets.';

  @override
  String get noPetsRegisteredClinic => 'No registered pets';

  @override
  String get ownerNoPetsWithVisits => 'This owner has no pets with visits.';

  @override
  String get history => 'History';

  @override
  String get clinicLoadError => 'Error loading clinic.';

  @override
  String get clinicNotFoundShort => 'Clinic not found.';

  @override
  String get historyLoadError => 'Could not load history.';

  @override
  String get noVisitsWithPetTitle => 'No appointments with this pet';

  @override
  String get noVisitsWithPetSubtitle =>
      'Pending, confirmed, or completed appointments will appear here to add notes.';

  @override
  String get clinicalNotes => 'Clinical notes';

  @override
  String clinicalNotesCount(int count) {
    return 'Clinical notes ($count)';
  }

  @override
  String get addAnotherNote => 'Add another note';

  @override
  String get addClinicalNote => 'Add clinical note';

  @override
  String get confirmAppointmentToAddNotes =>
      'Confirm the appointment in the schedule to add notes.';

  @override
  String get deleteNoteTitle => 'Delete note';

  @override
  String get deleteNoteConfirm =>
      'Are you sure you want to delete this clinical note? It cannot be undone.';

  @override
  String editedOn(String date) {
    return 'Edited $date';
  }

  @override
  String get edit => 'Edit';

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get newNoteHint => 'You can add several notes per visit.';

  @override
  String get editNoteHint => 'Update the text of this note.';

  @override
  String get noteHintExample => 'e.g. General check-up, rabies vaccine given…';

  @override
  String get saveNote => 'Save note';

  @override
  String get retry => 'Retry';

  @override
  String get newborn => 'newborn';

  @override
  String get ageOneMonth => '1 month';

  @override
  String get myClinicTitle => 'My clinic';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get unsavedChangesBody =>
      'You changed the clinic profile or hours without saving. What do you want to do?';

  @override
  String get save => 'Save';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get saveTooltip => 'Save';

  @override
  String schedulesLoadError(String error) {
    return 'Error loading hours: $error';
  }

  @override
  String get locationRegisteredSnack =>
      'Location saved. Your clinic will now appear in nearby searches.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileSavedNoLocation =>
      'Profile saved, but location could not be obtained. Check address and city (e.g. \"Valdemoro\") and save again.';

  @override
  String get registeringLocation => 'Registering your location on the map…';

  @override
  String get locationBannerNeedsSave =>
      'Your clinic has no GPS coordinates yet. Fill in address and city, then tap Save to appear in nearby searches.';

  @override
  String get locationBannerEnterCity =>
      'Enter the city (e.g. Valdemoro) and address so owners can find you nearby.';

  @override
  String get basicInformation => 'Basic information';

  @override
  String get clinicName => 'Clinic name';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get phone => 'Phone';

  @override
  String get contactEmail => 'Contact email';

  @override
  String get description => 'Description';

  @override
  String get requiredField => 'Required field';

  @override
  String get loadingSpecialties => 'Loading specialties…';

  @override
  String get appointmentDurationTitle => 'Appointment duration';

  @override
  String get appointmentDurationHelp =>
      'Each bookable slot will use this duration. Owners will see available times adjusted when you save.';

  @override
  String get durationPerAppointment => 'Duration per appointment';

  @override
  String get weeklyHours => 'Weekly schedule';

  @override
  String get closed => 'Closed';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get durationOneHour => '1 hour';

  @override
  String get durationOneHourThirty => '1 hour 30 min';

  @override
  String get durationTwoHours => '2 hours';

  @override
  String durationHours(int hours) {
    return '$hours hours';
  }

  @override
  String durationHoursMinutes(int minutes, int hours) {
    return '$hours h $minutes min';
  }

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get termsOfServiceTitle => 'Terms and conditions';
}
