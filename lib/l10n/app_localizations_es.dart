// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginWelcome => 'Bienvenido 👋';

  @override
  String get loginSubtitle => 'Inicia sesión en VetNow';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get loginErrorInvalidCredentials => 'Email o contraseña incorrectos';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get loginNoAccountRegister => '¿No tienes cuenta? Regístrate';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get registerClinicTitle => 'Registro de clínica';

  @override
  String get registerOwnerTitle => 'Registro de propietario';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get fillAllFields => 'Rellena todos los campos';

  @override
  String get registerMustAcceptLegal =>
      'Debes aceptar la política de privacidad y los términos';

  @override
  String registerError(String error) {
    return 'Error al registrarse: $error';
  }

  @override
  String get privacyPolicyLink => 'Política de Privacidad';

  @override
  String get termsAndConditionsLink => 'Términos y Condiciones';

  @override
  String get consentPrefix => 'He leído y acepto la ';

  @override
  String get roleSelectorTitle => '¿Cómo usarás VetNow?';

  @override
  String get selectYourProfile => 'Selecciona tu perfil';

  @override
  String get roleOwnerTitle => 'Soy propietario';

  @override
  String get roleOwnerSubtitle =>
      'Busco clínicas y reservo citas para mi mascota';

  @override
  String get roleClinicTitle => 'Soy clínica';

  @override
  String get roleClinicSubtitle => 'Gestiono mi agenda y recibo reservas';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get account => 'Cuenta';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get personalization => 'Personalización';

  @override
  String get privacyAndPolicy => 'Política y privacidad';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOutConfirmMessage => '¿Seguro que quieres cerrar sesión?';

  @override
  String signOutError(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get deleteAccountConfirmBody =>
      'Esta acción eliminará tus datos personales y cerrará tu sesión. No se puede deshacer.\n\n¿Deseas continuar?';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String deleteAccountError(String error) {
    return 'No se pudo eliminar la cuenta: $error';
  }

  @override
  String get appVersionLabel => 'App version: 5.271.0';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String get language => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get myPets => 'Mis mascotas';

  @override
  String get myAppointments => 'Mis citas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get saved => 'Guardados';

  @override
  String favoritesLoadError(String error) {
    return 'Error al cargar favoritos: $error';
  }

  @override
  String get noSavedClinicsTitle => 'No has guardado ninguna clínica';

  @override
  String get noSavedClinicsSubtitle =>
      'Cuando guardes clínicas con el corazón, las verás aquí';

  @override
  String get findClinics => 'Encontrar clínicas';

  @override
  String get personalData => 'Datos personales';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get phonePrefix => 'Prefijo';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get noChangesToSave => 'No hay cambios que guardar';

  @override
  String get dataSaved => 'Datos guardados';

  @override
  String saveError(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordUpdated => 'Contraseña actualizada';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get navSearch => 'Buscar';

  @override
  String get navAppointments => 'Citas';

  @override
  String get navPets => 'Mascotas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navClinicHome => 'Inicio';

  @override
  String get navClinicAgenda => 'Agenda';

  @override
  String get navClinicPatients => 'Pacientes';

  @override
  String get navMyClinic => 'Mi clínica';

  @override
  String get welcomeToVetNow => 'Bienvenido a VetNow';

  @override
  String welcomeToVetNowName(String name) {
    return 'Bienvenido a VetNow, $name!';
  }

  @override
  String get searchHintNameCityAddress =>
      'Buscar por nombre, ciudad o dirección';

  @override
  String get searchClinicsNearMe => 'Buscar clínicas cerca de mí';

  @override
  String get allSpecialties => 'Todas';

  @override
  String get favoriteClinics => 'Clínicas favoritas';

  @override
  String get noFavoriteClinicsTitle => 'Todavía no tienes clínicas favoritas';

  @override
  String get noFavoriteClinicsSubtitle =>
      'Explora y pulsa el corazón en cualquier clínica para añadirla aquí.';

  @override
  String get upcomingAppointments => 'Próximas citas';

  @override
  String get noScheduledAppointmentsTitle => 'No tienes citas programadas';

  @override
  String get noScheduledAppointmentsSubtitle =>
      'Reserva una cita y aparecerá aquí.';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get locationDisabledTitle => 'Ubicación desactivada';

  @override
  String get locationDisabledMessage =>
      'Activa el servicio de ubicación de tu dispositivo para ver las clínicas cercanas.';

  @override
  String get locationPermissionTitle => 'Permiso de ubicación necesario';

  @override
  String get locationPermissionMessage =>
      'Para mostrarte las clínicas más cercanas necesitamos acceder a tu ubicación. Actívala en los ajustes de la app.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String locationFetchError(String error) {
    return 'No se pudo obtener tu ubicación: $error';
  }

  @override
  String get searchClinicsTitle => 'Buscar clínicas';

  @override
  String get searchHintShort => 'Nombre, ciudad o dirección';

  @override
  String get searchTypeToSeeResults =>
      'Escribe para ver clínicas que coincidan';

  @override
  String searchNoClinicsForQuery(String query) {
    return 'No hay clínicas para \"$query\"';
  }

  @override
  String get searchTryAnotherQuery =>
      'Prueba con otro nombre, ciudad o dirección';

  @override
  String get clinicNotFound => 'Clínica no encontrada';

  @override
  String get aboutUs => 'Sobre nosotros';

  @override
  String get specialties => 'Especialidades';

  @override
  String get clinicNoSpecialtiesConfigured =>
      'Esta clínica no tiene especialidades configuradas';

  @override
  String get bookAppointment => 'Reservar cita';

  @override
  String get selectSpecialty => 'Selecciona especialidad';

  @override
  String get nearbyClinicsTitle => 'Clínicas cercanas';

  @override
  String get viewOnMap => 'Ver en el mapa';

  @override
  String noClinicsWithinRadius(String km) {
    return 'No hay clínicas en $km km';
  }

  @override
  String get nearbyTryOtherSpecialty =>
      'Prueba con otra especialidad o amplía el radio de búsqueda.';

  @override
  String get nearbyNeedsGps =>
      'Las clínicas necesitan tener su ubicación GPS registrada para aparecer aquí.';

  @override
  String nearbyClinicsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clínicas cerca de ti',
      one: '1 clínica cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String get appointmentsTitle => 'Citas';

  @override
  String get petFilterLabel => 'Mascota';

  @override
  String get allPets => 'Todas las mascotas';

  @override
  String get petsLoadError => 'No se pudieron cargar mascotas';

  @override
  String tabScheduled(int count) {
    return 'Programadas ($count)';
  }

  @override
  String tabCompleted(int count) {
    return 'Realizadas ($count)';
  }

  @override
  String tabCancelled(int count) {
    return 'Canceladas ($count)';
  }

  @override
  String get noCompletedAppointmentsTitle => 'No tienes citas realizadas';

  @override
  String get completedAppointmentsSubtitle =>
      'Aquí verás el historial de tus visitas.';

  @override
  String get noCancelledAppointmentsTitle => 'No tienes citas canceladas';

  @override
  String get statusDone => 'Realizada';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get cancelAppointment => 'Cancelar cita';

  @override
  String get cancelAppointmentConfirm =>
      '¿Seguro que quieres cancelar esta cita?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Sí, cancelar';

  @override
  String get deleteAppointment => 'Eliminar cita';

  @override
  String get deleteAppointmentConfirm =>
      'Se borrará esta cita de tu historial. No se puede deshacer.';

  @override
  String get yesDelete => 'Sí, eliminar';

  @override
  String get delete => 'Eliminar';

  @override
  String deleteFailed(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get bookAppointmentTitle => 'Reservar cita';

  @override
  String bookingError(String error) {
    return 'Error al reservar: $error';
  }

  @override
  String get appointmentBookedTitle => '¡Cita reservada!';

  @override
  String appointmentBookedBody(String date) {
    return '$date';
  }

  @override
  String get viewMyAppointments => 'Ver mis citas';

  @override
  String get clinicNoAppointmentsYetTitle =>
      'Esta clínica no acepta citas todavía';

  @override
  String get clinicNoSchedulesSubtitle =>
      'La clínica aún no ha configurado sus horarios de atención.';

  @override
  String get back => 'Volver';

  @override
  String get noSlotsThatDay => 'No hay horarios disponibles ese día';

  @override
  String get chooseAnotherDate => 'Elegir otra fecha';

  @override
  String get selectTime => 'Selecciona una hora';

  @override
  String get bookingPetQuestion => '¿Para qué mascota es la cita?';

  @override
  String get noPetsRegistered => 'No tienes mascotas registradas';

  @override
  String get addPet => 'Añadir mascota';

  @override
  String get appointmentSummary => 'Resumen de la cita';

  @override
  String get clinicLabel => 'Clínica';

  @override
  String get specialtyLabel => 'Especialidad';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get timeLabel => 'Hora';

  @override
  String get petLabel => 'Mascota';

  @override
  String get confirmBooking => 'Confirmar reserva';

  @override
  String bookingContinueWithDate(String date) {
    return 'Continuar con el $date';
  }

  @override
  String get weekdayLetters => 'D,L,M,X,J,V,S';

  @override
  String get myPetsTitle => 'Mis mascotas';

  @override
  String get noPetsYetTitle => 'Aún no has añadido mascotas';

  @override
  String get noPetsYetSubtitle => 'Añade a tu mascota para gestionar sus citas';

  @override
  String get uploadingPhoto => 'Subiendo foto…';

  @override
  String get tapToAddPhoto => 'Toca para añadir o cambiar foto';

  @override
  String get takePhoto => 'Hacer foto';

  @override
  String get chooseFromGallery => 'Elegir de galería';

  @override
  String get removeProfilePhoto => 'Quitar foto de perfil';

  @override
  String get editPetTooltip => 'Editar mascota';

  @override
  String get deletePetTitle => 'Eliminar mascota';

  @override
  String deletePetConfirm(String name) {
    return '¿Seguro que quieres eliminar a $name?';
  }

  @override
  String get newPet => 'Nueva mascota';

  @override
  String get editPet => 'Editar mascota';

  @override
  String get nameRequired => 'Nombre *';

  @override
  String get nameRequiredError => 'El nombre es obligatorio';

  @override
  String get species => 'Especie';

  @override
  String get breedOptional => 'Raza (opcional)';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get birthDateOptional => 'Fecha de nacimiento (opcional)';

  @override
  String get savePet => 'Guardar mascota';

  @override
  String get ageLessThanOneMonth => 'Menos de 1 mes';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String get ageOneYear => '1 año';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get speciesDog => 'Perro';

  @override
  String get speciesCat => 'Gato';

  @override
  String get speciesRabbit => 'Conejo';

  @override
  String get speciesHamster => 'Hámster';

  @override
  String get speciesBird => 'Ave';

  @override
  String get speciesReptile => 'Reptil';

  @override
  String get speciesFerret => 'Hurón';

  @override
  String get speciesOther => 'Otro';

  @override
  String get myClinicFallback => 'Mi clínica';

  @override
  String get today => 'Hoy';

  @override
  String get completeYourProfile => 'Completa tu perfil';

  @override
  String get completeProfileBannerBody =>
      'Los propietarios podrán encontrarte cuando completes los datos de tu clínica.';

  @override
  String get complete => 'Completar';

  @override
  String get todayPatients => 'Pacientes de hoy';

  @override
  String get pendingYourConfirmation => 'Pendiente de tu confirmación';

  @override
  String appointmentsAwaitingConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas esperando confirmación',
      one: '1 cita esperando confirmación',
    );
    return '$_temp0';
  }

  @override
  String get acceptOrRejectFromAgenda => 'Acepta o rechaza desde la agenda';

  @override
  String get activitySummary => 'Resumen de actividad';

  @override
  String get quickAccess => 'Acceso rápido';

  @override
  String get manageYourAppointments => 'Gestiona tus citas';

  @override
  String get medicalRecords => 'Expedientes médicos';

  @override
  String get confirmedAppointmentsToday => 'citas confirmadas hoy';

  @override
  String get noAppointmentsTodayEnjoy => 'Sin citas para hoy. Disfruta el día.';

  @override
  String get nextAppointment => 'Próxima cita';

  @override
  String get nextAppointments => 'Próximas citas';

  @override
  String get viewFullAgenda => 'Ver agenda completa';

  @override
  String get appointmentsOverview => 'Vista general de tus citas';

  @override
  String get viewAgenda => 'Ver agenda';

  @override
  String get scheduled => 'Programadas';

  @override
  String get statConfirmed => 'Confirmadas';

  @override
  String get statCompleted => 'Realizadas';

  @override
  String get toConfirm => 'Por confirmar';

  @override
  String confirmedPatientsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacientes confirmados hoy',
      one: '1 paciente confirmado hoy',
    );
    return '$_temp0';
  }

  @override
  String get thisWeek => 'Esta semana';

  @override
  String cancelledThisWeek(int count) {
    return '$count canceladas esta semana';
  }

  @override
  String cancelledToday(int count) {
    return '$count canceladas hoy';
  }

  @override
  String totalAwaitingConfirmation(int count) {
    return '$count en total esperando tu confirmación';
  }

  @override
  String get noConfirmedPatientsToday =>
      'Ningún paciente con cita confirmada para hoy.';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get clinicProfileNotFound => 'No se encontró el perfil de clínica.';

  @override
  String get dateFilter => 'Fecha';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get allAppointments => 'Todas las citas';

  @override
  String tabPending(int count) {
    return 'Pendientes ($count)';
  }

  @override
  String tabConfirmedCount(int count) {
    return 'Confirmadas ($count)';
  }

  @override
  String get noPendingAppointments => 'No hay citas pendientes';

  @override
  String get newBookingsAppearHere => 'Las nuevas reservas aparecerán aquí.';

  @override
  String get noConfirmedAppointments => 'No hay citas confirmadas';

  @override
  String get noCompletedAppointmentsClinic => 'No hay citas realizadas';

  @override
  String get noCancelledAppointmentsClinic => 'No hay citas canceladas';

  @override
  String get confirmAppointment => 'Confirmar cita';

  @override
  String get confirmAppointmentBody =>
      '¿Confirmas esta cita? El propietario verá el estado actualizado.';

  @override
  String get yesConfirm => 'Sí, confirmar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get denyAppointment => 'Denegar cita';

  @override
  String get denyAppointmentBody =>
      'La cita quedará cancelada y el propietario verá el cambio.';

  @override
  String get yesDeny => 'Sí, denegar';

  @override
  String get deny => 'Denegar';

  @override
  String get markAsDoneTitle => 'Marcar como realizada';

  @override
  String get markAsDoneBody => '¿Marcar esta cita como realizada?';

  @override
  String get yesMark => 'Sí, marcar';

  @override
  String get markAsDone => 'Marcar como realizada';

  @override
  String get deleteAppointmentClinicBody =>
      'Se borrará esta cita del historial. No se puede deshacer.';

  @override
  String get patientsTitle => 'Pacientes';

  @override
  String get patientsLoadError => 'No se pudieron cargar los pacientes.';

  @override
  String get noPatientsYetTitle => 'Sin pacientes aún';

  @override
  String get noPatientsYetSubtitle =>
      'Los propietarios que reserven citas aparecerán aquí.';

  @override
  String get searchPatientByName => 'Buscar paciente por nombre';

  @override
  String noResultsForQuery(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get tryAnotherName => 'Prueba con otro nombre.';

  @override
  String lastAppointment(String date) {
    return 'Última cita · $date';
  }

  @override
  String get petsTitle => 'Mascotas';

  @override
  String get petsLoadErrorClinic => 'No se pudieron cargar las mascotas.';

  @override
  String get noPetsRegisteredClinic => 'Sin mascotas registradas';

  @override
  String get ownerNoPetsWithVisits =>
      'Este propietario no tiene mascotas con visitas.';

  @override
  String get history => 'Historial';

  @override
  String get clinicLoadError => 'Error al cargar la clínica.';

  @override
  String get clinicNotFoundShort => 'No se encontró la clínica.';

  @override
  String get historyLoadError => 'No se pudo cargar el historial.';

  @override
  String get noVisitsWithPetTitle => 'Sin citas con esta mascota';

  @override
  String get noVisitsWithPetSubtitle =>
      'Las citas pendientes, confirmadas o realizadas aparecerán aquí para añadir notas.';

  @override
  String get clinicalNotes => 'Notas clínicas';

  @override
  String clinicalNotesCount(int count) {
    return 'Notas clínicas ($count)';
  }

  @override
  String get addAnotherNote => 'Añadir otra nota';

  @override
  String get addClinicalNote => 'Añadir nota clínica';

  @override
  String get confirmAppointmentToAddNotes =>
      'Confirma la cita en la agenda para poder añadir notas.';

  @override
  String get deleteNoteTitle => 'Eliminar nota';

  @override
  String get deleteNoteConfirm =>
      '¿Seguro que quieres eliminar esta nota clínica? No se puede deshacer.';

  @override
  String editedOn(String date) {
    return 'Editado $date';
  }

  @override
  String get edit => 'Editar';

  @override
  String get newNote => 'Nueva nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get newNoteHint => 'Puedes añadir varias notas por visita.';

  @override
  String get editNoteHint => 'Actualiza el texto de esta nota.';

  @override
  String get noteHintExample =>
      'Ej. Revisión general, vacuna antirrábica aplicada…';

  @override
  String get saveNote => 'Guardar nota';

  @override
  String get retry => 'Reintentar';

  @override
  String get newborn => 'recién nacido';

  @override
  String get ageOneMonth => '1 mes';

  @override
  String get myClinicTitle => 'Mi clínica';

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get unsavedChangesBody =>
      'Has modificado el perfil o los horarios de la clínica sin guardar. ¿Qué deseas hacer?';

  @override
  String get save => 'Guardar';

  @override
  String get discardChanges => 'Descartar cambios';

  @override
  String get saveTooltip => 'Guardar';

  @override
  String schedulesLoadError(String error) {
    return 'Error al cargar horarios: $error';
  }

  @override
  String get locationRegisteredSnack =>
      'Ubicación registrada. Tu clínica ya aparecerá en búsquedas cercanas.';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileSavedNoLocation =>
      'Perfil guardado, pero no se pudo obtener la ubicación. Revisa dirección y ciudad (ej. \"Valdemoro\") y vuelve a guardar.';

  @override
  String get registeringLocation => 'Registrando tu ubicación en el mapa…';

  @override
  String get locationBannerNeedsSave =>
      'Tu clínica aún no tiene coordenadas GPS. Completa dirección y ciudad, luego pulsa Guardar para aparecer en búsquedas cercanas.';

  @override
  String get locationBannerEnterCity =>
      'Indica la ciudad (ej. Valdemoro) y la dirección para que los propietarios te encuentren cerca.';

  @override
  String get basicInformation => 'Información básica';

  @override
  String get clinicName => 'Nombre de la clínica';

  @override
  String get address => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get phone => 'Teléfono';

  @override
  String get contactEmail => 'Email de contacto';

  @override
  String get description => 'Descripción';

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get loadingSpecialties => 'Cargando especialidades…';

  @override
  String get appointmentDurationTitle => 'Duración de las citas';

  @override
  String get appointmentDurationHelp =>
      'Cada franja reservable tendrá esta duración. Los propietarios verán los horarios disponibles ajustados al guardar.';

  @override
  String get durationPerAppointment => 'Duración por cita';

  @override
  String get weeklyHours => 'Horarios semanales';

  @override
  String get closed => 'Cerrado';

  @override
  String get dayMonday => 'Lunes';

  @override
  String get dayTuesday => 'Martes';

  @override
  String get dayWednesday => 'Miércoles';

  @override
  String get dayThursday => 'Jueves';

  @override
  String get dayFriday => 'Viernes';

  @override
  String get daySaturday => 'Sábado';

  @override
  String get daySunday => 'Domingo';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get durationOneHour => '1 hora';

  @override
  String get durationOneHourThirty => '1 hora 30 min';

  @override
  String get durationTwoHours => '2 horas';

  @override
  String durationHours(int hours) {
    return '$hours horas';
  }

  @override
  String durationHoursMinutes(int minutes, int hours) {
    return '$hours h $minutes min';
  }

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get termsOfServiceTitle => 'Términos y condiciones';
}
