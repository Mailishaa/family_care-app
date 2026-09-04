import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'theme.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

import 'screens/welcome_screen.dart';
import 'screens/family_setup_screen.dart';
import 'screens/home_screen.dart';

import 'models/app_models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  await NotificationService.instance.initialize();

  runApp(
    const FamilyCareApp(),
  );
}

class FamilyCareApp extends StatelessWidget {
  const FamilyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Care',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppRoot(),
    );
  }
}


// ============================================================
// APP ROOT
// ============================================================
//
// Supabase automatically persists the authentication session.
//
// When the app starts:
//   - no session -> Welcome
//   - session + no family -> Family Setup
//   - session + family -> Home
//
// Authentication changes are listened to here.
// ============================================================

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final SupabaseClient client;
  late final Stream<AuthState> authStream;

  bool loading = true;
  List<Family> families = [];
  String? error;

  @override
  void initState() {
    super.initState();

    client = Supabase.instance.client;
    authStream = client.auth.onAuthStateChange;

    // Load the persisted session when the app starts.
    _loadApp();

    // Listen for login/logout/session changes.
    authStream.listen(_onAuthStateChange);
  }

  Future<void> _onAuthStateChange(AuthState state) async {
    if (!mounted) return;

    switch (state.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.tokenRefreshed:
        await _loadApp();
        break;

      default:
        break;
    }
  }

  Future<void> _loadApp() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final session = client.auth.currentSession;

      // --------------------------------------------------------
      // NOT LOGGED IN
      // --------------------------------------------------------

      if (session == null) {
        if (!mounted) return;

        setState(() {
          families = [];
          loading = false;
        });

        return;
      }

      // --------------------------------------------------------
      // LOGGED IN
      // --------------------------------------------------------

      final loadedFamilies =
          await SupabaseService(client).myFamilies();

      if (!mounted) return;

      setState(() {
        families = loadedFamilies;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // Loading
    // ----------------------------------------------------------

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ----------------------------------------------------------
    // Error
    // ----------------------------------------------------------

    if (error != null) {
      return ErrorScreen(
        message: error!,
        onRetry: _loadApp,
      );
    }

    // ----------------------------------------------------------
    // Check current persisted session
    // ----------------------------------------------------------

    final session = client.auth.currentSession;

    // ----------------------------------------------------------
    // NOT LOGGED IN
    // ----------------------------------------------------------

    if (session == null) {
      return const WelcomeScreen();
    }

    // ----------------------------------------------------------
    // LOGGED IN BUT NO FAMILY
    // ----------------------------------------------------------

    if (families.isEmpty) {
      return const FamilySetupScreen();
    }

    // ----------------------------------------------------------
    // LOGGED IN + FAMILY
    // ----------------------------------------------------------

    return HomeScreen(
      family: families.first,
    );
  }
}


// ============================================================
// ERROR SCREEN
// ============================================================

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
              ),

              const SizedBox(height: 16),

              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              SelectableText(
                message,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}