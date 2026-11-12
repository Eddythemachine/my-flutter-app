import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_theme.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/utils/verification_cooldown.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  double _buttonScale = 1.0;
  bool _isCheckingStatus = false;

  // ⏱️ Countdown state
  Timer? _countdownTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    // Pick up any cooldown already started on RegisterView
    _syncWithCooldown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _syncWithCooldown() {
    final remaining = VerificationCooldown.remainingSeconds;
    if (remaining > 0) {
      setState(() => _secondsLeft = remaining);
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = VerificationCooldown.remainingSeconds;
      setState(() => _secondsLeft = remaining);
      if (remaining <= 0) {
        timer.cancel();
        _countdownTimer = null;
      }
    });
  }

  Future<void> _sendVerification() async {
    if (!VerificationCooldown.canSend) {
      _syncWithCooldown();
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      VerificationCooldown.markSent();

      if (!mounted) return;
      setState(() => _secondsLeft = VerificationCooldown.remainingSeconds);
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.deep, // 🎨 Themed
          content: Text(
            "Verification email sent! Check your inbox.",
            style: TextStyle(color: AppTheme.primary),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error, // 🎨 Themed
          content: Text("Could not send verification email: $e"),
        ),
      );
    }
  }

  // ✅ Check if the user has clicked the link in their email
  Future<void> _checkVerificationStatus() async {
    setState(() => _isCheckingStatus = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Force Firebase to fetch the latest data from the server
      await user?.reload();

      // Read the newly updated status
      final isVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;

      if (!mounted) return;

      if (isVerified) {
        // Success! Go to notes
        Navigator.pushNamedAndRemoveUntil(
          context,
          notesRoute,
          (route) => false,
        );
      } else {
        // Not verified yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.warning, // 🎨 Themed
            content: Text(
              "Email not verified yet. Please check your inbox.",
              style: TextStyle(color: AppTheme.dark),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error,
          content: Text("Error checking status: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onCooldown = _secondsLeft > 0;
    final buttonLabel = onCooldown
        ? "Wait ${_secondsLeft}s…"
        : "Send Email Verification";

    return Material(
      child: Container(
        // 🎨 Shared gradient
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 20),
                  // 🎨 Shared text styles
                  const Text("Verify Your Email", style: AppTheme.heading),
                  const SizedBox(height: 12),
                  const Text(
                    "We sent a verification link to your email address. "
                    "Please check your inbox to continue.",
                    textAlign: TextAlign.center,
                    style: AppTheme.body,
                  ),
                  const SizedBox(height: 32),

                  // ✅ I've Verified Button
                  GestureDetector(
                    onTap: _isCheckingStatus ? null : _checkVerificationStatus,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusField,
                        ),
                        boxShadow: AppTheme.buttonShadow,
                      ),
                      alignment: Alignment.center,
                      child: _isCheckingStatus
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.dark,
                                ),
                              ),
                            )
                          : const Text(
                              "I've Verified My Email",
                              style: TextStyle(
                                color: AppTheme.dark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📨 Resend button with live countdown
                  GestureDetector(
                    onTapDown: (_) {
                      if (!onCooldown) setState(() => _buttonScale = 0.95);
                    },
                    onTapUp: (_) {
                      if (!onCooldown) setState(() => _buttonScale = 1.0);
                    },
                    onTapCancel: () => setState(() => _buttonScale = 1.0),
                    onTap: onCooldown ? null : _sendVerification,
                    child: AnimatedScale(
                      scale: _buttonScale,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: onCooldown
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusField,
                          ),
                          border: Border.all(
                            color: onCooldown
                                ? Colors.white24
                                : AppTheme.primary,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (onCooldown) ...[
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              buttonLabel,
                              style: TextStyle(
                                color: onCooldown
                                    ? Colors.white54
                                    : AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ⏱️ Countdown line under the button
                  if (onCooldown) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "You can resend in ${_secondsLeft}s",
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 🔙 Back to register
                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        registerRoute,
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.muted,
                      size: 18,
                    ),
                    label: const Text(
                      "Go back and use a different email",
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
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
