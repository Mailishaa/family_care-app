import 'package:flutter/material.dart';

import '../theme.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  left: -35,
                  bottom: 90,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.greenSoft,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    44,
                    24,
                    24,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),

                      // ------------------------------------------------
                      // APP ICON
                      // ------------------------------------------------

                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.green,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // APP NAME
                      // ------------------------------------------------

                      const Text(
                        'Family Care',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ------------------------------------------------
                      // TAGLINE
                      // ------------------------------------------------

                      const Text(
                        'Stay connected.\nTake better care.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // DESCRIPTION
                      // ------------------------------------------------

                      const Text(
                        'A simple way to keep track of appointments, '
                        'care updates and important notes for your loved ones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ------------------------------------------------
                      // ILLUSTRATION AREA
                      // ------------------------------------------------

                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F0E8),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.diversity_1_rounded,
                            size: 90,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ------------------------------------------------
                      // GET STARTED
                      // ------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(
                                  createAccount: true,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // LOGIN
                      // ------------------------------------------------

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AuthScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Log In',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}