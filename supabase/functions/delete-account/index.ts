import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

async function removeStoragePrefix(
  admin: ReturnType<typeof createClient>,
  bucket: string,
  prefix: string,
) {
  const trimmed = prefix.replace(/\/$/, "");
  const { data: files, error } = await admin.storage.from(bucket).list(trimmed, {
    limit: 1000,
  });
  if (error) throw error;
  if (!files?.length) return;

  const paths = files
    .filter((f) => f.name && f.id !== null)
    .map((f) => `${trimmed}/${f.name}`);

  if (paths.length > 0) {
    const { error: removeError } = await admin.storage.from(bucket).remove(paths);
    if (removeError) throw removeError;
  }
}

async function deleteOwnerData(
  admin: ReturnType<typeof createClient>,
  userId: string,
) {
  const { data: appointments, error: aptListError } = await admin
    .from("appointments")
    .select("id")
    .eq("owner_id", userId);

  if (aptListError) throw aptListError;

  const appointmentIds = (appointments ?? []).map((a) => a.id as string);
  if (appointmentIds.length > 0) {
    const { error: notesError } = await admin
      .from("medical_notes")
      .delete()
      .in("appointment_id", appointmentIds);
    if (notesError) throw notesError;
  }

  const { error: aptError } = await admin
    .from("appointments")
    .delete()
    .eq("owner_id", userId);
  if (aptError) throw aptError;

  const { error: petsError } = await admin.from("pets").delete().eq("owner_id", userId);
  if (petsError) throw petsError;

  const { error: favError } = await admin
    .from("clinic_favorites")
    .delete()
    .eq("owner_id", userId);
  if (favError) throw favError;

  await removeStoragePrefix(admin, "pet-photos", userId);
}

async function deleteClinicData(
  admin: ReturnType<typeof createClient>,
  userId: string,
) {
  const { data: clinic, error: clinicFetchError } = await admin
    .from("clinics")
    .select("id")
    .eq("profile_id", userId)
    .maybeSingle();

  if (clinicFetchError) throw clinicFetchError;

  const clinicId = clinic?.id as string | undefined;

  if (clinicId) {
    const { error: notesError } = await admin
      .from("medical_notes")
      .delete()
      .eq("clinic_id", clinicId);
    if (notesError) throw notesError;

    const { error: aptError } = await admin
      .from("appointments")
      .delete()
      .eq("clinic_id", clinicId);
    if (aptError) throw aptError;

    const { error: specError } = await admin
      .from("clinic_specialties")
      .delete()
      .eq("clinic_id", clinicId);
    if (specError) throw specError;

    const { error: schedError } = await admin
      .from("schedules")
      .delete()
      .eq("clinic_id", clinicId);
    if (schedError) throw schedError;

    const { error: clinicError } = await admin
      .from("clinics")
      .delete()
      .eq("id", clinicId);
    if (clinicError) throw clinicError;

    await removeStoragePrefix(admin, "clinic-logos", clinicId);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return json({ error: "Missing or invalid Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
      return json({ error: "Server configuration error" }, 500);
    }

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);
    const userId = user.id;

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("role")
      .eq("id", userId)
      .maybeSingle();

    if (profileError) throw profileError;
    if (!profile) {
      return json({ error: "Profile not found" }, 404);
    }

    const role = profile.role as string;

    if (role === "owner") {
      await deleteOwnerData(admin, userId);
    } else if (role === "clinic") {
      await deleteClinicData(admin, userId);
    } else {
      return json({ error: `Unsupported role: ${role}` }, 400);
    }

    const { error: profileDeleteError } = await admin
      .from("profiles")
      .delete()
      .eq("id", userId);
    if (profileDeleteError) throw profileDeleteError;

    const { error: authDeleteError } = await admin.auth.admin.deleteUser(userId);
    if (authDeleteError) throw authDeleteError;

    return json({ ok: true });
  } catch (err) {
    console.error("delete-account error:", err);
    return json({ error: String(err) }, 500);
  }
});
