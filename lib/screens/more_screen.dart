import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import 'reminders_screen.dart';
import 'family_members_screen.dart';

class MoreScreen extends StatelessWidget {
  final Family family;
  const MoreScreen({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text('More', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        _tile(context, Icons.group_outlined, 'Family members', 'See who is connected', () => Navigator.push(context, MaterialPageRoute(builder: (_) => FamilyMembersScreen(family: family)))),
        _tile(context, Icons.notifications_none, 'Notifications', 'Allow reminders on this device', () async {
          await NotificationService.instance.requestPermission();
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification permission requested.')));
        }),
        _tile(context, Icons.help_outline, 'Help & support', 'How Family Care works', () => _help(context)),
        _tile(context, Icons.settings_outlined, 'Settings', 'Account and privacy', () => _settings(context)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.favorite, color: AppColors.green),
            SizedBox(width: 12),
            Expanded(child: Text('Better care starts with staying connected.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700))),
          ]),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.line)),
    child: ListTile(
      leading: Icon(icon, color: AppColors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );

  void _help(BuildContext context) => showDialog(context: context, builder: (_) => const AlertDialog(
    title: Text('Family Care'),
    content: Text('Use Family Care to share appointments, medication updates, notes, check-ins and reminders with trusted family members. It is a coordination tool, not a diagnosis service.'),
  ));

  void _settings(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(children: [
        const ListTile(title: Text('Account & privacy', style: TextStyle(fontWeight: FontWeight.w800))),
        const ListTile(leading: Icon(Icons.lock_outline), title: Text('Keep sensitive information limited to trusted family members.')),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          onTap: () async {
            Navigator.pop(context);
            await SupabaseService(Supabase.instance.client).signOut();
          },
        ),
      ]),
    ),
  );
}
