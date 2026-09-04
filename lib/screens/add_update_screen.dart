import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AddUpdateScreen extends StatefulWidget {
  final Family family;
  final CareRecipient recipient;

  const AddUpdateScreen({
    super.key,
    required this.family,
    required this.recipient,
  });

  @override
  State<AddUpdateScreen> createState() =>
      _AddUpdateScreenState();
}

class _AddUpdateScreenState
    extends State<AddUpdateScreen> {
  String type = 'appointment';

  final title = TextEditingController();
  final description = TextEditingController();

  DateTime eventDate = DateTime.now();

  bool saving = false;
  String? error;

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      setState(() {
        error = 'Please enter a title.';
      });
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      await SupabaseService(
        Supabase.instance.client,
      ).addEvent(
        familyId: widget.family.id,
        recipientId: widget.recipient.id,
        type: type,
        title: title.text.trim(),
        description:
            description.text.trim().isEmpty
                ? null
                : description.text.trim(),
        eventDate: eventDate,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Could not save update: $e';
      });
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: eventDate,
    );

    if (d == null || !mounted) {
      return;
    }

    final t = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(eventDate),
    );

    if (t == null || !mounted) {
      return;
    }

    setState(() {
      eventDate = DateTime(
        d.year,
        d.month,
        d.day,
        t.hour,
        t.minute,
      );
    });
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Update'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Update for ${widget.recipient.name}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Record something important for the family to remember.',
            style: TextStyle(
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 24),

          _type(
            'Appointment',
            'appointment',
            Icons.calendar_month,
            AppColors.greenSoft,
          ),

          _type(
            'Medication',
            'medication',
            Icons.medication,
            AppColors.lavender,
          ),

          _type(
            'Note',
            'note',
            Icons.note_alt,
            AppColors.yellow,
          ),

          const SizedBox(height: 18),

          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText:
                  'General check-up',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: description,
            maxLines: 5,
            decoration:
                const InputDecoration(
              labelText: 'Notes',
              hintText:
                  'Anything the family should know...',
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: pickDateTime,
            icon: const Icon(
              Icons.schedule,
            ),
            label: Text(
              'Date & time: ${eventDate.toLocal().toString().substring(0, 16)}',
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 16),

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  saving ? null : save,
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
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _type(
    String label,
    String value,
    IconData icon,
    Color bg,
  ) {
    final selected = type == value;

    return Card(
      elevation: 0,
      color: selected ? bg : Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.line,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: AppColors.green,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: Radio<String>(
          value: value,
          groupValue: type,
          onChanged: (newValue) {
            if (newValue == null) return;

            setState(() {
              type = newValue;
            });
          },
        ),
        onTap: () {
          setState(() {
            type = value;
          });
        },
      ),
    );
  }
}