# VetNow — Documento de Contexto Técnico

> Stack: Flutter + Supabase.

---

## 1. Objetivo del Proyecto

VetNow es una aplicación móvil multiplataforma (Android + iOS) que actúa como
plataforma intermediaria entre propietarios de mascotas y clínicas veterinarias
en España. El concepto es equivalente a Doctoralia pero orientado al sector
veterinario.

**Propuesta de valor:**
- El propietario puede buscar clínicas por ciudad y especialidad, ver su perfil,
  registrar sus mascotas y reservar citas de forma inmediata sin llamadas.
- La clínica puede gestionar su perfil público, ver y confirmar citas recibidas,
  gestionar expedientes médicos de sus pacientes y ganar visibilidad digital.

---

## 2. Arquitectura y Stack Tecnológico

### Frontend
- **Framework:** Flutter (Dart)
- **Gestión de estado:** Riverpod (flutter_riverpod + riverpod_annotation)
- **Navegación:** go_router con ShellRoute para bottom navigation
- **Internacionalización:** `flutter gen-l10n` (español / inglés), ARB en `lib/l10n/`
- **Geolocalización y mapas:** `geolocator`, `flutter_map`, `latlong2`
- **Persistencia local:** `shared_preferences` (idioma preferido)

### Backend
- **Plataforma:** Supabase (BaaS)
  - Auth: email/password con roles custom en tabla profiles
  - Base de datos: PostgreSQL con RLS activado en todas las tablas
  - Edge Functions: Deno (TypeScript) para recordatorios y notificaciones de email
  - Storage: buckets `clinic-logos` (logos de clínica) y `pet-photos` (fotos de mascotas)
- **Email:** Resend API (integrado en Edge Functions)
- **Geocodificación externa:** OpenStreetMap Nominatim (solo al guardar perfil de clínica)

### Estructura de carpetas Flutter

```
lib/
├── main.dart
├── l10n/                          # Generado + ARB (app_es.arb, app_en.arb)
│   ├── app_localizations.dart
│   ├── l10n_ext.dart              # extension context.l10n
│   └── ...
├── app/
│   ├── app.dart                   # MaterialApp con locale, themeMode, l10n delegates
│   ├── router.dart
│   ├── main_shell.dart
│   └── theme.dart                 # AppTheme.light + AppTheme.dark
├── core/
│   ├── supabase/supabase_client.dart
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   └── locale_provider.dart   # Locale persistido en SharedPreferences
│   ├── datetime/
│   │   ├── timestamptz.dart
│   │   └── app_date_format.dart   # Patrones DateFormat según locale
│   ├── errors/                    # Errores amigables (mapError, AppErrorCode, l10n)
│   ├── location/
│   │   └── user_location_service.dart  # GPS con caché lastKnown (15 min)
│   └── strings/search_text.dart   # Búsqueda sin tildes (normalizeForSearch)
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── providers/auth_provider.dart
│   │   └── ui/  login | register | role_selector
│   ├── clinic/                    # Buscador (rol owner)
│   │   ├── data/clinic_repository.dart
│   │   ├── providers/clinic_provider.dart
│   │   └── ui/
│   │       ├── search_screen.dart           # Hub: favoritos, próxima cita, Cerca de mí
│   │       ├── clinic_text_search_screen.dart
│   │       ├── nearby_screen.dart           # Mapa + lista por proximidad
│   │       ├── clinic_detail_screen.dart
│   │       ├── clinic_map_screen.dart       # Mapa clínica + ubicación usuario
│   │       ├── favorite_clinics_screen.dart # Lista completa de favoritos
│   │       └── clinic_list_card.dart
│   ├── appointment/
│   │   ├── data/appointment_repository.dart
│   │   ├── providers/appointment_provider.dart
│   │   ├── utils/slot_generator.dart
│   │   └── ui/  appointments_screen | booking_screen
│   ├── pet/
│   │   ├── data/pet_repository.dart
│   │   ├── providers/pet_provider.dart
│   │   └── ui/  pets_screen
│   ├── profile/
│   │   └── ui/
│   │       ├── profile_screen.dart
│   │       ├── settings_screen.dart
│   │       ├── account_screen.dart
│   │       ├── personalization_screen.dart  # Modo oscuro + idioma
│   │       ├── legal_text_screen.dart
│   │       └── legal_routes.dart
│   └── clinic_panel/              # Panel clínica — COMPLETO
│       ├── data/medical_notes_repository.dart
│       ├── providers/clinic_panel_provider.dart
│       └── ui/
│           ├── clinic_home_screen.dart
│           ├── clinic_agenda_screen.dart
│           ├── clinic_patients_screen.dart
│           ├── clinic_profile_menu_screen.dart  # Hub "Mi clínica"
│           ├── clinic_profile_screen.dart       # Formulario de edición (ClinicProfileEditScreen)
│           └── clinic_settings_screen.dart      # Ajustes de cuenta para rol clinic
└── shared/
    ├── appointment_duration.dart  # Constantes y etiquetas de duración
    ├── models/
    │   ├── profile.dart           # + privacyAcceptedAt, termsAcceptedAt
    │   ├── clinic.dart            # + appointmentDurationMinutes, distanceKm, haversineKm
    │   ├── specialty.dart
    │   ├── schedule.dart
    │   ├── pet.dart
    │   ├── appointment.dart
    │   └── medical_note.dart
    ├── widgets/
    │   ├── app_error_banner.dart    # Error inline en formularios
    │   └── app_error_snackbar.dart  # showAppError para acciones async
    └── legal/
        ├── legal_texts.dart
        └── legal_texts_en.dart

supabase/
├── migrations/                    # SQL versionado (RLS, RPC, buckets, etc.)
└── functions/
    ├── send-appointment-reminders/
    └── send-appointment-notification/
```

### Esquema de Base de Datos (Supabase / PostgreSQL)

```sql
profiles          -- Extiende auth.users. role, full_name, phone, avatar_url,
                  -- privacy_accepted_at, terms_accepted_at
specialties       -- Catálogo fijo. 7 registros seed insertados.
clinics           -- profile_id FK, datos públicos, lat/lng, appointment_duration_minutes
clinic_specialties-- Relación N:M clínicas ↔ especialidades.
clinic_favorites  -- owner_id + clinic_id (PK compuesta). Favoritos del propietario.
schedules         -- Horarios semanales (day_of_week, open_time, close_time).
pets              -- owner_id FK, name, species, breed, birth_date, photo_url.
appointments      -- clinic_id, pet_id, owner_id, specialty_id, scheduled_at,
                  -- status, reminder_sent, duration_minutes, completed_at, notes.
medical_notes     -- appointment_id FK, clinic_id FK, content, created_at, updated_at.
                  -- Varias notas por cita (sin UNIQUE en appointment_id).
```

**RPC functions:**
- `get_booked_slots(p_clinic_id, p_from, p_to)` — SECURITY DEFINER. Devuelve
  `(scheduled_at, duration_minutes)` de citas con status `pending` o `confirmed`.
  Permite detectar solapamientos cuando la duración de la cita es > 30 min.
- `complete_past_appointments()` — SECURITY DEFINER. Marca como `done` las citas
  `confirmed` cuyo fin (`scheduled_at` + duración) ya pasó y rellena `completed_at = now()`.
  Se invoca desde Flutter al cargar citas del propietario.
- Trigger `on_auth_user_created` → `handle_new_user()`: crea fila en `profiles` desde
  `raw_user_meta_data` (`role`, `full_name`) al registrarse en Auth.

**Storage buckets:**
- `clinic-logos` — logo por clínica (`{clinicId}/logo.{ext}`)
- `pet-photos` — foto por mascota (`{ownerId}/{petId}.{ext}`), lectura pública

**RLS activada en todas las tablas.** Políticas clave:
- `clinics`: lectura pública, escritura solo profile_id dueño.
- `pets`: solo el owner ve/edita las suyas; la clínica puede leer datos de mascotas
  vinculadas a sus citas (política adicional para agenda/expedientes).
- `appointments`: owner ve las suyas, clínica ve las de su clinic_id.
- `specialties` y `clinic_specialties`: lectura pública (crítico para joins).
- `medical_notes`: solo la clínica dueña puede leer/escribir.
- `clinic_favorites`: solo el owner autenticado gestiona sus filas.

### Navegación (router.dart)

```
/login              → LoginScreen         (sin shell)
/role-selector      → RoleSelectorScreen  (sin shell)
/register/:role     → RegisterScreen      (sin shell, rol por path param: owner|clinic)
/legal/privacy      → LegalPrivacyRoute   (público, sin login)
/legal/terms        → LegalTermsRoute     (público, sin login)
/auth-resolve       → Spinner             (sin shell, mientras profileProvider carga)

ShellRoute → MainShell (bottom nav dinámico por rol)
  /search                              → SearchScreen (hub)
  /search/favorites                    → FavoriteClinicsScreen (título: favoriteClinics)
  /search/query                        → ClinicTextSearchScreen
  /search/nearby                       → NearbyScreen (extra: lat, lng)
  /search/clinic/:id                   → ClinicDetailScreen
  /search/clinic/:id/map               → ClinicMapScreen (extra: clinicLat, clinicLng, clinicName)
  /search/clinic/:id/book              → BookingScreen (extra: Specialty)
  /appointments                        → AppointmentsScreen
  /pets                                → PetsScreen
  /profile                             → ProfileScreen
  /profile/favorites                   → FavoriteClinicsScreen (título: saved)
  /profile/settings                    → SettingsScreen
  /profile/settings/account            → AccountScreen
  /profile/settings/personalization    → PersonalizationScreen
  /clinic-home                         → ClinicHomeScreen
  /clinic-agenda                       → ClinicAgendaScreen (extra: initialTabIndex)
  /clinic-patients                     → ClinicPatientsScreen
  /clinic-patients/:ownerId            → OwnerPetsScreen (extra: ownerName)
  /clinic-patients/:ownerId/:petId     → PetVisitsScreen (extra: petName)
  /clinic-profile                      → ClinicProfileMenuScreen
  /clinic-profile/edit                 → ClinicProfileEditScreen
  /clinic-profile/settings             → ClinicSettingsScreen
  /clinic-profile/settings/account     → AccountScreen
  /clinic-profile/settings/personalization → PersonalizationScreen
```

**Redirección por rol en login:**
- role == 'owner'  → /search
- role == 'clinic' → /clinic-home

**Protección cruzada de rutas:** un rol no puede acceder a rutas del otro.
Mientras `profileProvider` carga → `/auth-resolve`.
Rutas legales accesibles sin sesión.
Las rutas `/register/*` quedan fuera del redirect del router (gestionan su propia
navegación tras signUp, evita races con signIn en email duplicado).

---

## 3. Estado Actual — Qué está hecho

### ✅ Auth (Fase 0 — completa)
- Registro con selección de rol (owner / clinic) mediante RoleSelectorScreen.
- Login con redirección automática según rol leído de tabla profiles.
- Logout funcional desde perfil (ambos roles).
- Provider `profileProvider` disponible globalmente vía Riverpod.
- Registro con aceptación obligatoria de privacidad y términos (`privacy_accepted_at`,
  `terms_accepted_at` en `profiles`).
- Enlaces a `/legal/privacy` y `/legal/terms` desde el formulario de registro.
- `RegisterException` con mensajes localizados para email ya registrado o contraseña
  incorrecta en cuenta existente.
- `signUp` envía `user_metadata` (`role`, `full_name`); trigger `handle_new_user` crea
  perfil en BD; si ya existe fila del trigger, se hace `UPDATE` con el rol elegido.
- Cuenta ya registrada se detecta por `privacy_accepted_at != null` (no solo existencia de fila).
- Registro **clínica** exige nombre de clínica y teléfono; crea fila en `clinics` con esos datos.
- Errores de registro vía `mapError` + `AppErrorBanner` (sin `e.toString()` en UI).

### ✅ Búsqueda de clínicas (Fase 1 — completa, ampliada en Fase 7)
- **SearchScreen** actúa como hub de inicio: saludo personalizado, barra que abre
  búsqueda en vivo, botón "Cerca de mí", sección de clínicas favoritas y resumen
  de próxima cita.
- **ClinicTextSearchScreen** (`/search/query`): búsqueda en vivo con debounce 300 ms
  por nombre, ciudad o dirección; filtro de especialidad opcional; normalización
  sin tildes vía `search_text.dart`.
- **NearbyScreen** (`/search/nearby`): obtiene GPS con `geolocator`, muestra mapa
  (`flutter_map`) y lista ordenada por distancia (Haversine, radio por defecto 10 km).
  Filtro por especialidad con chips.
- ClinicDetailScreen con SliverAppBar, info, especialidades, botón reservar,
  **toggle de favorito** (corazón) y enlace a mapa (`/search/clinic/:id/map`) si hay lat/lng.
- **FavoriteClinicsScreen**: lista completa en `/search/favorites` y `/profile/favorites`
  (mismo widget, títulos distintos: "Clínicas favoritas" / "Guardados").
- SearchScreen y ProfileScreen muestran preview de hasta 3 favoritos con "Ver más".
- **ClinicMapScreen**: mapa centrado en la clínica con marcador del usuario si hay GPS.
- **UserLocationService** (`resolveUserLocation`): usa `lastKnownPosition` (≤15 min) antes
  que GPS en vivo; usado en SearchScreen ("Cerca de mí") y ClinicMapScreen.
- Resolución del bug de RLS en joins anidados (specialties pública).

### ✅ Flujo de reserva de citas — propietario (Fase 2 — completa)
- BookingScreen con 4 pasos: fecha → hora → mascota → confirmación.
- Calendario custom que bloquea fechas pasadas y días sin horario en `schedules`.
- Slots generados con `slot_generator.dart` según horario del día y **duración
  configurada por la clínica** (30 / 45 / 60 / 90 / 120 min).
- Slots ocupados vía RPC `get_booked_slots`; detección de **solapamiento** con
  `isSlotBlocked` (cada cita reservada ocupa su duración completa).
- Al crear cita se guarda `duration_minutes` copiado de la clínica.
- Dialog de éxito con fecha formateada según locale (`app_date_format.dart`).
- Cancelación de cita con dialog de confirmación.
- AppointmentsScreen con 3 tabs y contadores reales.
- Al cargar citas del propietario se llama a `complete_past_appointments` (RPC).

### ✅ Gestión de mascotas — propietario (Fase 3 — completa)
- PetsScreen con lista, estado vacío y FAB.
- _AddPetSheet / edición: 8 especies con emojis, raza y fecha opcionales.
- **Foto de mascota:** cámara o galería → bucket `pet-photos` → `photo_url` en BD.
- Cálculo de edad automático en la tarjeta.
- Eliminación con dialog de confirmación.

### ✅ Recordatorio por email (Fase 4 — completa)
- Edge Function `send-appointment-reminders` + cron `pg_cron` cada hora.
- Limitación Resend en modo pruebas (dominio propio para producción).

### ✅ NavBar dinámico por rol y panel clínica (Fase 5 — completa)
- MainShell con NavBar por rol; spinner mientras carga perfil.
- Al salir de **Mi clínica** con cambios sin guardar, `clinicProfileExitHandlerProvider`
  intercepta el tap en otras tabs del NavBar.
- ClinicHomeScreen, ClinicAgendaScreen, ClinicPatientsScreen + expedientes médicos
  (varias notas por visita) y flujo completo de Mi Clínica.

#### ClinicHomeScreen (dashboard ampliado)
- Resumen del día: citas pendientes/confirmadas, carrusel de pacientes confirmados.
- Tarjeta de citas pendientes de confirmación con enlace a agenda.
- **Resumen de actividad** (`clinicAppointmentStatsProvider`): métricas de hoy y de la
  semana en curso; citas realizadas hoy por `completed_at` (fallback `scheduled_at`).
- Accesos rápidos a Agenda y Pacientes; pull-to-refresh.

#### Flujo Mi Clínica (refactor)
- `ClinicProfileMenuScreen` pasa a ser la entrada de `/clinic-profile` con accesos
  a Agenda, Pacientes, Editar clínica y Ajustes.
- `ClinicProfileEditScreen` (archivo `clinic_profile_screen.dart`) queda dedicado
  al formulario de edición de datos de clínica.
- `ClinicSettingsScreen` centraliza ajustes del rol clínica: cuenta, legal,
  personalización, cerrar sesión y eliminar cuenta.
- Esto unifica la experiencia del rol clínica con el patrón de ajustes del owner.

### ✅ Ajustes de cuenta y personalización (Fase 6 — completa)
- SettingsScreen, AccountScreen (teléfono, contraseña, borrar cuenta).
- PersonalizationScreen: **modo oscuro** (`AppTheme.dark`) e **idioma** (es/en)
  persistido con `localeProvider` + SharedPreferences.

### ✅ Notificaciones de email por acción de clínica (Fase 6 — completa)
- Edge Function `send-appointment-notification` tras confirmar o denegar cita.

### ✅ Internacionalización (Fase 7 — completa)
- Textos de UI en español e inglés (`AppLocalizations`, ARB).
- `context.l10n` en pantallas; fechas con patrones por locale en `app_date_format.dart`.
- `initializeDateFormatting` para `es` y `en` en `main()`.
- Idioma cambiable en PersonalizationScreen sin reiniciar la app.

### ✅ Favoritos, proximidad y geocodificación (Fase 7 — completa)
- Tabla `clinic_favorites` y CRUD en `ClinicRepository`.
- Providers `favoriteClinicIdsProvider` y `favoriteClinicsProvider`.
- Lista de favoritos en SearchScreen; corazón en ClinicDetailScreen.
- Columnas `lat` / `lng` en `clinics` + índice espacial básico.
- Geocodificación al guardar perfil de clínica (Nominatim, España); reintento
  automático al cambiar dirección/ciudad en ClinicProfileEditScreen.
- `Clinic.distanceKm` calculado en cliente para resultados cercanos.

### ✅ Duración de cita configurable (Fase 8 — completa)
- `clinics.appointment_duration_minutes` (30, 45, 60, 90, 120).
- `appointments.duration_minutes` al reservar.
- Selector en ClinicProfileEditScreen; slots y solapamientos respetan la duración.
- RPC `complete_past_appointments` usa la duración real de cada cita.

### ✅ Errores amigables en UI (Fase 9 — completa)
- Módulo `lib/core/errors/`: `AppError`, `AppErrorCode`, `mapError`, `appErrorMessage`.
- `mapError` traduce `AuthException`, `PostgrestException`, `SocketException`,
  `RegisterException`, timeouts de ubicación, etc.
- `AppErrorBanner` para formularios; `showAppError` / `logAppError` en `app_error_presenter.dart`.
- Widgets en `shared/widgets/`. Regla: no mostrar mensajes técnicos al usuario.

### ✅ Citas realizadas y UX ampliada (Fase 9 — completa)
- Columna `appointments.completed_at`: se rellena al marcar realizada desde agenda
  (`markAppointmentDone`) o al auto-completar vía RPC.
- Modelo `Appointment` incluye `completedAt`, `clinicPhone`, foto/especie de mascota en joins.
- `computeClinicAppointmentStats` agrega contadores semanales y `uniquePatientsToday`.

---

## 4. Reglas de Negocio y Peculiaridades Importantes

### Roles y acceso
- El rol se guarda en `profiles.role` como TEXT ('owner' | 'clinic').
- El enum Dart es `UserRole { owner, clinic }`.
- **Una cuenta no puede cambiar de rol.** No hay UI para ello.
- Router con protección cruzada y `/auth-resolve` mientras carga el perfil.
- Rutas `/legal/*` públicas (registro y consulta sin sesión).

### Slots de cita
- Slots generados en cliente con `generateSlotsForDate` y paso = duración de la clínica.
- Horarios desde tabla `schedules`; día sin horario → sin slots y día bloqueado.
- Ocupación: RPC `get_booked_slots` devuelve inicio + duración; `isSlotBlocked`
  comprueba solapamiento de intervalos (no solo coincidencia exacta de hora).
- Fechas en UTC en BD; `parseTimestamptzToLocal` / `parseScheduledAtColumn` en lectura.
- `hasBookableSlotsForDate` excluye slots pasados si el día es hoy.

### Especialidades
- Catálogo fijo de 7 items (seed). Sin UI para crear nuevas.
- Gestión en `clinic_specialties` con DELETE + INSERT.

### Búsqueda de texto
- `searchClinics` trae todas las clínicas y filtra en cliente con `searchTextContains`
  (ignora mayúsculas y tildes). No usa `.ilike` por campo individual.
- Búsqueda cercana: bounding box en Supabase + filtro Haversine en cliente.

### Favoritos
- Solo el propietario autenticado puede añadir/quitar favoritos de su lista.
- Invalidar `favoriteClinicIdsProvider` y `favoriteClinicsProvider` tras toggle.
- Listas dedicadas: `/search/favorites` (desde buscar) y `/profile/favorites` (desde perfil).

### Citas realizadas (`completed_at`)
- Al marcar manualmente desde agenda clínica: `status = done` + `completed_at = now()`.
- Auto-completado RPC: solo citas `confirmed` cuyo slot ya terminó; también setea `completed_at`.
- Estadísticas del dashboard usan `completed_at` para contar realizadas del día.

### Joins y RLS — punto crítico
- Tablas en joins anidados públicos deben tener SELECT USING(true) donde aplique.
- `get_booked_slots` usa SECURITY DEFINER para slots ocupados sin exponer datos de otros owners.

### Notas clínicas
- Varias notas por cita permitidas en BD.
- Solo si status `confirmed` o `done`; `PetVisit.canAddNotes` en UI.

### Perfil de clínica incompleto
- `Clinic.isProfileComplete`: `name`, `address` y `city` no vacíos (ya no exige especialidad).
- Banner en ClinicHomeScreen si incompleto.
- Sin `lat`/`lng` la clínica no aparece en búsqueda por proximidad.

### Navegación con go_router
- `context.push()` / `context.go()` según apilar o reemplazar tab.
- `extra` entre rutas: `Specialty`, `int` (tab agenda), `String` (nombres),
  `({double lat, double lng})` (nearby),
  `({double clinicLat, double clinicLng, String clinicName})` (mapa clínica).
  No sobrevive hot restart.
- Registro por ruta parametrizada: `/register/:role` (owner|clinic) en lugar de
  pasar rol por `extra`.

### Eliminación de citas canceladas
- Se mantiene **borrado físico** de citas canceladas (`DELETE`) para owner y clinic
  bajo políticas RLS específicas.
- El intento de soft delete por actor (`deleted_by_owner_at` / `deleted_by_clinic_at`)
  fue revertido; no forma parte del estado actual.

### Dialogs y contexto
- Usar `dialogContext` del builder en AlertDialog y bottom sheets.
- Cerrar dialog antes de navegar con GoRouter.

### Sistema de errores en UI
- No mostrar errores técnicos (`e.toString()`, `'$e'`) en textos visibles para usuario.
- Flujo: `catch` → `mapError(e)` → `appErrorMessage(context, error)` (traducción es/en).
- Inline en formularios/sheets: `AppErrorBanner`; acciones async: `showAppError(context, e)`.
- Detalles técnicos solo en logs con `logAppError(context, e, tag: '...')`.
- Códigos en `AppErrorCode`: red, timeout, auth, ubicación, permisos, etc.

### Ubicación del usuario
- `resolveUserLocation()` en `user_location_service.dart`: servicio deshabilitado,
  permiso denegado, timeout o éxito (con flag `fromCache` si viene de lastKnown).
- SearchScreen y ClinicMapScreen muestran diálogos localizados según el fallo.

### Invalidación de providers
- Citas propietario: `myAppointmentsProvider`
- Mascotas: `myPetsProvider`
- Slots reserva: `bookedSlotsProvider` al entrar al paso hora
- Agenda clínica: `clinicAppointmentsProvider`
- Perfil clínica guardado: `myClinicProvider`, `mySchedulesProvider`
- Reserva tras cambio en Mi clínica: `invalidateClinicBookingData(ref, clinicId)`
- Favoritos: `favoriteClinicIdsProvider`, `favoriteClinicsProvider`
- SearchScreen refresh: favoritos, especialidades, perfil, citas

### Formato de fechas e i18n
- `intl` + `app_date_format.dart` según `Locale` activo (`localeProvider`).
- Patrones distintos para es/en (ej. `"d 'de' MMMM"` vs `"MMMM d"`).

### Edge Functions — recordatorios y notificaciones
- `send-appointment-reminders`: cron horario, `reminder_sent`.
- `send-appointment-notification`: confirmación/denegación desde Flutter.
- SERVICE_ROLE_KEY para leer emails en `auth.users`.
- Destinatario hardcodeado en desarrollo (Resend modo pruebas).

### Consentimiento legal
- Registro bloqueado sin aceptar privacidad y términos.
- Timestamps guardados en `profiles`; textos en `shared/legal/`.

### Geocodificación (Nominatim)
- Solo al guardar perfil de clínica o al editar dirección/ciudad (con rate limit ~1 req/s).
- User-Agent identificable requerido por OSM.
- Si falla, se guarda la clínica sin coordenadas (aviso naranja en snackbar).
