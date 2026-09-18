import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      showMessage('Please enter your full name.');
      return;
    }

    if (name.length < 2) {
      showMessage('Please enter a valid name.');
      return;
    }

    if (email.isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter a password.');
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    if (confirmPassword != password) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session != null) {
        context.go('/home');
      } else {
        showMessage(
          'Account created! Check your email to verify your account.',
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: loading
                        ? null
                        : () {
                            context.go('/login');
                          },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Temporary logo.
                  // We will replace this with the real
                  // SaiClubs logo later.
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join the SaiClubs community.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: nameController,
                    enabled: !loading,
                    textCapitalization:
                        TextCapitalization.words,
                    textInputAction:
                        TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.name,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    enabled: !loading,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    enabled: !loading,
                    obscureText: obscurePassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon: IconButton(
                        tooltip: obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller:
                        confirmPasswordController,
                    enabled: !loading,
                    obscureText:
                        obscureConfirmPassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!loading) {
                        signup();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon: IconButton(
                        tooltip: obscureConfirmPassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : signup,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create account',
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () {
                                context.go('/login');
                              },
                        child: const Text(
                          'Sign in',
                        ),
                      ),
                    ],
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