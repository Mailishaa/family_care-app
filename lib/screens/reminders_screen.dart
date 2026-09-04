import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';

class RemindersScreen extends StatefulWidget {
  final Family family;
  final CareRecipient? selectedRecipient;

  const RemindersScreen({
    super.key,
    required this.family,
    this.selectedRecipient,
  });

  @override
  State<RemindersScreen> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState
    extends State<RemindersScreen> {
  late Future<List<Reminder>> future;
  CareRecipient? selected;

  bool emailEnabled = true;
  bool pushEnabled = true;
  bool saving = false;

  final title = TextEditingController();

  DateTime remindAt =
      DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();

    selected = widget.selectedRecipient;
    future = _load();
  }

  Future<List<Reminder>> _load() {
    return SupabaseService(
      Supabase.instance.client,
    ).reminders(widget.family.id);
  }

  Future<List<CareRecipient>> _loadPeople() {
    return SupabaseService(
      Supabase.instance.client,
    ).recipients(widget.family.id);
  }

  Future<void> addReminder() async {
    if (selected == null) {
      _showError('Please select a person.');
      return;
    }

    if (title.text.trim().isEmpty) {
      _showError('Please enter a reminder.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final reminder =
          await SupabaseService(
        Supabase.instance.client,
      ).addReminder(
        familyId: widget.family.id,
        recipientId: selected!.id,
        title: title.text.trim(),
        reminderAt: remindAt,
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
      );

      if (pushEnabled) {
        await NotificationService.instance.schedule(
          id: reminder.id.hashCode,
          title: 'Family Care reminder',
          body:
              '${selected!.name}: ${reminder.title}',
          when: reminder.reminderAt,
        );
      }

      if (!mounted) return;

      setState(() {
        future = _load();
        title.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not save reminder: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Future<void> pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: remindAt,
    );

    if (d == null || !mounted) {
      return;
    }

    final t = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(remindAt),
    );

    if (t == null || !mounted) {
      return;
    }

    setState(() {
      remindAt = DateTime(
        d.year,
        d.month,
        d.day,
        t.hour,
        t.minute,
      );
    });
  }

  Future<void> completeReminder(
    Reminder reminder,
    bool completed,
  ) async {
    try {
      await SupabaseService(
        Supabase.instance.client,
      ).completeReminder(
        reminder.id,
        completed,
      );

      if (!completed) {
        await NotificationService.instance.schedule(
          id: reminder.id.hashCode,
          title: 'Family Care reminder',
          body: reminder.title,
          when: reminder.reminderAt,
        );
      } else {
        await NotificationService.instance.cancel(
          reminder.id.hashCode,
        );
      }

      if (!mounted) return;

      setState(() {
        future = _load();
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not update reminder: $e',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keep track of appointments, medication and other important care tasks.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (widget.selectedRecipient == null)
            FutureBuilder<List<CareRecipient>>(
              future: _loadPeople(),
              builder: (context, snapshot) {
                if (snapshot.connectionState !=
                    ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Could not load people: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  );
                }

                final people =
                    snapshot.data ?? [];

                if (people.isEmpty) {
                  return const Text(
                    'Add a person to your family before creating a reminder.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  initialValue: selected?.id,
                  decoration:
                      const InputDecoration(
                    labelText: 'Person',
                  ),
                  items: people
                      .map(
                        (person) =>
                            DropdownMenuItem<String>(
                          value: person.id,
                          child:
                              Text(person.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;

                    setState(() {
                      selected = people.firstWhere(
                        (person) =>
                            person.id == id,
                      );
                    });
                  },
                );
              },
            ),

          if (selected != null) ...[
            const SizedBox(height: 12),
            Text(
              'For: ${selected!.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 14),

          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Reminder',
              hintText: 'General check-up',
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: pickDateTime,
            icon: const Icon(
              Icons.calendar_month,
            ),
            label: Text(
              DateFormat(
                'dd MMM yyyy • HH:mm',
              ).format(remindAt),
            ),
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title:
                const Text('Email reminder'),
            subtitle: const Text(
              'Send an email reminder when this is due.',
            ),
            value: emailEnabled,
            onChanged: (value) {
              setState(() {
                emailEnabled = value;
              });
            },
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title:
                const Text('App notification'),
            subtitle: const Text(
              'Show a notification on supported devices.',
            ),
            value: pushEnabled,
            onChanged: (value) {
              setState(() {
                pushEnabled = value;
              });
            },
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  saving ? null : addReminder,
              style: FilledButton.styleFrom(
                backgroundColor:
                    AppColors.green,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save reminder',
                    ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Upcoming',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          FutureBuilder<List<Reminder>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState !=
                  ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Could not load reminders:\n${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                );
              }

              final list =
                  snapshot.data ?? [];

              if (list.isEmpty) {
                return const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Text(
                    'No reminders yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                );
              }

              return Column(
                children: list
                    .map(
                      (reminder) => Card(
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          side:
                              const BorderSide(
                            color:
                                AppColors.line,
                          ),
                        ),
                        child:
                            CheckboxListTile(
                          value:
                              reminder.completed,
                          onChanged:
                              (value) {
                            if (value == null) {
                              return;
                            }

                            completeReminder(
                              reminder,
                              value,
                            );
                          },
                          title: Text(
                            reminder.title,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd MMM yyyy • HH:mm',
                            ).format(
                              reminder
                                  .reminderAt,
                            ),
                          ),
                          secondary:
                              const Icon(
                            Icons
                                .notifications_none,
                            color:
                                AppColors.green,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}