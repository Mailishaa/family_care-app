class Profile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String nationalId;

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationalId,
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    return Profile(
      id: m['id'] as String,
      fullName: (m['full_name'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      phone: (m['phone'] ?? '') as String,
      nationalId: (m['national_id'] ?? '') as String,
    );
  }
}

class Family {
  final String id;
  final String name;
  final String inviteCode;

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
  });

  factory Family.fromMap(Map<String, dynamic> m) {
    return Family(
      id: m['id'] as String,
      name: (m['name'] ?? '') as String,
      inviteCode: (m['invite_code'] ?? '') as String,
    );
  }
}

class CareRecipient {
  final String id;
  final String familyId;
  final String name;
  final String relationship;
  final DateTime? dateOfBirth;
  final String? notes;

  const CareRecipient({
    required this.id,
    required this.familyId,
    required this.name,
    required this.relationship,
    this.dateOfBirth,
    this.notes,
  });

  /// Calculates the person's current age from their date of birth.
  int? get age {
    if (dateOfBirth == null) {
      return null;
    }

    final today = DateTime.now();

    int years = today.year - dateOfBirth!.year;

    final birthdayThisYear = DateTime(
      today.year,
      dateOfBirth!.month,
      dateOfBirth!.day,
    );

    if (today.isBefore(birthdayThisYear)) {
      years--;
    }

    return years;
  }

  factory CareRecipient.fromMap(Map<String, dynamic> m) {
    DateTime? parsedDateOfBirth;

    final rawDate = m['date_of_birth'];

    if (rawDate != null && rawDate.toString().isNotEmpty) {
      parsedDateOfBirth = DateTime.tryParse(
        rawDate.toString(),
      );
    }

    return CareRecipient(
      id: m['id'] as String,
      familyId: m['family_id'] as String,
      name: (m['name'] ?? '') as String,
      relationship: (m['relationship'] ?? '') as String,
      dateOfBirth: parsedDateOfBirth,
      notes: m['notes'] as String?,
    );
  }
}

class CareEvent {
  final String id;
  final String familyId;
  final String recipientId;
  final String type;
  final String title;
  final String? description;
  final DateTime eventDate;

  const CareEvent({
    required this.id,
    required this.familyId,
    required this.recipientId,
    required this.type,
    required this.title,
    this.description,
    required this.eventDate,
  });

  factory CareEvent.fromMap(Map<String, dynamic> m) {
    return CareEvent(
      id: m['id'] as String,
      familyId: m['family_id'] as String,
      recipientId: m['recipient_id'] as String,
      type: (m['event_type'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      description: m['description'] as String?,
      eventDate: DateTime.parse(
        m['event_date'] as String,
      ),
    );
  }
}

class Reminder {
  final String id;
  final String familyId;
  final String recipientId;
  final String title;
  final DateTime reminderAt;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool completed;

  const Reminder({
    required this.id,
    required this.familyId,
    required this.recipientId,
    required this.title,
    required this.reminderAt,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.completed,
  });

  factory Reminder.fromMap(Map<String, dynamic> m) {
    return Reminder(
      id: m['id'] as String,
      familyId: m['family_id'] as String,
      recipientId: m['recipient_id'] as String,
      title: (m['title'] ?? '') as String,
      reminderAt: DateTime.parse(
        m['reminder_at'] as String,
      ),
      emailEnabled: m['email_enabled'] as bool? ?? true,
      pushEnabled: m['push_enabled'] as bool? ?? true,
      completed: m['completed'] as bool? ?? false,
    );
  }
}