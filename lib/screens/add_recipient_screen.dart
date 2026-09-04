import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AddRecipientScreen extends StatefulWidget {
  final Family family;

  const AddRecipientScreen({
    super.key,
    required this.family,
  });

  @override
  State<AddRecipientScreen> createState() =>
      _AddRecipientScreenState();
}

class _AddRecipientScreenState
    extends State<AddRecipientScreen> {
  final name = TextEditingController();
  final relationship = TextEditingController();
  final dateOfBirth = TextEditingController();
  final notes = TextEditingController();

  bool loading = false;
  String? error;

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      setState(() {
        error = 'Please enter the person\'s name.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await SupabaseService(
        Supabase.instance.client,
      ).addRecipient(
        familyId: widget.family.id,
        name: name.text.trim(),
        relationship: relationship.text.trim(),
        dateOfBirth: _parseDateOfBirth(),
        notes: notes.text.trim().isEmpty
            ? null
            : notes.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Could not add person: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String? _parseDateOfBirth() {
    final value = dateOfBirth.text.trim();

    if (value.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return null;
    }

    return parsed.toIso8601String().split('T').first;
  }

  @override
  void dispose() {
    name.dispose();
    relationship.dispose();
    dateOfBirth.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add person'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Add someone your family cares for',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Add a family member or loved one whose care you want to keep track of.',
            style: TextStyle(
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Mum, Dad, John...',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: relationship,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Relationship',
              hintText: 'Mother, Father, Brother...',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: dateOfBirth,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Date of birth (optional)',
              hintText: 'YYYY-MM-DD',
              helperText: 'Example: 1985-06-24',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: notes,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Things to remember',
              hintText:
                  'Important information your family should remember...',
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save person'),
            ),
          ),
        ],
      ),
    );
  }
}