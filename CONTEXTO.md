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

### Backend
- **Plataforma:** Supabase (BaaS)
  - Auth: email/password con roles custom en tabla profiles
  - Base de datos: PostgreSQL con RLS activado en todas las tablas
  - Edge Functions: Deno (TypeScript) para recordatorios y notificaciones de email
  - Storage: usado para logos de clínica (subida vía image_picker)
- **Email:** Resend API (integrado en Edge Functions)

### Estructura de carpetas Flutter

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart          # GoRouter con ShellRoute y redirección por rol
│   ├── main_shell.dart      # Bottom NavBar dinámico según rol
│   └── theme.dart           # Sistema de diseño (colores, inputs, botones)
├── core/
│   ├── supabase/
│   │   └── supabase_client.dart   # instancia global: supabase
│   ├── providers/
│   │   └── theme_provider.dart    # StateProvider<ThemeMode> para modo oscuro
│   └── datetime/
│       └── timestamptz.dart       # Helper para parsear timestamptz de PostgREST a local
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── providers/auth_provider.dart
│   │   └── ui/  login_screen | register_screen | role_selector_screen
│   ├── clinic/                    # Funcionalidades del buscador (rol owner)
│   │   ├── data/clinic_repository.dart
│   │   ├── providers/clinic_provider.dart
│   │   └── ui/  search_screen | clinic_detail_screen
│   ├── appointment/               # Citas (rol owner)
│   │   ├── data/appointment_repository.dart
│   │   ├── providers/appointment_provider.dart
│   │   ├── utils/slot_generator.dart   # Genera slots según horarios de la clínica
│   │   └── ui/  appointments_screen | booking_screen
│   ├── pet/                       # Mascotas (rol owner)
│   │   ├── data/pet_repository.dart
│   │   ├── providers/pet_provider.dart
│   │   └── ui/  pets_screen
│   ├── profile/                   # Perfil propietario
│   │   └── ui/
│   │       ├── profile_screen.dart
│   │       ├── settings_screen.dart        # Ajustes: acceso a cuenta y personalización
│   │       ├── account_screen.dart         # Edición teléfono y cambio de contraseña
│   │       └── personalization_screen.dart # Toggle modo oscuro
│   └── clinic_panel/              # Panel de gestión (rol clinic) — COMPLETO
│       ├── data/medical_notes_repository.dart  # Notas clínicas + pacientes + visitas
│       ├── providers/clinic_panel_provider.dart
│       └── ui/
│           ├── clinic_home_screen.dart     # Dashboard con resumen del día
│           ├── clinic_agenda_screen.dart   # Agenda con 4 tabs y filtro de fecha
│           ├── clinic_patients_screen.dart # Expedientes: propietarios → mascotas → visitas
│           └── clinic_profile_screen.dart  # Edición completa del perfil de clínica
└── shared/
    ├── models/
    │   ├── profile.dart      # id, role (owner|clinic), fullName, phone, avatarUrl
    │   ├── clinic.dart       # id, profileId, name, city, specialties[], isProfileComplete
    │   ├── specialty.dart    # id, name
    │   ├── schedule.dart     # id, clinicId, dayOfWeek (0=lun..6=dom), openTime, closeTime
    │   ├── pet.dart          # id, ownerId, name, species (8 valores), breed, birthDate
    │   ├── appointment.dart  # id, clinicId, petId, scheduledAt, status, ownerFullName...
    │   └── medical_note.dart # id, appointmentId, clinicId, content, createdAt, updatedAt
    └── widgets/
```

### Esquema de Base de Datos (Supabase / PostgreSQL)

```sql
profiles          -- Extiende auth.users. role: 'owner' | 'clinic'
specialties       -- Catálogo fijo. 7 registros seed insertados.
clinics           -- profile_id FK → profiles. Datos públicos de la clínica.
clinic_specialties-- Relación N:M clínicas ↔ especialidades.
schedules         -- Horarios semanales por clínica (day_of_week, open/close_time).
pets              -- owner_id FK → profiles. Mascotas del propietario.
appointments      -- clinic_id, pet_id, owner_id, specialty_id, scheduled_at, status, reminder_sent.
medical_notes     -- appointment_id FK, clinic_id FK, content, created_at, updated_at.
```

**RPC functions:**
- `get_booked_slots(p_clinic_id, p_from, p_to)` — SECURITY DEFINER: devuelve
  `scheduled_at` de citas ocupadas sin exponer datos personales. Necesario para
  que un propietario pueda ver los huecos libres de la clínica sin que la RLS
  bloquee las citas de otros propietarios.

**RLS activada en todas las tablas.** Políticas clave:
- `clinics`: lectura pública, escritura solo profile_id dueño.
- `pets`: solo el owner ve/edita las suyas.
- `appointments`: owner ve las suyas, clínica ve las de su clinic_id.
- `specialties` y `clinic_specialties`: lectura pública (crítico para joins).
- `medical_notes`: solo la clínica dueña (`clinic_id` del JWT) puede leer/escribir.

### Navegación (router.dart)

```
/login              → LoginScreen         (sin shell)
/role-selector      → RoleSelectorScreen  (sin shell)
/register           → RegisterScreen      (sin shell, recibe UserRole por extra)
/auth-resolve       → Spinner de carga    (sin shell, mientras profileProvider carga)

ShellRoute → MainShell (bottom nav dinámico por rol)
  /search                              → SearchScreen
  /search/clinic/:id                   → ClinicDetailScreen
  /search/clinic/:id/book              → BookingScreen (recibe Specialty por extra)
  /appointments                        → AppointmentsScreen
  /pets                                → PetsScreen
  /profile                             → ProfileScreen
  /profile/settings                    → SettingsScreen
  /profile/settings/account            → AccountScreen
  /profile/settings/personalization    → PersonalizationScreen
  /clinic-home                         → ClinicHomeScreen
  /clinic-agenda                       → ClinicAgendaScreen (recibe int initialTabIndex por extra)
  /clinic-patients                     → ClinicPatientsScreen
  /clinic-patients/:ownerId            → OwnerPetsScreen (recibe ownerName por extra)
  /clinic-patients/:ownerId/:petId     → PetVisitsScreen (recibe petName por extra)
  /clinic-profile                      → ClinicProfileScreen
```

**Redirección por rol en login:**
- role == 'owner'  → /search
- role == 'clinic' → /clinic-home

**Protección cruzada de rutas:** si un usuario `clinic` intenta acceder a una
ruta de `owner` (o viceversa), el router lo redirige a su home automáticamente.
Mientras `profileProvider` está cargando, el router envía a `/auth-resolve`
(spinner) para evitar flashes de ruta incorrecta.

---

## 3. Estado Actual — Qué está hecho

### ✅ Auth (Fase 0 — completa)
- Registro con selección de rol (owner / clinic) mediante RoleSelectorScreen.
- Login con redirección automática según rol leído de tabla profiles.
- Logout funcional desde perfil (ambos roles).
- Provider `profileProvider` disponible globalmente vía Riverpod.

### ✅ Búsqueda de clínicas (Fase 1 — completa)
- SearchScreen con campo de texto (filtro ciudad) y chips horizontales
  de especialidad (filtro por specialty_id).
- Filtro de ciudad usa `.ilike()` en Supabase.
- Filtro de especialidad se aplica en cliente tras el fetch.
- ClinicDetailScreen con SliverAppBar, info básica, chips de especialidades
  y botón "Reservar cita".
- Resolución del bug de RLS en joins anidados (specialties pública).

### ✅ Flujo de reserva de citas — propietario (Fase 2 — completa)
- BookingScreen con 4 pasos: fecha → hora → mascota → confirmación.
- Calendario custom (sin dependencias externas) que bloquea fechas pasadas
  y días sin horario configurado por la clínica.
- Grid de slots generados dinámicamente según horarios reales de la clínica
  (`slot_generator.dart` + tabla `schedules`). Slots ocupados en gris.
- Los slots ocupados se consultan vía RPC `get_booked_slots` (SECURITY DEFINER)
  y se invalidan al montar el paso de hora (evita reservas duplicadas).
- Dialog de éxito con fecha formateada en español (intl).
- Cancelación de cita con dialog de confirmación.
- AppointmentsScreen con 3 tabs (Programadas / Realizadas / Canceladas)
  con contadores reales desde Supabase.
- Status badge por estado (pendiente / confirmada / realizada / cancelada).

### ✅ Gestión de mascotas — propietario (Fase 3 — completa)
- PetsScreen con lista de mascotas y estado vacío.
- _AddPetSheet: bottom sheet con nombre, selector de especie (8 especies con
  emojis: perro, gato, conejo, hámster, ave, reptil, hurón, otro), raza
  opcional y fecha de nacimiento opcional.
- Cálculo de edad automático en la tarjeta (meses / años).
- Eliminación con dialog de confirmación.
- FAB "Añadir mascota" visible siempre.

### ✅ Recordatorio por email (Fase 4 — completa)
- Edge Function `send-appointment-reminders` desplegada en Supabase.
- Busca citas en las próximas 24h con reminder_sent = false.
- Envía email HTML con Resend API.
- Marca reminder_sent = true tras el envío.
- Cron job configurado cada hora con pg_cron.
- Limitación actual: Resend en modo pruebas solo envía al email
  del propietario de la cuenta. Para enviar a cualquier destinatario
  se requiere verificar un dominio propio.

### ✅ NavBar dinámico por rol y panel clínica (Fase 5 — completa)
- MainShell detecta el rol del profileProvider y renderiza:
  - Owner: Buscar | Citas | Mascotas | Perfil
  - Clinic: Inicio | Agenda | Pacientes | Mi clínica
- Redirección automática tras login según rol.
- Protección cruzada de rutas: un rol no puede acceder a rutas del otro.
- `/auth-resolve` como pantalla de espera mientras carga el perfil.

#### ClinicHomeScreen (dashboard)
- SliverAppBar con logo, nombre de clínica y fecha del día.
- Banner amarillo si el perfil de la clínica está incompleto (`isProfileComplete`).
- Tarjeta teal con contador de citas del día y lista de las 3 próximas.
- Carrusel horizontal de pacientes confirmados para hoy (con foto/emoji de especie).
- Tarjeta naranja si hay citas pendientes de confirmación, con enlace a agenda.
- Grid de accesos rápidos: Agenda y Pacientes.
- Pull-to-refresh invalida `myClinicProvider` y `clinicAppointmentsProvider`.

#### ClinicAgendaScreen (agenda)
- 4 tabs: Pendientes | Confirmadas | Realizadas | Canceladas (con contadores).
- Dropdown de filtro de fecha: Hoy / Mañana / Esta semana / Todas las citas.
- Acciones por tarjeta según estado:
  - Pendiente: botones "Confirmar" y "Denegar" con dialog de confirmación.
    Ambas acciones disparan la Edge Function `send-appointment-notification`
    para notificar al propietario por email.
  - Confirmada: botón "Marcar como realizada".
  - Cancelada: botón "Eliminar" (borra la fila de BD).
- Recibe `initialTabIndex` por `extra` de go_router (usado desde ClinicHomeScreen).

#### ClinicPatientsScreen + expedientes médicos
- Lista de propietarios únicos que han tenido al menos una cita en la clínica,
  con buscador por nombre y fecha de última visita.
- Navegación anidada: propietario → lista de mascotas → historial de visitas.
- Cada visita (PetVisit) muestra fecha, especialidad, estado y sus notas clínicas.
- CRUD completo de notas clínicas por visita:
  - Añadir nota (solo si status ≠ 'pending').
  - Editar nota inline con campo de texto expandible.
  - Eliminar nota con confirmación.
- Las notas solo se pueden gestionar si la cita está `confirmed` o `done`;
  si está `pending`, el repositorio lanza `StateError` antes de escribir.

#### ClinicProfileScreen (perfil de clínica)
- Formulario completo: nombre, dirección, ciudad, teléfono, email, descripción.
- Selector de especialidades (chips toggle, máx. 7).
- Editor de horario semanal (lunes–domingo): activar día + hora apertura/cierre.
- Subida de logo desde galería o cámara (image_picker → Supabase Storage).
- `isProfileComplete` en el modelo `Clinic`: true si tiene nombre, dirección,
  ciudad y al menos una especialidad.
- Detección de cambios sin guardar: `clinicProfileExitHandlerProvider` registra
  un handler que muestra dialog de confirmación si se intenta salir con cambios.
- Guardado: upsert en `clinics` + DELETE/INSERT en `clinic_specialties` +
  upsert en `schedules`.

### ✅ Ajustes de cuenta y personalización — propietario (Fase 6 — completa)
- SettingsScreen: menú de ajustes con enlaces a cuenta y personalización.
- AccountScreen: edición de teléfono (prefijo + número), visualización de email,
  cambio de contraseña mediante bottom sheet, eliminación de cuenta con confirmación.
- PersonalizationScreen: toggle de modo oscuro gestionado por `themeModeProvider`
  (StateProvider<ThemeMode>).

### ✅ Notificaciones de email por acción de clínica (Fase 6 — completa)
- Edge Function `send-appointment-notification` desplegada en Supabase.
- Invocada por `AppointmentRepository` tras confirmar o denegar una cita.
- Recibe `{ appointmentId, type: 'confirmed' | 'rejected' }` en el body.
- Envía email HTML al propietario informando del cambio de estado.
- No lanza excepción si falla (la mutación en BD ya se completó).
- Misma limitación de dominio que `send-appointment-reminders`.

---

## 4. Reglas de Negocio y Peculiaridades Importantes

### Roles y acceso
- El rol se guarda en `profiles.role` como TEXT ('owner' | 'clinic').
- El enum Dart es `UserRole { owner, clinic }`.
- **Una cuenta no puede cambiar de rol.** No hay UI para ello.
- El MainShell lee `profileProvider` para decidir qué NavBar mostrar.
- El router protege las rutas cruzadas: `clinic` no puede acceder a `/search`,
  `/appointments`, `/pets` ni `/profile`; `owner` no puede acceder a
  `/clinic-*`.
- Mientras el perfil carga, el router redirige a `/auth-resolve` (spinner)
  para evitar que se muestre una pantalla del rol equivocado.

### Slots de cita
- Los slots se generan en el **cliente Flutter** mediante `slot_generator.dart`.
- El rango y los intervalos dependen de los **horarios reales** de la clínica
  almacenados en la tabla `schedules` (day_of_week, open_time, close_time).
- Si un día no tiene horario configurado, no se muestran slots y ese día queda
  bloqueado en el calendario.
- Un slot está ocupado si la RPC `get_booked_slots` lo devuelve (citas con
  status IN ('pending', 'confirmed') en ese tramo horario).
- La comparación de slots se hace por hora y minuto como string (`'HH:mm'`)
  para evitar problemas de zona horaria.
- Las fechas se guardan en Supabase en UTC. La función `parseTimestamptzToLocal`
  en `core/datetime/timestamptz.dart` normaliza el formato de PostgREST
  (espacio en lugar de 'T', offset sin ':') y convierte a hora local del dispositivo.

### Especialidades
- Son un **catálogo fijo** de 7 items insertado como seed en Supabase.
- No hay UI para que la clínica cree especialidades nuevas.
- Las especialidades de una clínica se gestionan en `clinic_specialties`.
- Al actualizar especialidades se hace DELETE + INSERT (no upsert).

### Joins y RLS — punto crítico
- Supabase requiere que **todas** las tablas involucradas en un join
  anidado tengan RLS con política de lectura pública si el dato es público.
- `specialties` y `clinic_specialties` deben tener política SELECT USING(true).
- Sin esto, los arrays de specialties llegan vacíos sin error explícito.
- Para `fetchBookedSlots` se usa una función RPC con SECURITY DEFINER en lugar
  de una query directa, ya que la RLS de `appointments` solo permite ver las
  propias citas y un propietario necesita ver todos los slots ocupados de la
  clínica para no solaparse.

### Notas clínicas y regla de estado
- Solo se pueden añadir, editar o eliminar notas si la cita tiene status
  `confirmed` o `done`. Si el status es `pending`, el repositorio llama a
  `_assertAppointmentAllowsNotes` antes de cualquier escritura y lanza
  `StateError`. Esta comprobación existe en capa Dart además de estar reforzada
  por RLS.
- La UI también oculta el formulario de notas si `PetVisit.canAddNotes == false`.

### Navegación con go_router
- `context.push()` para navegación hacia adelante (apila).
- `context.go()` para navegación por tabs (reemplaza, no apila).
- El botón back en BookingScreen usa `context.pop()` para retroceder
  pasos del formulario, y `context.go()` después del éxito para ir
  a /appointments sin dejar BookingScreen en el stack.
- El `extra` de go_router se usa para pasar objetos entre rutas:
  - RoleSelectorScreen → RegisterScreen: pasa `UserRole`
  - ClinicDetailScreen → BookingScreen: pasa `Specialty`
  - ClinicHomeScreen → ClinicAgendaScreen: pasa `int` (initialTabIndex)
  - ClinicPatientsScreen → OwnerPetsScreen: pasa `String` (ownerName)
  - OwnerPetsScreen → PetVisitsScreen: pasa `String` (petName)
  - El extra no sobrevive hot restart.

### Dialogs y contexto
- **Regla crítica:** los dialogs (AlertDialog, showModalBottomSheet)
  deben usar el `BuildContext` propio del builder (`dialogContext`),
  nunca el del widget padre.
- Usar `Navigator.of(dialogContext).pop()` dentro de dialogs.
- Usar `GoRouter.of(dialogContext).go()` para navegar desde dentro
  de un dialog.
- Si se navega desde un dialog, cerrar primero el dialog y luego navegar.

### Invalidación de providers
- Después de crear/cancelar una cita: `ref.invalidate(myAppointmentsProvider)`
- Después de crear/eliminar mascota: `ref.invalidate(myPetsProvider)`
- Al entrar al paso de selección de hora: `ref.invalidate(bookedSlotsProvider)`
  (se hace en initState de _StepTimeState para forzar fetch fresco).
- Tras confirmar/denegar/marcar realizada desde agenda: `ref.invalidate(clinicAppointmentsProvider)`
- Tras guardar perfil de clínica: `ref.invalidate(myClinicProvider)` +
  `ref.invalidate(mySchedulesProvider)`.
- ClinicHomeScreen invalida `clinicAppointmentsProvider` en `initState`
  para mostrar datos frescos cada vez que se entra al dashboard.

### Formato de fechas
- Se usa el paquete `intl` con locale 'es'.
- `initializeDateFormatting('es', null)` se llama en `main()` antes de
  `runApp()`.
- Formato típico: `DateFormat("d 'de' MMMM 'a las' HH:mm", 'es')`

### Timestamptz y zona horaria
- PostgREST puede devolver `timestamptz` en formato `"2025-05-10 07:30:00+00"`
  (espacio en lugar de 'T', offset sin ':'). `DateTime.parse` de Dart no
  acepta estos formatos sin normalización.
- `parseTimestamptzToLocal(String raw)` en `core/datetime/timestamptz.dart`
  normaliza ambos casos y garantiza que el resultado sea siempre hora local.
- Todos los modelos usan esta función al parsear campos de fecha.

### Edge Functions — recordatorios y notificaciones
- `send-appointment-reminders`: cron cada hora, busca citas en las próximas 24h
  con `reminder_sent = false`, envía email y marca el campo.
- `send-appointment-notification`: invocada explícitamente desde Flutter al
  confirmar o denegar una cita. Recibe `{ appointmentId, type }`.
- Ambas usan `SUPABASE_SERVICE_ROLE_KEY` para acceder a `auth.users`.
- En desarrollo: el destinatario está hardcodeado. En producción cambiar a
  `ownerEmail` con dominio verificado en Resend.

### Perfil de clínica incompleto
- `Clinic.isProfileComplete` devuelve `true` si tiene `name`, `address`,
  `city` y al menos una especialidad.
- Si es `false`, ClinicHomeScreen muestra un banner amarillo con enlace a
  `/clinic-profile` para completar los datos.
- Una clínica con perfil incompleto no aparecerá correctamente en búsquedas.
