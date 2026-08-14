import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _announcementsChannel;
  RealtimeChannel? _tugasChannel;
  RealtimeChannel? _materiChannel;

  bool _isInitialized = false;
  final DateTime _initTimestamp = DateTime.now();

  /// Initialize Local Notifications plugin & permissions
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification clicked with payload: ${response.payload}');
          }
        },
      );

      // Request Android 13+ permission
      final androidImpl = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService init error (memerlukan rebuild/restart aplikasi untuk mendaftarkan native plugin baru): $e');
      }
    }

    // Start listening to Supabase Realtime updates
    startRealtimeListeners();
  }

  /// Display a local device notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Skipping notification because plugin native is not initialized: $title - $body');
      }
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'edu_school_channel',
        'EduSchool Notifications',
        channelDescription: 'Notifikasi pengumuman, tugas, dan materi perkuliahan baru',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
    }
  }

  /// Setup Supabase Realtime listeners for Pengumuman, Tugas, and Materi
  void startRealtimeListeners() {
    // 1. Listen for new Pengumuman
    _announcementsChannel?.unsubscribe();
    _announcementsChannel = _supabase
        .channel('public:pengumuman_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'pengumuman',
          callback: (payload) {
            final record = payload.newRecord;
            final createdAtStr = record['created_at'] as String?;
            if (_isNewItem(createdAtStr)) {
              final judul = record['judul'] as String? ?? 'Pengumuman Baru';
              final isi = record['isi'] as String? ?? (record['deskripsi'] as String? ?? 'Silakan cek pengumuman terbaru di aplikasi.');
              showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: '📢 Pengumuman Baru: $judul',
                body: isi,
                payload: 'pengumuman',
              );
            }
          },
        )
        .subscribe();

    // 2. Listen for new Tugas Kuliah
    _tugasChannel?.unsubscribe();
    _tugasChannel = _supabase
        .channel('public:tugas_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tugas',
          callback: (payload) {
            final record = payload.newRecord;
            final createdAtStr = record['created_at'] as String?;
            if (_isNewItem(createdAtStr)) {
              final judul = record['judul_tugas'] as String? ?? (record['judul'] as String? ?? 'Tugas Baru');
              final deskripsi = record['deskripsi'] as String? ?? 'Tugas kuliah baru telah ditambahkan.';
              showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
                title: '📝 Tugas Kuliah Baru: $judul',
                body: deskripsi,
                payload: 'tugas',
              );
            }
          },
        )
        .subscribe();

    // 3. Listen for new Materi Kuliah
    _materiChannel?.unsubscribe();
    _materiChannel = _supabase
        .channel('public:materi_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'materi',
          callback: (payload) {
            final record = payload.newRecord;
            final createdAtStr = record['created_at'] as String?;
            if (_isNewItem(createdAtStr)) {
              final judul = record['judul_materi'] as String? ?? (record['judul'] as String? ?? 'Materi Baru');
              final deskripsi = record['deskripsi'] as String? ?? 'Materi pembelajaran baru telah diunggah.';
              showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
                title: '📚 Materi Pembelajaran Baru: $judul',
                body: deskripsi,
                payload: 'materi',
              );
            }
          },
        )
        .subscribe();
  }

  /// Helper to check if an item was created after app initialization
  bool _isNewItem(String? createdAtStr) {
    if (createdAtStr == null) return true;
    final createdAt = DateTime.tryParse(createdAtStr);
    if (createdAt == null) return true;
    // Allow a small 5 second buffer for network time drift
    return createdAt.isAfter(_initTimestamp.subtract(const Duration(seconds: 5)));
  }

  /// Dispose channels on logout/shutdown
  void dispose() {
    _announcementsChannel?.unsubscribe();
    _tugasChannel?.unsubscribe();
    _materiChannel?.unsubscribe();
  }
}
