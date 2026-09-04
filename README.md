# Family Care V2

This version follows the reference screens you provided:
- Welcome / Get Started
- Create account
- Login
- Family setup + invite code
- People dashboard
- Recipient detail
- Timeline
- Add update
- Medication / appointment / note entry
- Reminders
- More / family members / notifications / settings

## Stack

Flutter + Supabase + PostgreSQL.

## 1. Create the Flutter platform files

From this folder:

```bash
flutter create .
```

Then:

```bash
flutter pub get
```

## 2. Supabase

Open Supabase SQL Editor and run `supabase_schema.sql`.

Use your publishable/anon key in the Flutter app. Never put a service-role/secret key in Flutter.

Run:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

## 3. Account fields

Create account asks for:
- Full name
- Phone number
- National ID (optional)
- Email
- Password
- Confirm password

National ID is sensitive personal data. Keep it optional and only collect it if you have a clear lawful purpose. The RLS policy in this MVP lets a user read/update their own profile only.

## 4. Notifications

### App notifications

`flutter_local_notifications` is included.

On Android/iOS, reminders created in the app are scheduled on the device.

On the web, browsers have limitations around future scheduled notifications. The app therefore treats Supabase + email delivery as the reliable server-side reminder path. The web notification permission can still be requested from More > Notifications.

### Email reminders

The included Edge Function is:

`supabase/functions/send_reminders/index.ts`

It sends due reminders through Resend.

Deploy:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set RESEND_API_KEY=YOUR_RESEND_KEY
supabase functions deploy send_reminders
```

Then schedule it with Supabase Cron to run every minute. The Supabase Dashboard can create a Cron job that invokes the Edge Function.

Change the `from` email in the function to an address on a verified domain.

## 5. Hosting

For a normal public web version:

```bash
flutter build web --release
```

The output is in `build/web`.

You can deploy that folder to Vercel, Firebase Hosting, Cloudflare Pages, Netlify, or another static host.

For this project, I recommend Vercel or Firebase Hosting for the web URL, and Supabase for the backend.

Appetize is better for demos/testing of an Android/iOS build in a browser. It is not the same as hosting your production Flutter web app. Appetize can give you a share link for a specific mobile build.

## Important

This is a family coordination app, not a diagnosis or emergency-care system. Do not rely on it for urgent medical decisions. Before real-world use, add stronger privacy controls, audit logging, data retention/deletion rules, consent flows, backups, and a security review.
