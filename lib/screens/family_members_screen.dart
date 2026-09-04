import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../theme.dart';

class FamilyMembersScreen extends StatelessWidget {
  final Family family;
  const FamilyMembersScreen({super.key, required this.family});

  Future<List<Map<String, dynamic>>> load() async {
    final rows = await Supabase.instance.client
        .from('family_members')
        .select('role, profiles(full_name,email,phone)')
        .eq('family_id', family.id);
    return (rows as List).map((r) => Map<String, dynamic>.from(r)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family members')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: load(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  const Text('Invite code', style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 6),
                  SelectableText(family.inviteCode, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4)),
                ]),
              ),
              const SizedBox(height: 20),
              ...rows.map((r) {
                final p = r['profiles'] as Map<String, dynamic>;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text((p['full_name'] ?? 'Family member') as String),
                  subtitle: Text((p['email'] ?? '') as String),
                  trailing: Text((r['role'] ?? '') as String),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
