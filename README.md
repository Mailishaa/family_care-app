# Family Care

Family Care is a shared family-care coordination application designed to help families keep important care information, appointments, reminders, and updates organized in one place.

The application focuses on **care coordination and memory**, not medical diagnosis.

## Project Purpose

Families often share responsibility for caring for parents, children, siblings, or other relatives. Important information can easily become scattered across WhatsApp messages, phone calls, notebooks, and personal calendars.

Family Care provides a simple shared space where family members can keep track of:

- People they care for
- Important care information
- Appointments and care updates
- Medication and other reminders
- Family activity and check-ins
- A chronological care timeline
- Important things to remember

The goal is to make family care more coordinated, visible, and less dependent on one person remembering everything.

---

## Features

### Family Management

- Create a family
- Join a family using an invite code
- Share care responsibilities with family members
- Family-based access to care information

### People

Add people the family cares for, including:

- Name
- Relationship
- Date of birth
- Notes
- Important things to remember

###  Care Updates

Family members can record updates such as:

- Doctor appointments
- Hospital visits
- Medication changes
- General care updates
- Important events

Each update can include:

- Title
- Description
- Date
- Person it relates to

###  Timeline

The timeline provides a chronological view of family-care updates.

Recent events appear first so family members can quickly understand what has happened recently.

###  Reminders

Create reminders for important care activities.

Reminders support:

- Reminder title
- Date and time
- Email notification preference
- Push/local notification preference
- Completion status

### Notifications

The project is designed to support:

- Local notifications on mobile
- Email reminders through Supabase Edge Functions
- Resend for transactional email
- Supabase Cron for scheduled reminder processing
- Firebase Cloud Messaging for future server-triggered push notifications

Web notification support can be added separately because browser background scheduling has different limitations from native mobile applications.

---

# 🛠️ Technology Stack

## Frontend

- Flutter
- Dart
- Material Design
- `supabase_flutter`
- `flutter_local_notifications`
- `intl`
- `timezone`

## Backend

- Supabase
- PostgreSQL
- Supabase Auth
- Row Level Security (RLS)
- Supabase Edge Functions
- Supabase Cron

## Hosting

- Vercel for Flutter Web deployment

## Planned Notification Services

- Resend for email
- Firebase Cloud Messaging for future push notifications

---

# Architecture

```text
                    ┌─────────────────────┐
                    │     Family Care     │
                    │    Flutter Web/App  │
                    └──────────┬──────────┘
                               │
                               │ supabase_flutter
                               ▼
                    ┌─────────────────────┐
                    │      Supabase       │
                    ├─────────────────────┤
                    │ Authentication      │
                    │ PostgreSQL           │
                    │ Row Level Security   │
                    │ Storage (optional)   │
                    │ Edge Functions      │
                    │ Cron                │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
              Email Service         Push Services
                 Resend             FCM / Local