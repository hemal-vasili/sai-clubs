import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
      },
    );
  }

  static Future<void> signOut() {
    return _supabase.auth.signOut();
  }

  static User? get currentUser =>
      _supabase.auth.currentUser;

  static Session? get currentSession =>
      _supabase.auth.currentSession;
}