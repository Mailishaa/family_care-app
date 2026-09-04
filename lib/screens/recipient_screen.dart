import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
import 'add_update_screen.dart';
import 'reminders_screen.dart';

class RecipientScreen extends StatefulWidget {
  final CareRecipient recipient;
  final Family family;

  const RecipientScreen({
    super.key,
    required this.recipient,
    required this.family,
  });

  @override
  State<RecipientScreen> createState() => _RecipientScreenState();
}

class _RecipientScreenState extends State<RecipientScreen> {
  late Future<List<CareEvent>> events;

  @override
  void initState() {
    super.initState();
    events = _loadEvents();
  }

  Future<List<CareEvent>> _loadEvents() {
    return SupabaseService(
      Supabase.instance.client,
    ).events(widget.recipient.id);
  }

  Future<void> addUpdate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddUpdateScreen(
          family: widget.family,
          recipient: widget.recipient,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      events = _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.recipient.name.trim();

    final initial = name.isEmpty
        ? '?'
        : name.substring(0, 1).toUpperCase();

    final relationship = widget.recipient.relationship.trim().isEmpty
        ? 'Family member'
        : widget.recipient.relationship;

    final notes = widget.recipient.notes?.trim();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Edit/settings can be connected later.
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        children: [
          const SizedBox(height: 8),

          // PROFILE PHOTO / INITIAL
          Center(
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.greenSoft,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              name.isEmpty ? 'Unnamed' : name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              '${widget.recipient.age ?? '—'} years • $relationship',
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // LAST / NEXT APPOINTMENT
          _infoCard(
            icon: Icons.event,
            title: 'Last / next appointment',
            subtitle: 'Tap to add an appointment',
            tint: AppColors.pink,
            onTap: addUpdate,
          ),

          // MEDICATION
          _infoCard(
            icon: Icons.medication,
            title: 'Medication',
            subtitle: 'Add medication updates',
            tint: AppColors.lavender,
            onTap: addUpdate,
          ),

          // THINGS TO REMEMBER
          _infoCard(
            icon: Icons.note_alt_outlined,
            title: 'Things to remember',
            subtitle: notes?.isNotEmpty == true
                ? notes!
                : 'Add a note for the family',
            tint: AppColors.yellow,
            onTap: addUpdate,
          ),

          const SizedBox(height: 18),

          // RECENT ACTIVITY
          Row(
            children: [
              const Text(
                'Recent activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: addUpdate,
                child: const Text('Add update'),
              ),
            ],
          ),

          const SizedBox(height: 4),

          FutureBuilder<List<CareEvent>>(
            future: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LinearProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(height: 8),
                      const Text(
                        'Could not load recent activity.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            events = _loadEvents();
                          });
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final list = snapshot.data ?? [];

              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No activity yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                );
              }

              return Column(
                children: list.take(6).map((event) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.greenSoft,
                      child: Icon(
                        Icons.check,
                        color: AppColors.green,
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy • HH:mm',
                      ).format(event.eventDate),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          // REMINDERS
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RemindersScreen(
                    family: widget.family,
                    selectedRecipient: widget.recipient,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
            ),
            label: const Text(
              'View reminders',
            ),
          ),

          const SizedBox(height: 12),

          // ADD UPDATE
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: addUpdate,
              icon: const Icon(Icons.add),
              label: const Text('Add update'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  color: AppColors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}