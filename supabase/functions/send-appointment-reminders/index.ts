import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;

Deno.serve(async () => {
  try {
    // Buscar citas en las próximas 24h que no hayan recibido recordatorio
    const now = new Date();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const { data: appointments, error } = await supabase
      .from("appointments")
      .select(
        `
    id,
    owner_id,
    scheduled_at,
    notes,
    profiles!owner_id(full_name),
    clinics(name, address, city, phone),
    pets(name),
    specialties(name)
  `,
      )
      .gte("scheduled_at", now.toISOString())
      .lte("scheduled_at", in24h.toISOString())
      .in("status", ["pending", "confirmed"])
      .eq("reminder_sent", false);

    if (error) throw error;
    if (!appointments || appointments.length === 0) {
      return new Response(
        JSON.stringify({ message: "No hay citas para recordar", count: 0 }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    let sent = 0;
    const errors = [];

    for (const apt of appointments) {
      try {
        // Obtener email del propietario desde auth.users
        const { data: userData } = await supabase.auth.admin.getUserById(
          apt.owner_id ?? "",
        );
        const ownerEmail = userData?.user?.email;
        if (!ownerEmail) continue;

        const scheduledDate = new Date(apt.scheduled_at);
        const dateStr = scheduledDate.toLocaleDateString("es-ES", {
          weekday: "long",
          year: "numeric",
          month: "long",
          day: "numeric",
        });
        const timeStr = scheduledDate.toLocaleTimeString("es-ES", {
          hour: "2-digit",
          minute: "2-digit",
        });

        // Enviar email con Resend
        const emailRes = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: "VetNow <onboarding@resend.dev>",
            //Cambiar robertoalexandruleahu@gmail.com a ownerEmail fuera de Modo Pruebas de Resend
            //Necesitas verificar un dominio en Resend. Es el único requisito para enviar a cualquier destinatario.
            to: ['robertoalexandruleahu@gmail.com'],
            subject: `Recordatorio: cita mañana en ${apt.clinics?.name}`,
            html: `
              <div style="font-family: sans-serif; max-width: 500px; margin: 0 auto;">
                <h2 style="color: #00897B;">Recordatorio de cita 🐾</h2>
                <p>Hola <strong>${apt.profiles?.full_name}</strong>,</p>
                <p>Te recordamos que mañana tienes una cita veterinaria:</p>

                <div style="background: #F5F7F8; border-radius: 12px; padding: 20px; margin: 20px 0;">
                  <p><strong>📍 Clínica:</strong> ${apt.clinics?.name}</p>
                  <p><strong>📌 Dirección:</strong> ${apt.clinics?.address}, ${apt.clinics?.city}</p>
                  <p><strong>🩺 Especialidad:</strong> ${apt.specialties?.name}</p>
                  <p><strong>🐶 Mascota:</strong> ${apt.pets?.name}</p>
                  <p><strong>📅 Fecha:</strong> ${dateStr}</p>
                  <p><strong>🕐 Hora:</strong> ${timeStr}</p>
                  ${
                    apt.clinics?.phone
                      ? `<p><strong>📞 Teléfono:</strong> ${apt.clinics.phone}</p>`
                      : ""
                  }
                </div>

                <p style="color: #8A94A6; font-size: 13px;">
                  Si necesitas cancelar, hazlo desde la app VetNow.
                </p>
              </div>
            `,
          }),
        });

        if (!emailRes.ok) {
          const errBody = await emailRes.text();
          errors.push({ appointmentId: apt.id, error: errBody });
          continue;
        }

        // Marcar reminder_sent = true
        await supabase
          .from("appointments")
          .update({ reminder_sent: true })
          .eq("id", apt.id);

        sent++;
      } catch (aptError) {
        errors.push({ appointmentId: apt.id, error: String(aptError) });
      }
    }

    return new Response(
      JSON.stringify({
        message: `Recordatorios enviados: ${sent}/${appointments.length}`,
        sent,
        errors,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
