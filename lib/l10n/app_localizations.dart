import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @loginWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido 👋'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión en VetNow'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @loginNoAccountRegister.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get loginNoAccountRegister;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @registerClinicTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de clínica'**
  String get registerClinicTitle;

  /// No description provided for @registerOwnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de propietario'**
  String get registerOwnerTitle;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @fillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Rellena todos los campos'**
  String get fillAllFields;

  /// No description provided for @registerMustAcceptLegal.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar la política de privacidad y los términos'**
  String get registerMustAcceptLegal;

  /// No description provided for @registerError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse: {error}'**
  String registerError(String error);

  /// No description provided for @registerEmailAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Este email ya está registrado. Inicia sesión o usa otro email.'**
  String get registerEmailAlreadyExists;

  /// No description provided for @registerEmailExistsWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Este email ya existe pero la contraseña no coincide. Usa la contraseña correcta o recupera el acceso desde Supabase.'**
  String get registerEmailExistsWrongPassword;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicyLink;

  /// No description provided for @termsAndConditionsLink.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditionsLink;

  /// No description provided for @consentPrefix.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto la '**
  String get consentPrefix;

  /// No description provided for @roleSelectorTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo usarás VetNow?'**
  String get roleSelectorTitle;

  /// No description provided for @selectYourProfile.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu perfil'**
  String get selectYourProfile;

  /// No description provided for @roleOwnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Soy propietario'**
  String get roleOwnerTitle;

  /// No description provided for @roleOwnerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Busco clínicas y reservo citas para mi mascota'**
  String get roleOwnerSubtitle;

  /// No description provided for @roleClinicTitle.
  ///
  /// In es, this message translates to:
  /// **'Soy clínica'**
  String get roleClinicTitle;

  /// No description provided for @roleClinicSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiono mi agenda y recibo reservas'**
  String get roleClinicSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @account.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get termsAndConditions;

  /// No description provided for @personalization.
  ///
  /// In es, this message translates to:
  /// **'Personalización'**
  String get personalization;

  /// No description provided for @privacyAndPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política y privacidad'**
  String get privacyAndPolicy;

  /// No description provided for @deleteMyAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get deleteMyAccount;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar sesión?'**
  String get signOutConfirmMessage;

  /// No description provided for @signOutError.
  ///
  /// In es, this message translates to:
  /// **'Error al cerrar sesión: {error}'**
  String signOutError(String error);

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará tus datos personales y cerrará tu sesión. No se puede deshacer.\n\n¿Deseas continuar?'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta: {error}'**
  String deleteAccountError(String error);

  /// No description provided for @appVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'App version: 5.271.0'**
  String get appVersionLabel;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkMode;

  /// No description provided for @enabled.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get disabled;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @myPets.
  ///
  /// In es, this message translates to:
  /// **'Mis mascotas'**
  String get myPets;

  /// No description provided for @myAppointments.
  ///
  /// In es, this message translates to:
  /// **'Mis citas'**
  String get myAppointments;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Guardados'**
  String get saved;

  /// No description provided for @favoritesLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar favoritos: {error}'**
  String favoritesLoadError(String error);

  /// No description provided for @noSavedClinicsTitle.
  ///
  /// In es, this message translates to:
  /// **'No has guardado ninguna clínica'**
  String get noSavedClinicsTitle;

  /// No description provided for @noSavedClinicsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuando guardes clínicas con el corazón, las verás aquí'**
  String get noSavedClinicsSubtitle;

  /// No description provided for @findClinics.
  ///
  /// In es, this message translates to:
  /// **'Encontrar clínicas'**
  String get findClinics;

  /// No description provided for @personalData.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get personalData;

  /// No description provided for @emailAddress.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailAddress;

  /// No description provided for @phonePrefix.
  ///
  /// In es, this message translates to:
  /// **'Prefijo'**
  String get phonePrefix;

  /// No description provided for @phoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono'**
  String get phoneNumber;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @noChangesToSave.
  ///
  /// In es, this message translates to:
  /// **'No hay cambios que guardar'**
  String get noChangesToSave;

  /// No description provided for @dataSaved.
  ///
  /// In es, this message translates to:
  /// **'Datos guardados'**
  String get dataSaved;

  /// No description provided for @saveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {error}'**
  String saveError(String error);

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get passwordUpdated;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contraseña'**
  String get updatePassword;

  /// No description provided for @errorWithDetails.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @navSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get navSearch;

  /// No description provided for @navAppointments.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get navAppointments;

  /// No description provided for @navPets.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get navPets;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navClinicHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navClinicHome;

  /// No description provided for @navClinicAgenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get navClinicAgenda;

  /// No description provided for @navClinicPatients.
  ///
  /// In es, this message translates to:
  /// **'Pacientes'**
  String get navClinicPatients;

  /// No description provided for @navMyClinic.
  ///
  /// In es, this message translates to:
  /// **'Mi clínica'**
  String get navMyClinic;

  /// No description provided for @welcomeToVetNow.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a VetNow'**
  String get welcomeToVetNow;

  /// No description provided for @welcomeToVetNowName.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a VetNow, {name}!'**
  String welcomeToVetNowName(String name);

  /// No description provided for @searchHintNameCityAddress.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, ciudad o dirección'**
  String get searchHintNameCityAddress;

  /// No description provided for @searchClinicsNearMe.
  ///
  /// In es, this message translates to:
  /// **'Buscar clínicas cerca de mí'**
  String get searchClinicsNearMe;

  /// No description provided for @allSpecialties.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get allSpecialties;

  /// No description provided for @favoriteClinics.
  ///
  /// In es, this message translates to:
  /// **'Clínicas favoritas'**
  String get favoriteClinics;

  /// No description provided for @noFavoriteClinicsTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes clínicas favoritas'**
  String get noFavoriteClinicsTitle;

  /// No description provided for @noFavoriteClinicsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Explora y pulsa el corazón en cualquier clínica para añadirla aquí.'**
  String get noFavoriteClinicsSubtitle;

  /// No description provided for @upcomingAppointments.
  ///
  /// In es, this message translates to:
  /// **'Próximas citas'**
  String get upcomingAppointments;

  /// No description provided for @noScheduledAppointmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas programadas'**
  String get noScheduledAppointmentsTitle;

  /// No description provided for @noScheduledAppointmentsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva una cita y aparecerá aquí.'**
  String get noScheduledAppointmentsSubtitle;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get statusConfirmed;

  /// No description provided for @locationDisabledTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación desactivada'**
  String get locationDisabledTitle;

  /// No description provided for @locationDisabledMessage.
  ///
  /// In es, this message translates to:
  /// **'Activa el servicio de ubicación de tu dispositivo para ver las clínicas cercanas.'**
  String get locationDisabledMessage;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación necesario'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In es, this message translates to:
  /// **'Para mostrarte las clínicas más cercanas necesitamos acceder a tu ubicación. Actívala en los ajustes de la app.'**
  String get locationPermissionMessage;

  /// No description provided for @openSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get openSettings;

  /// No description provided for @locationFetchError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener tu ubicación: {error}'**
  String locationFetchError(String error);

  /// No description provided for @errorLocationTimeout.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido obtener tu ubicación a tiempo. Inténtalo de nuevo.'**
  String get errorLocationTimeout;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido acceder a tu ubicación ahora mismo. Revisa los ajustes del dispositivo e inténtalo otra vez.'**
  String get errorLocationUnavailable;

  /// No description provided for @errorLocationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos permiso de ubicación para mostrarte clínicas cercanas.'**
  String get errorLocationPermissionDenied;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Parece que no hay conexión. Revisa tu red e inténtalo de nuevo.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'La operación tardó demasiado. Inténtalo de nuevo.'**
  String get errorTimeout;

  /// No description provided for @errorSessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ha caducado. Inicia sesión de nuevo.'**
  String get errorSessionExpired;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un problema en el servidor. Vuelve a intentarlo en unos minutos.'**
  String get errorServer;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No hemos encontrado la información solicitada.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos introducidos e inténtalo de nuevo.'**
  String get errorValidation;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error inesperado. Inténtalo de nuevo.'**
  String get errorGeneric;

  /// No description provided for @searchClinicsTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar clínicas'**
  String get searchClinicsTitle;

  /// No description provided for @searchHintShort.
  ///
  /// In es, this message translates to:
  /// **'Nombre, ciudad o dirección'**
  String get searchHintShort;

  /// No description provided for @searchTypeToSeeResults.
  ///
  /// In es, this message translates to:
  /// **'Escribe para ver clínicas que coincidan'**
  String get searchTypeToSeeResults;

  /// No description provided for @searchNoClinicsForQuery.
  ///
  /// In es, this message translates to:
  /// **'No hay clínicas para \"{query}\"'**
  String searchNoClinicsForQuery(String query);

  /// No description provided for @searchTryAnotherQuery.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre, ciudad o dirección'**
  String get searchTryAnotherQuery;

  /// No description provided for @clinicNotFound.
  ///
  /// In es, this message translates to:
  /// **'Clínica no encontrada'**
  String get clinicNotFound;

  /// No description provided for @aboutUs.
  ///
  /// In es, this message translates to:
  /// **'Sobre nosotros'**
  String get aboutUs;

  /// No description provided for @specialties.
  ///
  /// In es, this message translates to:
  /// **'Especialidades'**
  String get specialties;

  /// No description provided for @clinicNoSpecialtiesConfigured.
  ///
  /// In es, this message translates to:
  /// **'Esta clínica no tiene especialidades configuradas'**
  String get clinicNoSpecialtiesConfigured;

  /// No description provided for @bookAppointment.
  ///
  /// In es, this message translates to:
  /// **'Reservar cita'**
  String get bookAppointment;

  /// No description provided for @selectSpecialty.
  ///
  /// In es, this message translates to:
  /// **'Selecciona especialidad'**
  String get selectSpecialty;

  /// No description provided for @nearbyClinicsTitle.
  ///
  /// In es, this message translates to:
  /// **'Clínicas cercanas'**
  String get nearbyClinicsTitle;

  /// No description provided for @viewOnMap.
  ///
  /// In es, this message translates to:
  /// **'Ver en el mapa'**
  String get viewOnMap;

  /// No description provided for @clinicMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get clinicMapTitle;

  /// No description provided for @clinicMapUserUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener tu ubicación. Se muestra solo la clínica.'**
  String get clinicMapUserUnavailable;

  /// No description provided for @locatingUser.
  ///
  /// In es, this message translates to:
  /// **'Obteniendo tu ubicación…'**
  String get locatingUser;

  /// No description provided for @noClinicsWithinRadius.
  ///
  /// In es, this message translates to:
  /// **'No hay clínicas en {km} km'**
  String noClinicsWithinRadius(String km);

  /// No description provided for @nearbyTryOtherSpecialty.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra especialidad o amplía el radio de búsqueda.'**
  String get nearbyTryOtherSpecialty;

  /// No description provided for @nearbyNeedsGps.
  ///
  /// In es, this message translates to:
  /// **'Las clínicas necesitan tener su ubicación GPS registrada para aparecer aquí.'**
  String get nearbyNeedsGps;

  /// No description provided for @nearbyClinicsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 clínica cerca de ti} other{{count} clínicas cerca de ti}}'**
  String nearbyClinicsCount(int count);

  /// No description provided for @appointmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get appointmentsTitle;

  /// No description provided for @petFilterLabel.
  ///
  /// In es, this message translates to:
  /// **'Mascota'**
  String get petFilterLabel;

  /// No description provided for @allPets.
  ///
  /// In es, this message translates to:
  /// **'Todas las mascotas'**
  String get allPets;

  /// No description provided for @petsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar mascotas'**
  String get petsLoadError;

  /// No description provided for @tabScheduled.
  ///
  /// In es, this message translates to:
  /// **'Programadas ({count})'**
  String tabScheduled(int count);

  /// No description provided for @tabCompleted.
  ///
  /// In es, this message translates to:
  /// **'Realizadas ({count})'**
  String tabCompleted(int count);

  /// No description provided for @tabCancelled.
  ///
  /// In es, this message translates to:
  /// **'Canceladas ({count})'**
  String tabCancelled(int count);

  /// No description provided for @noCompletedAppointmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas realizadas'**
  String get noCompletedAppointmentsTitle;

  /// No description provided for @completedAppointmentsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás el historial de tus visitas.'**
  String get completedAppointmentsSubtitle;

  /// No description provided for @noCancelledAppointmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas canceladas'**
  String get noCancelledAppointmentsTitle;

  /// No description provided for @statusDone.
  ///
  /// In es, this message translates to:
  /// **'Realizada'**
  String get statusDone;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get statusCancelled;

  /// No description provided for @cancelAppointment.
  ///
  /// In es, this message translates to:
  /// **'Cancelar cita'**
  String get cancelAppointment;

  /// No description provided for @cancelAppointmentConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar esta cita?'**
  String get cancelAppointmentConfirm;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get yesCancel;

  /// No description provided for @deleteAppointment.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cita'**
  String get deleteAppointment;

  /// No description provided for @deleteAppointmentConfirm.
  ///
  /// In es, this message translates to:
  /// **'Se borrará esta cita de tu historial. No se puede deshacer.'**
  String get deleteAppointmentConfirm;

  /// No description provided for @yesDelete.
  ///
  /// In es, this message translates to:
  /// **'Sí, eliminar'**
  String get yesDelete;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar: {error}'**
  String deleteFailed(String error);

  /// No description provided for @bookAppointmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Reservar cita'**
  String get bookAppointmentTitle;

  /// No description provided for @bookingError.
  ///
  /// In es, this message translates to:
  /// **'Error al reservar: {error}'**
  String bookingError(String error);

  /// No description provided for @appointmentBookedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Cita reservada!'**
  String get appointmentBookedTitle;

  /// No description provided for @appointmentBookedBody.
  ///
  /// In es, this message translates to:
  /// **'{date}'**
  String appointmentBookedBody(String date);

  /// No description provided for @viewMyAppointments.
  ///
  /// In es, this message translates to:
  /// **'Ver mis citas'**
  String get viewMyAppointments;

  /// No description provided for @clinicNoAppointmentsYetTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta clínica no acepta citas todavía'**
  String get clinicNoAppointmentsYetTitle;

  /// No description provided for @clinicNoSchedulesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La clínica aún no ha configurado sus horarios de atención.'**
  String get clinicNoSchedulesSubtitle;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @noSlotsThatDay.
  ///
  /// In es, this message translates to:
  /// **'No hay horarios disponibles ese día'**
  String get noSlotsThatDay;

  /// No description provided for @chooseAnotherDate.
  ///
  /// In es, this message translates to:
  /// **'Elegir otra fecha'**
  String get chooseAnotherDate;

  /// No description provided for @selectTime.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una hora'**
  String get selectTime;

  /// No description provided for @bookingPetQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué mascota es la cita?'**
  String get bookingPetQuestion;

  /// No description provided for @noPetsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tienes mascotas registradas'**
  String get noPetsRegistered;

  /// No description provided for @addPet.
  ///
  /// In es, this message translates to:
  /// **'Añadir mascota'**
  String get addPet;

  /// No description provided for @appointmentSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de la cita'**
  String get appointmentSummary;

  /// No description provided for @clinicLabel.
  ///
  /// In es, this message translates to:
  /// **'Clínica'**
  String get clinicLabel;

  /// No description provided for @specialtyLabel.
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get specialtyLabel;

  /// No description provided for @dateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get timeLabel;

  /// No description provided for @petLabel.
  ///
  /// In es, this message translates to:
  /// **'Mascota'**
  String get petLabel;

  /// No description provided for @confirmBooking.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get confirmBooking;

  /// No description provided for @bookingContinueWithDate.
  ///
  /// In es, this message translates to:
  /// **'Continuar con el {date}'**
  String bookingContinueWithDate(String date);

  /// No description provided for @weekdayLetters.
  ///
  /// In es, this message translates to:
  /// **'D,L,M,X,J,V,S'**
  String get weekdayLetters;

  /// No description provided for @myPetsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis mascotas'**
  String get myPetsTitle;

  /// No description provided for @noPetsYetTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no has añadido mascotas'**
  String get noPetsYetTitle;

  /// No description provided for @noPetsYetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade a tu mascota para gestionar sus citas'**
  String get noPetsYetSubtitle;

  /// No description provided for @uploadingPhoto.
  ///
  /// In es, this message translates to:
  /// **'Subiendo foto…'**
  String get uploadingPhoto;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In es, this message translates to:
  /// **'Toca para añadir o cambiar foto'**
  String get tapToAddPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Hacer foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get chooseFromGallery;

  /// No description provided for @removeProfilePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto de perfil'**
  String get removeProfilePhoto;

  /// No description provided for @editPetTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar mascota'**
  String get editPetTooltip;

  /// No description provided for @deletePetTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mascota'**
  String get deletePetTitle;

  /// No description provided for @deletePetConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar a {name}?'**
  String deletePetConfirm(String name);

  /// No description provided for @newPet.
  ///
  /// In es, this message translates to:
  /// **'Nueva mascota'**
  String get newPet;

  /// No description provided for @editPet.
  ///
  /// In es, this message translates to:
  /// **'Editar mascota'**
  String get editPet;

  /// No description provided for @nameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get nameRequired;

  /// No description provided for @nameRequiredError.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nameRequiredError;

  /// No description provided for @species.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get species;

  /// No description provided for @breedOptional.
  ///
  /// In es, this message translates to:
  /// **'Raza (opcional)'**
  String get breedOptional;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @birthDateOptional.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento (opcional)'**
  String get birthDateOptional;

  /// No description provided for @savePet.
  ///
  /// In es, this message translates to:
  /// **'Guardar mascota'**
  String get savePet;

  /// No description provided for @ageLessThanOneMonth.
  ///
  /// In es, this message translates to:
  /// **'Menos de 1 mes'**
  String get ageLessThanOneMonth;

  /// No description provided for @ageMonths.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 mes} other{{count} meses}}'**
  String ageMonths(int count);

  /// No description provided for @ageOneYear.
  ///
  /// In es, this message translates to:
  /// **'1 año'**
  String get ageOneYear;

  /// No description provided for @ageYears.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 año} other{{count} años}}'**
  String ageYears(int count);

  /// No description provided for @speciesDog.
  ///
  /// In es, this message translates to:
  /// **'Perro'**
  String get speciesDog;

  /// No description provided for @speciesCat.
  ///
  /// In es, this message translates to:
  /// **'Gato'**
  String get speciesCat;

  /// No description provided for @speciesRabbit.
  ///
  /// In es, this message translates to:
  /// **'Conejo'**
  String get speciesRabbit;

  /// No description provided for @speciesHamster.
  ///
  /// In es, this message translates to:
  /// **'Hámster'**
  String get speciesHamster;

  /// No description provided for @speciesBird.
  ///
  /// In es, this message translates to:
  /// **'Ave'**
  String get speciesBird;

  /// No description provided for @speciesReptile.
  ///
  /// In es, this message translates to:
  /// **'Reptil'**
  String get speciesReptile;

  /// No description provided for @speciesFerret.
  ///
  /// In es, this message translates to:
  /// **'Hurón'**
  String get speciesFerret;

  /// No description provided for @speciesOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get speciesOther;

  /// No description provided for @specialtyGeneralMedicine.
  ///
  /// In es, this message translates to:
  /// **'Medicina general'**
  String get specialtyGeneralMedicine;

  /// No description provided for @specialtyDermatology.
  ///
  /// In es, this message translates to:
  /// **'Dermatología'**
  String get specialtyDermatology;

  /// No description provided for @specialtyCardiology.
  ///
  /// In es, this message translates to:
  /// **'Cardiología'**
  String get specialtyCardiology;

  /// No description provided for @specialtyTraumatology.
  ///
  /// In es, this message translates to:
  /// **'Traumatología'**
  String get specialtyTraumatology;

  /// No description provided for @specialtyOphthalmology.
  ///
  /// In es, this message translates to:
  /// **'Oftalmología'**
  String get specialtyOphthalmology;

  /// No description provided for @specialtyExotics.
  ///
  /// In es, this message translates to:
  /// **'Animales exóticos'**
  String get specialtyExotics;

  /// No description provided for @specialtyEmergency.
  ///
  /// In es, this message translates to:
  /// **'Urgencias'**
  String get specialtyEmergency;

  /// No description provided for @myClinicFallback.
  ///
  /// In es, this message translates to:
  /// **'Mi clínica'**
  String get myClinicFallback;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @completeYourProfile.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil'**
  String get completeYourProfile;

  /// No description provided for @completeProfileBannerBody.
  ///
  /// In es, this message translates to:
  /// **'Los propietarios podrán encontrarte cuando completes los datos de tu clínica.'**
  String get completeProfileBannerBody;

  /// No description provided for @complete.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get complete;

  /// No description provided for @todayPatients.
  ///
  /// In es, this message translates to:
  /// **'Pacientes de hoy'**
  String get todayPatients;

  /// No description provided for @pendingYourConfirmation.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de tu confirmación'**
  String get pendingYourConfirmation;

  /// No description provided for @appointmentsAwaitingConfirmation.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 cita esperando confirmación} other{{count} citas esperando confirmación}}'**
  String appointmentsAwaitingConfirmation(int count);

  /// No description provided for @acceptOrRejectFromAgenda.
  ///
  /// In es, this message translates to:
  /// **'Acepta o rechaza desde la agenda'**
  String get acceptOrRejectFromAgenda;

  /// No description provided for @activitySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de actividad'**
  String get activitySummary;

  /// No description provided for @quickAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso rápido'**
  String get quickAccess;

  /// No description provided for @manageYourAppointments.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus citas'**
  String get manageYourAppointments;

  /// No description provided for @medicalRecords.
  ///
  /// In es, this message translates to:
  /// **'Expedientes médicos'**
  String get medicalRecords;

  /// No description provided for @confirmedAppointmentsToday.
  ///
  /// In es, this message translates to:
  /// **'citas confirmadas hoy'**
  String get confirmedAppointmentsToday;

  /// No description provided for @noAppointmentsTodayEnjoy.
  ///
  /// In es, this message translates to:
  /// **'Sin citas para hoy. Disfruta el día.'**
  String get noAppointmentsTodayEnjoy;

  /// No description provided for @nextAppointment.
  ///
  /// In es, this message translates to:
  /// **'Próxima cita'**
  String get nextAppointment;

  /// No description provided for @nextAppointments.
  ///
  /// In es, this message translates to:
  /// **'Próximas citas'**
  String get nextAppointments;

  /// No description provided for @viewFullAgenda.
  ///
  /// In es, this message translates to:
  /// **'Ver agenda completa'**
  String get viewFullAgenda;

  /// No description provided for @showMore.
  ///
  /// In es, this message translates to:
  /// **'Mostrar más'**
  String get showMore;

  /// No description provided for @appointmentsOverview.
  ///
  /// In es, this message translates to:
  /// **'Vista general de tus citas'**
  String get appointmentsOverview;

  /// No description provided for @viewAgenda.
  ///
  /// In es, this message translates to:
  /// **'Ver agenda'**
  String get viewAgenda;

  /// No description provided for @scheduled.
  ///
  /// In es, this message translates to:
  /// **'Programadas'**
  String get scheduled;

  /// No description provided for @statConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmadas'**
  String get statConfirmed;

  /// No description provided for @statCompleted.
  ///
  /// In es, this message translates to:
  /// **'Realizadas'**
  String get statCompleted;

  /// No description provided for @toConfirm.
  ///
  /// In es, this message translates to:
  /// **'Por confirmar'**
  String get toConfirm;

  /// No description provided for @confirmedPatientsToday.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 paciente confirmado hoy} other{{count} pacientes confirmados hoy}}'**
  String confirmedPatientsToday(int count);

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @cancelledThisWeek.
  ///
  /// In es, this message translates to:
  /// **'{count} canceladas esta semana'**
  String cancelledThisWeek(int count);

  /// No description provided for @cancelledToday.
  ///
  /// In es, this message translates to:
  /// **'{count} canceladas hoy'**
  String cancelledToday(int count);

  /// No description provided for @totalAwaitingConfirmation.
  ///
  /// In es, this message translates to:
  /// **'{count} en total esperando tu confirmación'**
  String totalAwaitingConfirmation(int count);

  /// No description provided for @noConfirmedPatientsToday.
  ///
  /// In es, this message translates to:
  /// **'Ningún paciente con cita confirmada para hoy.'**
  String get noConfirmedPatientsToday;

  /// No description provided for @agendaTitle.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get agendaTitle;

  /// No description provided for @clinicProfileNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el perfil de clínica.'**
  String get clinicProfileNotFound;

  /// No description provided for @dateFilter.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dateFilter;

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tomorrow;

  /// No description provided for @allAppointments.
  ///
  /// In es, this message translates to:
  /// **'Todas las citas'**
  String get allAppointments;

  /// No description provided for @tabPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes ({count})'**
  String tabPending(int count);

  /// No description provided for @tabConfirmedCount.
  ///
  /// In es, this message translates to:
  /// **'Confirmadas ({count})'**
  String tabConfirmedCount(int count);

  /// No description provided for @noPendingAppointments.
  ///
  /// In es, this message translates to:
  /// **'No hay citas pendientes'**
  String get noPendingAppointments;

  /// No description provided for @newBookingsAppearHere.
  ///
  /// In es, this message translates to:
  /// **'Las nuevas reservas aparecerán aquí.'**
  String get newBookingsAppearHere;

  /// No description provided for @noConfirmedAppointments.
  ///
  /// In es, this message translates to:
  /// **'No hay citas confirmadas'**
  String get noConfirmedAppointments;

  /// No description provided for @noCompletedAppointmentsClinic.
  ///
  /// In es, this message translates to:
  /// **'No hay citas realizadas'**
  String get noCompletedAppointmentsClinic;

  /// No description provided for @noCancelledAppointmentsClinic.
  ///
  /// In es, this message translates to:
  /// **'No hay citas canceladas'**
  String get noCancelledAppointmentsClinic;

  /// No description provided for @confirmAppointment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cita'**
  String get confirmAppointment;

  /// No description provided for @confirmAppointmentBody.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmas esta cita? El propietario verá el estado actualizado.'**
  String get confirmAppointmentBody;

  /// No description provided for @yesConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, confirmar'**
  String get yesConfirm;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @denyAppointment.
  ///
  /// In es, this message translates to:
  /// **'Denegar cita'**
  String get denyAppointment;

  /// No description provided for @denyAppointmentBody.
  ///
  /// In es, this message translates to:
  /// **'La cita quedará cancelada y el propietario verá el cambio.'**
  String get denyAppointmentBody;

  /// No description provided for @yesDeny.
  ///
  /// In es, this message translates to:
  /// **'Sí, denegar'**
  String get yesDeny;

  /// No description provided for @deny.
  ///
  /// In es, this message translates to:
  /// **'Denegar'**
  String get deny;

  /// No description provided for @markAsDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Marcar como realizada'**
  String get markAsDoneTitle;

  /// No description provided for @markAsDoneBody.
  ///
  /// In es, this message translates to:
  /// **'¿Marcar esta cita como realizada?'**
  String get markAsDoneBody;

  /// No description provided for @yesMark.
  ///
  /// In es, this message translates to:
  /// **'Sí, marcar'**
  String get yesMark;

  /// No description provided for @markAsDone.
  ///
  /// In es, this message translates to:
  /// **'Marcar como realizada'**
  String get markAsDone;

  /// No description provided for @deleteAppointmentClinicBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrará esta cita del historial. No se puede deshacer.'**
  String get deleteAppointmentClinicBody;

  /// No description provided for @patientsTitle.
  ///
  /// In es, this message translates to:
  /// **'Pacientes'**
  String get patientsTitle;

  /// No description provided for @patientsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los pacientes.'**
  String get patientsLoadError;

  /// No description provided for @noPatientsYetTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin pacientes aún'**
  String get noPatientsYetTitle;

  /// No description provided for @noPatientsYetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los propietarios que reserven citas aparecerán aquí.'**
  String get noPatientsYetSubtitle;

  /// No description provided for @searchPatientByName.
  ///
  /// In es, this message translates to:
  /// **'Buscar paciente por nombre'**
  String get searchPatientByName;

  /// No description provided for @noResultsForQuery.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\"'**
  String noResultsForQuery(String query);

  /// No description provided for @tryAnotherName.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre.'**
  String get tryAnotherName;

  /// No description provided for @lastAppointment.
  ///
  /// In es, this message translates to:
  /// **'Última cita · {date}'**
  String lastAppointment(String date);

  /// No description provided for @petsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get petsTitle;

  /// No description provided for @petsLoadErrorClinic.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las mascotas.'**
  String get petsLoadErrorClinic;

  /// No description provided for @noPetsRegisteredClinic.
  ///
  /// In es, this message translates to:
  /// **'Sin mascotas registradas'**
  String get noPetsRegisteredClinic;

  /// No description provided for @ownerNoPetsWithVisits.
  ///
  /// In es, this message translates to:
  /// **'Este propietario no tiene mascotas con visitas.'**
  String get ownerNoPetsWithVisits;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @clinicLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la clínica.'**
  String get clinicLoadError;

  /// No description provided for @clinicNotFoundShort.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la clínica.'**
  String get clinicNotFoundShort;

  /// No description provided for @historyLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el historial.'**
  String get historyLoadError;

  /// No description provided for @noVisitsWithPetTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin citas con esta mascota'**
  String get noVisitsWithPetTitle;

  /// No description provided for @noVisitsWithPetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las citas pendientes, confirmadas o realizadas aparecerán aquí para añadir notas.'**
  String get noVisitsWithPetSubtitle;

  /// No description provided for @clinicalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas clínicas'**
  String get clinicalNotes;

  /// No description provided for @clinicalNotesCount.
  ///
  /// In es, this message translates to:
  /// **'Notas clínicas ({count})'**
  String clinicalNotesCount(int count);

  /// No description provided for @addAnotherNote.
  ///
  /// In es, this message translates to:
  /// **'Añadir otra nota'**
  String get addAnotherNote;

  /// No description provided for @addClinicalNote.
  ///
  /// In es, this message translates to:
  /// **'Añadir nota clínica'**
  String get addClinicalNote;

  /// No description provided for @confirmAppointmentToAddNotes.
  ///
  /// In es, this message translates to:
  /// **'Confirma la cita en la agenda para poder añadir notas.'**
  String get confirmAppointmentToAddNotes;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar nota'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta nota clínica? No se puede deshacer.'**
  String get deleteNoteConfirm;

  /// No description provided for @editedOn.
  ///
  /// In es, this message translates to:
  /// **'Editado {date}'**
  String editedOn(String date);

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @newNote.
  ///
  /// In es, this message translates to:
  /// **'Nueva nota'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In es, this message translates to:
  /// **'Editar nota'**
  String get editNote;

  /// No description provided for @newNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes añadir varias notas por visita.'**
  String get newNoteHint;

  /// No description provided for @editNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Actualiza el texto de esta nota.'**
  String get editNoteHint;

  /// No description provided for @noteHintExample.
  ///
  /// In es, this message translates to:
  /// **'Ej. Revisión general, vacuna antirrábica aplicada…'**
  String get noteHintExample;

  /// No description provided for @saveNote.
  ///
  /// In es, this message translates to:
  /// **'Guardar nota'**
  String get saveNote;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @newborn.
  ///
  /// In es, this message translates to:
  /// **'recién nacido'**
  String get newborn;

  /// No description provided for @ageOneMonth.
  ///
  /// In es, this message translates to:
  /// **'1 mes'**
  String get ageOneMonth;

  /// No description provided for @myClinicTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi clínica'**
  String get myClinicTitle;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambios sin guardar'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesBody.
  ///
  /// In es, this message translates to:
  /// **'Has modificado el perfil o los horarios de la clínica sin guardar. ¿Qué deseas hacer?'**
  String get unsavedChangesBody;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @discardChanges.
  ///
  /// In es, this message translates to:
  /// **'Descartar cambios'**
  String get discardChanges;

  /// No description provided for @saveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveTooltip;

  /// No description provided for @schedulesLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar horarios: {error}'**
  String schedulesLoadError(String error);

  /// No description provided for @locationRegisteredSnack.
  ///
  /// In es, this message translates to:
  /// **'Ubicación registrada. Tu clínica ya aparecerá en búsquedas cercanas.'**
  String get locationRegisteredSnack;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileUpdated;

  /// No description provided for @profileSavedNoLocation.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado, pero no se pudo obtener la ubicación. Revisa dirección y ciudad (ej. \"Valdemoro\") y vuelve a guardar.'**
  String get profileSavedNoLocation;

  /// No description provided for @registeringLocation.
  ///
  /// In es, this message translates to:
  /// **'Registrando tu ubicación en el mapa…'**
  String get registeringLocation;

  /// No description provided for @locationBannerNeedsSave.
  ///
  /// In es, this message translates to:
  /// **'Tu clínica aún no tiene coordenadas GPS. Completa dirección y ciudad, luego pulsa Guardar para aparecer en búsquedas cercanas.'**
  String get locationBannerNeedsSave;

  /// No description provided for @locationBannerEnterCity.
  ///
  /// In es, this message translates to:
  /// **'Indica la ciudad (ej. Valdemoro) y la dirección para que los propietarios puedan encontrarte.'**
  String get locationBannerEnterCity;

  /// No description provided for @basicInformation.
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get basicInformation;

  /// No description provided for @clinicName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la clínica'**
  String get clinicName;

  /// No description provided for @address.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get address;

  /// No description provided for @city.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get city;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @contactEmail.
  ///
  /// In es, this message translates to:
  /// **'Email de contacto'**
  String get contactEmail;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get requiredField;

  /// No description provided for @loadingSpecialties.
  ///
  /// In es, this message translates to:
  /// **'Cargando especialidades…'**
  String get loadingSpecialties;

  /// No description provided for @appointmentDurationTitle.
  ///
  /// In es, this message translates to:
  /// **'Duración de las citas'**
  String get appointmentDurationTitle;

  /// No description provided for @appointmentDurationHelp.
  ///
  /// In es, this message translates to:
  /// **'Cada franja reservable tendrá esta duración. Los propietarios verán los horarios disponibles ajustados al guardar.'**
  String get appointmentDurationHelp;

  /// No description provided for @durationPerAppointment.
  ///
  /// In es, this message translates to:
  /// **'Duración por cita'**
  String get durationPerAppointment;

  /// No description provided for @weeklyHours.
  ///
  /// In es, this message translates to:
  /// **'Horarios semanales'**
  String get weeklyHours;

  /// No description provided for @closed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get closed;

  /// No description provided for @dayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get daySunday;

  /// No description provided for @durationMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} minutos'**
  String durationMinutes(int minutes);

  /// No description provided for @durationOneHour.
  ///
  /// In es, this message translates to:
  /// **'1 hora'**
  String get durationOneHour;

  /// No description provided for @durationOneHourThirty.
  ///
  /// In es, this message translates to:
  /// **'1 hora 30 min'**
  String get durationOneHourThirty;

  /// No description provided for @durationTwoHours.
  ///
  /// In es, this message translates to:
  /// **'2 horas'**
  String get durationTwoHours;

  /// No description provided for @durationHours.
  ///
  /// In es, this message translates to:
  /// **'{hours} horas'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int minutes, int hours);

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get termsOfServiceTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @onboardingGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get onboardingGotIt;

  /// No description provided for @onboardingOwnerSearchTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar clínicas'**
  String get onboardingOwnerSearchTitle;

  /// No description provided for @onboardingOwnerSearchDesc.
  ///
  /// In es, this message translates to:
  /// **'Busca por nombre, ciudad o dirección para encontrar veterinarios cerca de ti.'**
  String get onboardingOwnerSearchDesc;

  /// No description provided for @onboardingOwnerNearbyTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerca de mí'**
  String get onboardingOwnerNearbyTitle;

  /// No description provided for @onboardingOwnerNearbyDesc.
  ///
  /// In es, this message translates to:
  /// **'Usa tu ubicación para ver clínicas en mapa y lista, ordenadas por distancia.'**
  String get onboardingOwnerNearbyDesc;

  /// No description provided for @onboardingOwnerNavTitle.
  ///
  /// In es, this message translates to:
  /// **'Navegación'**
  String get onboardingOwnerNavTitle;

  /// No description provided for @onboardingOwnerNavDesc.
  ///
  /// In es, this message translates to:
  /// **'Desde aquí accedes a tus citas, mascotas y perfil. Registra tus mascotas antes de reservar una cita.'**
  String get onboardingOwnerNavDesc;

  /// No description provided for @onboardingClinicDashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen del día'**
  String get onboardingClinicDashboardTitle;

  /// No description provided for @onboardingClinicDashboardDesc.
  ///
  /// In es, this message translates to:
  /// **'Consulta las citas de hoy y un resumen de la actividad de tu clínica.'**
  String get onboardingClinicDashboardDesc;

  /// No description provided for @onboardingClinicQuickAccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get onboardingClinicQuickAccessTitle;

  /// No description provided for @onboardingClinicQuickAccessDesc.
  ///
  /// In es, this message translates to:
  /// **'Entra a la agenda para confirmar citas o a pacientes para ver expedientes médicos.'**
  String get onboardingClinicQuickAccessDesc;

  /// No description provided for @onboardingClinicNavTitle.
  ///
  /// In es, this message translates to:
  /// **'Navegación'**
  String get onboardingClinicNavTitle;

  /// No description provided for @onboardingClinicNavDesc.
  ///
  /// In es, this message translates to:
  /// **'Usa la barra inferior para ir a la agenda, pacientes y completar el perfil público de tu clínica.'**
  String get onboardingClinicNavDesc;

  /// No description provided for @settingsShowAppGuide.
  ///
  /// In es, this message translates to:
  /// **'Ver guía de la app'**
  String get settingsShowAppGuide;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
