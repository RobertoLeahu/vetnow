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
  - Edge Functions: Deno (TypeScript) para recordatorios de email
  - Storage: disponible pero no usado aún
- **Email:** Resend API (integrado en Edge Function)

### Estructura de carpetas Flutter

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart          # GoRouter con ShellRoute
│   ├── main_shell.dart      # Bottom NavBar dinámico según rol
│   └── theme.dart           # Sistema de diseño (colores, inputs, botones)
├── core/
│   ├── supabase/
│   │   └── supabase_client.dart   # instancia global: supabase
│   └── constants/
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
│   │   └── ui/  appointments_screen | booking_screen
│   ├── pet/                       # Mascotas (rol owner)
│   │   ├── data/pet_repository.dart
│   │   ├── providers/pet_provider.dart
│   │   └── ui/  pets_screen
│   ├── profile/                   # Perfil propietario
│   │   └── ui/  profile_screen
│   └── clinic_panel/              # Panel de gestión (rol clinic) — EN PROGRESO
│       └── ui/
│           ├── clinic_home_screen.dart     # placeholder
│           ├── clinic_agenda_screen.dart   # placeholder
│           ├── clinic_patients_screen.dart # placeholder
│           └── clinic_profile_screen.dart  # solo logout
└── shared/
    ├── models/
    │   ├── profile.dart      # id, role (owner|clinic), fullName, phone, avatarUrl
    │   ├── clinic.dart       # id, profileId, name, city, specialties[]...
    │   ├── specialty.dart    # id, name
    │   ├── pet.dart          # id, ownerId, name, species, breed, birthDate
    │   └── appointment.dart  # id, clinicId, petId, scheduledAt, status...
    └── widgets/              # vacío por ahora
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
```

**RLS activada en todas las tablas.** Políticas clave:
- `clinics`: lectura pública, escritura solo profile_id dueño.
- `pets`: solo el owner ve/edita las suyas.
- `appointments`: owner ve las suyas, clínica ve las de su clinic_id.
- `specialties` y `clinic_specialties`: lectura pública (crítico para joins).

### Navegación (router.dart)

```
/login              → LoginScreen         (sin shell)
/role-selector      → RoleSelectorScreen  (sin shell)
/register           → RegisterScreen      (sin shell, recibe UserRole por extra)

ShellRoute → MainShell (bottom nav dinámico por rol)
  /search                        → SearchScreen
  /search/clinic/:id             → ClinicDetailScreen
  /search/clinic/:id/book        → BookingScreen (recibe Specialty por extra)
  /appointments                  → AppointmentsScreen
  /pets                          → PetsScreen
  /profile                       → ProfileScreen
  /clinic-home                   → ClinicHomeScreen      (placeholder)
  /clinic-agenda                 → ClinicAgendaScreen    (placeholder)
  /clinic-patients               → ClinicPatientsScreen  (placeholder)
  /clinic-profile                → ClinicProfileScreen   (solo logout)
```

**Redirección por rol en login:**
- role == 'owner'  → /search
- role == 'clinic' → /clinic-home

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
- Calendario custom (sin dependencias externas) que bloquea fechas pasadas.
- Grid de slots de 30 min (09:00–19:00) con slots ocupados en gris.
- Los slots ocupados se consultan en Supabase y se invalidan al montar
  el paso de hora (evita reservas duplicadas sin hot reload).
- Dialog de éxito con fecha formateada en español (intl).
- Cancelación de cita con dialog de confirmación.
- AppointmentsScreen con 3 tabs (Programadas / Realizadas / Canceladas)
  con contadores reales desde Supabase.
- Status badge por estado (pendiente / confirmada / realizada / cancelada).

### ✅ Gestión de mascotas — propietario (Fase 3 — completa)
- PetsScreen con lista de mascotas y estado vacío.
- _AddPetSheet: bottom sheet con nombre, selector de especie (perro/gato/
  exótico/otro con emojis), raza opcional y fecha de nacimiento opcional.
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

### ✅ NavBar dinámico por rol (inicio Fase 5)
- MainShell detecta el rol del profileProvider y renderiza:
  - Owner: Buscar | Citas | Mascotas | Perfil
  - Clinic: Inicio | Agenda | Pacientes | Mi clínica
- Redirección automática tras login según rol.
- Las 4 pantallas del panel clínica existen como placeholders.

---

Falta: tabla `medical_notes` (no creada aún). Esquema propuesto:
```sql
medical_notes
  id            uuid PK
  appointment_id uuid FK → appointments.id
  clinic_id     uuid FK → clinics.id
  content       text
  created_at    timestamptz
```
RLS: solo la clínica dueña puede leer/escribir sus notas.

---

## 5. Reglas de Negocio y Peculiaridades Importantes

### Roles y acceso
- El rol se guarda en `profiles.role` como TEXT ('owner' | 'clinic').
- El enum Dart es `UserRole { owner, clinic }`.
- **Una cuenta no puede cambiar de rol.** No hay UI para ello.
- El MainShell lee `profileProvider` para decidir qué NavBar mostrar.
  Si el profile tarda en cargar, muestra el NavBar de owner por defecto
  (el valor por defecto de `isClinic` es false).

### Slots de cita
- Los slots se generan en el **cliente Flutter**, no en Supabase.
- Rango fijo: 09:00 – 19:00, intervalos de 30 minutos = 20 slots/día.
- Un slot está ocupado si existe una cita con ese `scheduled_at` exacto
  y status IN ('pending', 'confirmed').
- La comparación de slots se hace por hora y minuto como string
  (`'HH:mm'`) para evitar problemas de zona horaria.
- Las fechas se guardan en Supabase en UTC y se convierten a local
  con `.toLocal()` al leer.

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

### Navegación con go_router
- `context.push()` para navegación hacia adelante (apila).
- `context.go()` para navegación por tabs (reemplaza, no apila).
- El botón back en BookingScreen usa `context.pop()` para retroceder
  pasos del formulario, y `context.go()` después del éxito para ir
  a /appointments sin dejar BookingScreen en el stack.
- El `extra` de go_router se usa para pasar objetos entre rutas:
  - RoleSelectorScreen → RegisterScreen: pasa `UserRole`
  - ClinicDetailScreen → BookingScreen: pasa `Specialty`
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

### Formato de fechas
- Se usa el paquete `intl` con locale 'es'.
- `initializeDateFormatting('es', null)` se llama en `main()` antes de
  `runApp()`.
- Formato típico: `DateFormat("d 'de' MMMM 'a las' HH:mm", 'es')`

### Edge Function — recordatorios
- Archivo: `supabase/functions/send-appointment-reminders/index.ts`
- Se invoca vía HTTP POST (cron job cada hora con pg_cron).
- Usa `SUPABASE_SERVICE_ROLE_KEY` (no anon key) para leer auth.users.
- Marca `reminder_sent = true` tras enviar para no reenviar.
- En desarrollo: el `to` del email está hardcodeado al email de la
  cuenta Resend. En producción cambiar a `ownerEmail` variable con
  dominio verificado.