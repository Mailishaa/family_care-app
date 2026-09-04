import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  // ------------------------------------------------------------
  // PROFILE
  // ------------------------------------------------------------

  Future<Profile?> myProfile() async {
    final user = client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final row = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return Profile.fromMap(row);
  }

  // ------------------------------------------------------------
  // FAMILIES
  // ------------------------------------------------------------

  Future<List<Family>> myFamilies() async {
    final user = client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final rows = await client
        .from('family_members')
        .select(
          'family_id, families(id, name, invite_code)',
        )
        .eq('user_id', user.id);

    return (rows as List)
        .map(
          (row) => Family.fromMap(
            row['families'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Family> createFamily(String name) async {
    final row = await client.rpc(
      'create_family',
      params: {
        'family_name':
            name.trim().isEmpty ? 'My Family' : name.trim(),
      },
    );

    return Family.fromMap(
      row as Map<String, dynamic>,
    );
  }

  Future<Family> joinFamily(String code) async {
    final row = await client.rpc(
      'join_family',
      params: {
        'invite_code_input':
            code.trim().toUpperCase(),
      },
    );

    return Family.fromMap(
      row as Map<String, dynamic>,
    );
  }

  // ------------------------------------------------------------
  // CARE RECIPIENTS
  // ------------------------------------------------------------

  Future<List<CareRecipient>> recipients(
    String familyId,
  ) async {
    final rows = await client
        .from('care_recipients')
        .select()
        .eq('family_id', familyId)
        .order('created_at');

    return (rows as List)
        .map(
          (row) => CareRecipient.fromMap(row),
        )
        .toList();
  }

  Future<CareRecipient> addRecipient({
    required String familyId,
    required String name,
    required String relationship,
    String? dateOfBirth,
    String? notes,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to add a person.',
      );
    }

    final row = await client
        .from('care_recipients')
        .insert({
          'family_id': familyId,
          'name': name,
          'relationship':
              relationship.trim().isEmpty
                  ? null
                  : relationship.trim(),
          'date_of_birth': dateOfBirth,
          'notes': notes,
          'created_by': user.id,
        })
        .select()
        .single();

    return CareRecipient.fromMap(row);
  }

  // ------------------------------------------------------------
  // CARE EVENTS
  // ------------------------------------------------------------

  Future<List<CareEvent>> events(
    String recipientId,
  ) async {
    final rows = await client
        .from('care_events')
        .select()
        .eq('recipient_id', recipientId)
        .order(
          'event_date',
          ascending: false,
        );

    return (rows as List)
        .map(
          (row) => CareEvent.fromMap(row),
        )
        .toList();
  }

  Future<void> addEvent({
    required String familyId,
    required String recipientId,
    required String type,
    required String title,
    String? description,
    required DateTime eventDate,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to add an event.',
      );
    }

    await client.from('care_events').insert({
      'family_id': familyId,
      'recipient_id': recipientId,
      'created_by': user.id,
      'event_type': type,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
    });
  }

  // ------------------------------------------------------------
  // REMINDERS
  // ------------------------------------------------------------

  Future<List<Reminder>> reminders(
    String familyId,
  ) async {
    final rows = await client
        .from('reminders')
        .select()
        .eq('family_id', familyId)
        .order('reminder_at');

    return (rows as List)
        .map(
          (row) => Reminder.fromMap(row),
        )
        .toList();
  }

  Future<Reminder> addReminder({
    required String familyId,
    required String recipientId,
    required String title,
    required DateTime reminderAt,
    bool emailEnabled = true,
    bool pushEnabled = true,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to add a reminder.',
      );
    }

    final row = await client
        .from('reminders')
        .insert({
          'family_id': familyId,
          'recipient_id': recipientId,
          'created_by': user.id,
          'title': title,
          'reminder_at':
              reminderAt.toIso8601String(),
          'email_enabled': emailEnabled,
          'push_enabled': pushEnabled,
          'completed': false,
        })
        .select()
        .single();

    return Reminder.fromMap(row);
  }

  Future<void> completeReminder(
    String id,
    bool completed,
  ) async {
    await client
        .from('reminders')
        .update({
          'completed': completed,
        })
        .eq('id', id);
  }

  // ------------------------------------------------------------
  // AUTH
  // ------------------------------------------------------------

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}