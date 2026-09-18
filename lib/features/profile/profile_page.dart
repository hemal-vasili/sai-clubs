import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool saving = false;

  Map<String, dynamic>? profile;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        profile = data;

        nameController.text =
            data['full_name']?.toString() ?? '';

        usernameController.text =
            data['username']?.toString() ?? '';

        bioController.text =
            data['bio']?.toString() ?? '';

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'Unable to load your profile.',
      );
    }
  }

  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final bio = bioController.text.trim();

    if (name.isEmpty) {
      showMessage('Name cannot be empty.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final updated = await supabase
          .from('profiles')
          .update({
            'full_name': name,
            'username':
                username.isEmpty ? null : username,
            'bio': bio.isEmpty ? null : bio,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id)
          .select()
          .single();

      if (!mounted) return;

      setState(() {
        profile = updated;
      });

      showMessage('Profile updated successfully.');
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to update your profile.',
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    context.go('/login');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final user = supabase.auth.currentUser;

    final email =
        profile?['university_email']?.toString() ??
            user?.email ??
            '';

    final role =
        profile?['user_role']?.toString() ??
            'student';

    final avatarUrl =
        profile?['avatar_url']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profile',
                style:
                    theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Manage your SaiClubs profile.',
                style:
                    theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // Profile header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor:
                            theme.colorScheme.primary,
                        backgroundImage:
                            avatarUrl != null &&
                                    avatarUrl.isNotEmpty
                                ? NetworkImage(
                                    avatarUrl,
                                  )
                                : null,
                        child:
                            avatarUrl == null ||
                                    avatarUrl.isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 42,
                                    color:
                                        Colors.white,
                                  )
                                : null,
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameController
                                  .text
                                  .isEmpty
                                  ? 'Student'
                                  : nameController.text,
                              style: theme
                                  .textTheme
                                  .titleLarge,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              email,
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: theme
                                    .colorScheme
                                    .primary
                                    .withValues(
                                      alpha: 0.10,
                                    ),
                                borderRadius:
                                    BorderRadius
                                        .circular(20),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .primary,
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Personal information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Personal information',
                        style: theme
                            .textTheme
                            .titleLarge,
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller:
                            nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration:
                            const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            usernameController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            bioController,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(
                          labelText: 'Bio',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              saving
                                  ? null
                                  : saveProfile,
                          child: saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save changes',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Account section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Account',
                        style: theme
                            .textTheme
                            .titleLarge,
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.email_outlined,
                        ),
                        title: const Text(
                          'University email',
                        ),
                        subtitle: Text(email),
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.logout_rounded,
                        ),
                        title: const Text(
                          'Sign out',
                        ),
                        onTap: signOut,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}