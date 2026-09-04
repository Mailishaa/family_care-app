import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';

import 'family_setup_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool createAccount;

  const AuthScreen({
    super.key,
    this.createAccount = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool creating;

  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final nationalId = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    creating = widget.createAccount;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    nationalId.dispose();
    password.dispose();
    confirm.dispose();

    super.dispose();
  }


  // ==========================================================
  // AFTER LOGIN
  // ==========================================================

  Future<void> _goToApp() async {
    if (!mounted) return;

    final client = Supabase.instance.client;

    try {
      final families =
          await SupabaseService(client).myFamilies();

      if (!mounted) return;

      // --------------------------------------------------------
      // NO FAMILY YET
      // --------------------------------------------------------

      if (families.isEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const FamilySetupScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // --------------------------------------------------------
      // FAMILY EXISTS
      // --------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            family: families.first,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Could not load your family: $e';
      });
    }
  }


  // ==========================================================
  // SUBMIT
  // ==========================================================

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final auth = Supabase.instance.client.auth;

      // ======================================================
      // CREATE ACCOUNT
      // ======================================================

      if (creating) {
        final response = await auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {
            'full_name': name.text.trim(),
            'phone': phone.text.trim(),
            'national_id': nationalId.text.trim(),
          },
        );

        if (!mounted) return;

        // ----------------------------------------------------
        // Email confirmation required
        // ----------------------------------------------------

        if (response.user != null && response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created. Please check your email and confirm your account before logging in.',
              ),
              duration: Duration(seconds: 6),
            ),
          );

          setState(() {
            creating = false;
            loading = false;
          });

          return;
        }

        // ----------------------------------------------------
        // Account created and session available
        // ----------------------------------------------------

        await _goToApp();

        return;
      }


      // ======================================================
      // LOGIN
      // ======================================================

      await auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );

      if (!mounted) return;

      // The important part:
      // explicitly move the user into the application.
      await _goToApp();

    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Something went wrong: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }


  // ==========================================================
  // VALIDATION
  // ==========================================================

  String? requiredField(
    String? value,
    String label,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters';
    }

    return null;
  }


  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          creating ? 'Create account' : 'Log in',
        ),
        backgroundColor: Colors.transparent,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              30,
            ),

            child: Form(
              key: formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    creating
                        ? 'Create your Family Care account'
                        : 'Welcome back',

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    creating
                        ? 'Your account lets your family share care updates securely.'
                        : 'Sign in to see your family care timeline.',

                    style: const TextStyle(
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 26),


                  // ==================================================
                  // CREATE ACCOUNT FIELDS
                  // ==================================================

                  if (creating) ...[
                    TextFormField(
                      controller: name,

                      decoration: const InputDecoration(
                        labelText: 'Full name',
                      ),

                      validator: (v) =>
                          requiredField(v, 'Full name'),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: phone,

                      keyboardType:
                          TextInputType.phone,

                      decoration:
                          const InputDecoration(
                        labelText: 'Phone number',
                        hintText:
                            '+254 7xx xxx xxx',
                      ),

                      validator: (v) =>
                          requiredField(
                            v,
                            'Phone number',
                          ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: nationalId,

                      keyboardType:
                          TextInputType.number,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'National ID number',
                        helperText:
                            'Optional — only add this if your family needs it.',
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],


                  // ==================================================
                  // EMAIL
                  // ==================================================

                  TextFormField(
                    controller: email,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration:
                        const InputDecoration(
                      labelText: 'Email address',
                    ),

                    validator: validateEmail,
                  ),

                  const SizedBox(height: 14),


                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  TextFormField(
                    controller: password,

                    obscureText: true,

                    decoration:
                        const InputDecoration(
                      labelText: 'Password',
                    ),

                    validator: validatePassword,
                  ),


                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================

                  if (creating) ...[
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: confirm,

                      obscureText: true,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Confirm password',
                      ),

                      validator: (v) {
                        if (v != password.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),
                  ],


                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (error != null) ...[
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(12),

                      decoration:
                          BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.08,
                        ),

                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: Text(
                        error!,

                        style:
                            const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],


                  const SizedBox(height: 24),


                  // ==================================================
                  // MAIN BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton(
                      onPressed:
                          loading ? null : submit,

                      style:
                          FilledButton.styleFrom(
                        backgroundColor:
                            AppColors.green,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                      ),

                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : Text(
                              creating
                                  ? 'Create account'
                                  : 'Log in',
                            ),
                    ),
                  ),


                  const SizedBox(height: 8),


                  // ==================================================
                  // SWITCH LOGIN / CREATE ACCOUNT
                  // ==================================================

                  Center(
                    child: TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                creating = !creating;
                                error = null;
                              });
                            },

                      child: Text(
                        creating
                            ? 'Already have an account? Log in'
                            : 'Need an account? Create one',
                      ),
                    ),
                  ),


                  // ==================================================
                  // PRIVACY NOTE
                  // ==================================================

                  if (creating)
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 10),

                      child: Text(
                        'Privacy note: national ID is sensitive personal information. Keep it optional unless you have a clear, lawful reason to collect it, and restrict access in Supabase.',

                        style: TextStyle(
                          fontSize: 12,
                          color:
                              AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}