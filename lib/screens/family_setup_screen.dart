import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'home_screen.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final familyName = TextEditingController(text: "Malisha's Family");
  final inviteCode = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> createFamily() async {
    setState(() { loading = true; error = null; });
    try {
      final family = await SupabaseService(Supabase.instance.client)
          .createFamily(familyName.text);
      if (!mounted) return;
      await _showCode(family);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(family: family)),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> joinFamily() async {
    setState(() { loading = true; error = null; });
    try {
      final family = await SupabaseService(Supabase.instance.client)
          .joinFamily(inviteCode.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(family: family)),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _showCode(Family family) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Family created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with your family members.'),
            const SizedBox(height: 18),
            SelectableText(
              family.inviteCode,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 5),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    familyName.dispose();
    inviteCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your family')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create or join a family', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Everyone who joins can see the shared care timeline and reminders.', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 28),
                TextField(controller: familyName, decoration: const InputDecoration(labelText: 'Family name')),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading ? null : createFamily,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Create family'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR')), Expanded(child: Divider())]),
                ),
                TextField(
                  controller: inviteCode,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Family invite code', hintText: 'e.g. A1B2C3'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: loading ? null : joinFamily,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Join family'),
                  ),
                ),
                if (error != null) Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
