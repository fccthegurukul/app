// lib/services/user_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  /// Update user profile during onboarding or later
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? city,
    String? studentClass,
    String? board,
    String? medium,
    List<String>? subjects,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add only non-null and non-empty values
      if (fullName?.isNotEmpty ?? false) updates['full_name'] = fullName;
      if (phone?.isNotEmpty ?? false) updates['phone'] = phone;
      if (city?.isNotEmpty ?? false) updates['city'] = city;
      if (studentClass?.isNotEmpty ?? false) updates['student_class'] = studentClass;
      if (board?.isNotEmpty ?? false) updates['board'] = board;
      if (medium?.isNotEmpty ?? false) updates['medium'] = medium;
      if (subjects != null && subjects.isNotEmpty) updates['subjects'] = subjects;

      // Prevent accidental empty updates
      if (updates.keys.length <= 1) {
        throw Exception('No valid fields provided for update.');
      }

      await _supabase
          .from('user_profiles')
          .update(updates)
          .eq('user_id', userId);
    } catch (error) {
      print('Error updating user profile: $error');
      rethrow;
    }
  }

  /// Fetch a single user profile by userId
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      return data;
    } catch (error) {
      print('Error fetching user profile: $error');
      return null;
    }
  }
}
