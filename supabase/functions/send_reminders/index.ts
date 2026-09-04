// Supabase Edge Function: sends due reminder emails.
// Configure RESEND_API_KEY as a Supabase secret.
// The mobile/web app remains the source of truth for reminders.
// Push notifications can be added here later using FCM/OneSignal.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const resendKey = Deno.env.get("RESEND_API_KEY")!;

const admin = createClient(supabaseUrl, serviceRoleKey);

Deno.serve(async () => {
  const now = new Date().toISOString();

  const { data: reminders, error } = await admin
    .from("reminders")
    .select(`
      id, title, remind_at, email_enabled,
      care_recipients(name, family_id),
      families:care_recipients!inner(families(name))
    `)
    .eq("completed", false)
    .eq("email_enabled", true)
    .is("sent_at", null)
    .lte("remind_at", now);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  let sent = 0;

  for (const reminder of reminders ?? []) {
    const recipient = reminder.care_recipients;
    if (!recipient) continue;

    const familyId = recipient.family_id;

    const { data: members } = await admin
      .from("family_members")
      .select("profiles(email,full_name)")
      .eq("family_id", familyId);

    for (const member of members ?? []) {
      const profile = member.profiles;
      const email = profile?.email;
      if (!email) continue;

      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${resendKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: "Family Care <reminders@yourdomain.example>",
          to: [email],
          subject: `Family Care reminder: ${reminder.title}`,
          html: `<p>Hello ${profile.full_name ?? ""},</p>
                 <p>Reminder for <strong>${recipient.name}</strong>:</p>
                 <p><strong>${reminder.title}</strong></p>
                 <p>This reminder was scheduled for ${reminder.remind_at}.</p>`,
        }),
      });
    }

    await admin.from("reminders").update({ sent_at: now }).eq("id", reminder.id);
    sent++;
  }

  return new Response(JSON.stringify({ ok: true, sent }), {
    headers: { "Content-Type": "application/json" },
  });
});
