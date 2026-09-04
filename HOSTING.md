# Hosting checklist

## Best production shape

**Frontend:** Flutter Web on Vercel (or Firebase Hosting)  
**Backend:** Supabase Auth + PostgreSQL + Edge Functions  
**Email:** Resend  
**Native app notifications:** flutter_local_notifications  
**Future background push:** Firebase Cloud Messaging (FCM)

### Build the web app

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

The release files are in `build/web`.

### Vercel

A practical route is to deploy the already-built `build/web` folder as a static site. Vercel serves the output directory; it does not require your users to install Flutter or run `flutter run`.

If you connect a Git repository, either:
1. build Flutter Web in CI and deploy `build/web`, or
2. keep a generated `build/web` artifact and configure Vercel to serve it.

For a first prototype, the easiest approach is to build locally and deploy the generated web folder.

### Appetize

Appetize is excellent for a browser-based demo of the **mobile APK/IPA**. Uploading a Flutter-generated mobile build gives you an Appetize share link that people can open in a browser. It is not the right replacement for production hosting of your Flutter Web app.

## Reminder delivery

A reminder has two flags:
- `email_enabled`
- `push_enabled`

The Flutter app schedules a native local notification when a reminder is created.

For email, deploy `supabase/functions/send_reminders/index.ts` and run it every minute with Supabase Cron. The function finds due reminders and emails every member of the family.

For a production browser push experience, add FCM/Web Push later. Browsers do not have the same future-scheduling guarantees as Android/iOS local notifications.

## Security before real users

Because the app may contain health-related notes and national ID numbers:
- Keep national ID optional.
- Never expose a Supabase service-role key in Flutter or the browser.
- Keep RLS enabled.
- Consider encrypting especially sensitive fields.
- Add account deletion and data export.
- Add an audit log before scaling.
- Decide how long records are retained.
