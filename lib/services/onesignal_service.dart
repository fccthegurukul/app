// lib/services/onesignal_service.dart

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final _supabase = Supabase.instance.client;

  /// Initialize OneSignal
  Future<void> initialize() async {
    OneSignal.initialize("79fa97c0-00ff-409e-b4c8-bd9004738fcd");

    // Request notification permission
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Login user to OneSignal
  Future<void> loginUser(String authUserId) async {
    await OneSignal.login(authUserId);
  }

  /// Set user tags for targeting
  Future<void> setUserTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
  }

  /// Save player ID to database
  Future<void> savePlayerIdToDb(String authUserId, String playerId) async {
    try {
      await _supabase.from('users').update({
        'onesignal_player_id': playerId,
      }).eq('auth_user_id', authUserId);
    } catch (e) {
      print('Error saving player ID: $e');
    }
  }

  /// Logout user from OneSignal
  Future<void> logout() async {
    await OneSignal.logout();
  }
}
