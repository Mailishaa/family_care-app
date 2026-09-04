# Notifications setup

## Android

The current `flutter_local_notifications` version may require Android build configuration changes.
After `flutter create .`, if Gradle asks for core library desugaring, follow the package's current Android setup instructions.

For exact scheduled alarms, Android 13+ also requires notification permission.

## iOS

For local notifications, Xcode must have notification capabilities/permissions configured.

## Web

Browser notifications require user permission. The app requests this from the Notifications item in More, rather than automatically on page load.

Future scheduled browser notifications are not as dependable as native scheduled notifications. For production web reminders, use the included Supabase Cron + Edge Function email path, and add Web Push/FCM when you want background push notifications on browsers.
