import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_mobile/firebase_options.dart';
import 'package:thermal_mobile/data/network/user/user_token_api_service.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';

/// Handler for background messages - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase should already be initialized, but check for background isolate
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Firebase already initialized, continue
    print('Firebase already initialized: $e');
  }
  debugPrint('Handling a background message: ${message.messageId}');
}

/// Firebase Messaging Service for handling push notifications
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// User token API service for server registration
  UserTokenApiService? _userTokenApiService;

  /// Current logged in user
  UserEntity? _currentUser;

  /// Current access token
  String? _accessToken;

  /// FCM token
  String? _fcmToken;

  /// SharedPreferences key for stored FCM token
  static const String _fcmTokenKey = 'fcm_token';

  /// Configure dependencies for token registration
  void configure({required UserTokenApiService userTokenApiService}) {
    _userTokenApiService = userTokenApiService;
    debugPrint('🔧 FirebaseMessaging: Configured with UserTokenApiService');
  }

  /// Android notification channel for high importance notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'thermal_high_importance_channel',
    'Thermal Notifications',
    description: 'This channel is used for thermal warning notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Callback for handling notification taps
  void Function(Map<String, dynamic> data)? onNotificationTap;

  /// Callback for receiving FCM token
  void Function(String token)? onTokenRefresh;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Setup local notifications
    await _setupLocalNotifications();

    // Setup message handlers
    _setupMessageHandlers();

    // Get initial token
    await _getToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('🔄 FCM Token refreshed: $token');
      _fcmToken = token;
      onTokenRefresh?.call(token);

      // Send refreshed token to server if user is logged in
      if (_currentUser != null && _accessToken != null) {
        debugPrint('🔄 Sending refreshed token to server...');
        await _sendTokenToServer();
      }
    });
  }

  /// Register FCM token for user after login
  ///
  /// Call this method after successful login to register device for push notifications
  ///
  /// [user] - The logged in user entity
  /// [accessToken] - The access token for API calls
  /// 
  /// Returns: true if token was registered successfully
  Future<bool> registerTokenForUser({
    required UserEntity user,
    required String accessToken,
  }) async {
    _currentUser = user;
    _accessToken = accessToken;

    debugPrint(
      '👤 FirebaseMessaging: Registering token for user ${user.userName}',
    );

    // Get token if not available
    _fcmToken ??= await _messaging.getToken();

    if (_fcmToken != null) {
      return await _sendTokenToServer();
    } else {
      debugPrint('⚠️ FirebaseMessaging: No FCM token available');
      return false;
    }
  }

  /// Unregister FCM token on logout
  ///
  /// Call this method before logout to clean up device registration
  Future<void> unregisterToken() async {
    debugPrint('🚪 FirebaseMessaging: Unregistering token on logout');

    // Clear stored token from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      debugPrint('💾 Removed FCM token from local storage');
    } catch (e) {
      debugPrint('⚠️ Error removing FCM token from storage: $e');
    }

    // Delete FCM token (optional - server will clean up inactive tokens)
    // await deleteToken();

    // Clear user data
    _currentUser = null;
    _accessToken = null;

    debugPrint('✅ FCM token unregistered');
  }

  /// Send FCM token to server
  /// Returns: true if successful
  Future<bool> _sendTokenToServer() async {
    if (_fcmToken == null) {
      debugPrint('⚠️ FirebaseMessaging: No FCM token to send');
      return false;
    }

    if (_userTokenApiService == null) {
      debugPrint('⚠️ FirebaseMessaging: UserTokenApiService not configured');
      return false;
    }

    if (_currentUser == null || _accessToken == null) {
      debugPrint('⚠️ FirebaseMessaging: User not logged in');
      return false;
    }

    try {
      debugPrint(
        '📤 FirebaseMessaging: Sending token to server for user ${_currentUser!.userName}',
      );

      final success = await _userTokenApiService!.postUserToken(
        userId: _currentUser!.id.toString(),
        deviceType: UserTokenApiService.currentDeviceType,
        token: _fcmToken!,
        areaIds: [], // Can be updated later with user's subscribed areas
        isAdmin:
            _currentUser!.roleName?.toLowerCase().contains('admin') ?? false,
        accessToken: _accessToken!,
      );

      if (success) {
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, _fcmToken!);

        debugPrint('✅ FCM token registered successfully');
        debugPrint('💾 Token saved to local storage');
        return true;
      } else {
        debugPrint('❌ Failed to register FCM token');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM token: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );
  }

  /// Setup local notifications for foreground messages
  Future<void> _setupLocalNotifications() async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Handle notification tap response
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTap?.call(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Setup Firebase message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    _checkInitialMessage();
  }

  /// Handle foreground message - show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Received foreground message: ${message.messageId}');
    debugPrint('📩 Title: ${message.notification?.title}');
    debugPrint('📩 Body: ${message.notification?.body}');
    debugPrint('📩 Data: ${message.data}');

    final notification = message.notification;
    final android = message.notification?.android;

    // Show local notification on Android
    if (notification != null && !kIsWeb) {
      debugPrint('🔔 Showing local notification...');
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      debugPrint('✅ Local notification shown');
    } else {
      debugPrint('⚠️ No notification to show (notification: $notification, kIsWeb: $kIsWeb)');
    }
  }

  /// Handle message when app is opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');
    onNotificationTap?.call(message.data);
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      // Delay to ensure app is fully initialized
      Future.delayed(const Duration(seconds: 1), () {
        onNotificationTap?.call(initialMessage.data);
      });
    }
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $token');
      _fcmToken = token;
      if (token != null) {
        onTokenRefresh?.call(token);
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    _fcmToken ??= await _messaging.getToken();
    return _fcmToken;
  }

  /// Check if user is registered for notifications
  bool get isRegistered => _currentUser != null && _fcmToken != null;

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    debugPrint('FCM token deleted');
  }
}
