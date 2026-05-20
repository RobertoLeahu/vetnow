import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;

Deno.serve(async (req) => {
  try {
    const { appointmentId, type } = await req.json() as {
      appointmentId: string;
      type: "confirmed" | "rejected";
    };

    if (!appointmentId || !type) {
      return new Response(
        JSON.stringify({ error: "Faltan parámetros: appointmentId y type son obligatorios" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const { data: apt, error } = await supabase
      .from("appointments")
      .select(
        `
        id,
        owner_id,
        scheduled_at,
        profiles!owner_id(full_name),
        clinics(name, address, city, phone),
        pets(name),
        specialties(name)
      `,
      )
      .eq("id", appointmentId)
      .single();

    if (error) throw error;
    if (!apt) {
      return new Response(
        JSON.stringify({ error: "Cita no encontrada" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    const { data: userData } = await supabase.auth.admin.getUserById(
      apt.owner_id ?? "",
    );
    const ownerEmail = userData?.user?.email;
    if (!ownerEmail) {
      return new Response(
        JSON.stringify({ error: "No se encontró el email del propietario" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

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

    const isConfirmed = type === "confirmed";

    const subject = isConfirmed
      ? `Tu cita en ${apt.clinics?.name} ha sido confirmada`
      : `Tu cita en ${apt.clinics?.name} ha sido cancelada`;

    const accentColor = isConfirmed ? "#00897B" : "#E53935";
    const iconEmoji = isConfirmed ? "✅" : "❌";
    const headingText = isConfirmed ? "Cita confirmada" : "Cita cancelada";
    const bodyText = isConfirmed
      ? `Tu cita veterinaria ha sido <strong>confirmada</strong> por la clínica. Te esperamos en:`
      : `Lamentablemente, la clínica ha <strong>cancelado</strong> tu cita veterinaria. Si lo deseas, puedes reservar una nueva cita desde la app VetNow.`;

    const html = `
      <div style="font-family: sans-serif; max-width: 500px; margin: 0 auto;">
        <h2 style="color: ${accentColor};">${iconEmoji} ${headingText}</h2>
        <p>Hola <strong>${apt.profiles?.full_name}</strong>,</p>
        <p>${bodyText}</p>

        <div style="background: #F5F7F8; border-radius: 12px; padding: 20px; margin: 20px 0;">
          <p><strong>📍 Clínica:</strong> ${apt.clinics?.name}</p>
          <p><strong>📌 Dirección:</strong> ${apt.clinics?.address}, ${apt.clinics?.city}</p>
          <p><strong>🩺 Especialidad:</strong> ${apt.specialties?.name}</p>
          <p><strong>🐶 Mascota:</strong> ${apt.pets?.name}</p>
          <p><strong>📅 Fecha:</strong> ${dateStr}</p>
          <p><strong>🕐 Hora:</strong> ${timeStr}</p>
          ${apt.clinics?.phone ? `<p><strong>📞 Teléfono:</strong> ${apt.clinics.phone}</p>` : ""}
        </div>

        <p style="color: #8A94A6; font-size: 13px;">
          ${isConfirmed
            ? "Si necesitas cancelar, hazlo desde la app VetNow."
            : "Puedes ver tus citas en cualquier momento desde la app VetNow."}
        </p>
      </div>
    `;

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
        to: ["robertoalexandruleahu@gmail.com"],
        subject,
        html,
      }),
    });

    if (!emailRes.ok) {
      const errBody = await emailRes.text();
      return new Response(
        JSON.stringify({ error: "Error enviando email", detail: errBody }),
        { status: 502, headers: { "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ message: "Email enviado correctamente", type, appointmentId }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
