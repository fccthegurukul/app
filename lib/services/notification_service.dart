import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  SupabaseClient get supabase => Supabase.instance.client; // ✅


  // ==========================================
  // NOTIFICATION OPERATIONS
  // ==========================================

  /// Record notification sent
  Future<void> recordNotificationSent({
    required String userId,
    required String channel,
    required String subject,
    required String body,
    String? campaignId,
    String? templateId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'channel': channel,
        'subject': subject,
        'body': body,
        'campaign_id': campaignId,
        'template_id': templateId,
        'status': 'sent',
        'sent_at': DateTime.now().toIso8601String(),
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Notification recorded');
    } catch (e) {
      print('❌ Failed to record notification: $e');
    }
  }

  /// Record notification opened
  Future<void> recordNotificationOpened(String notificationId) async {
    try {
      await supabase.from('notifications').update({
        'status': 'opened',
        'opened_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);

      print('✅ Notification opened recorded');
    } catch (e) {
      print('❌ Failed to record opened: $e');
    }
  }

  /// Get user's notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(
      String userId, {
        int limit = 20,
      }) async {
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Failed to get notifications: $e');
      return [];
    }
  }
}
