// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  /// Sign Up - Creates auth user + user row + profile
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    // 1. Create auth user
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    final userId = response.user!.id;

    // 2. Create user row
    await _supabase.from('users').insert({
      'auth_user_id': userId,
      'email': email,
    });

    // 3. Get the created user's DB id
    final userRow = await _supabase
        .from('users')
        .select('id')
        .eq('auth_user_id', userId)
        .single();

    final dbUserId = userRow['id'] as String;

    // 4. Create user profile
    await _supabase.from('user_profiles').insert({
      'user_id': dbUserId,
      'full_name': fullName,
      'phone': phone,
      'is_onboarding_completed': false,
      'profile_completion_percentage': 30,
    });

    return response;
  }

  /// Check if user has completed onboarding
  Future<bool> checkOnboardingStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final userRow = await _supabase
          .from('users')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      final profile = await _supabase
          .from('user_profiles')
          .select('is_onboarding_completed')
          .eq('user_id', userRow['id'])
          .maybeSingle();

      return profile?['is_onboarding_completed'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
