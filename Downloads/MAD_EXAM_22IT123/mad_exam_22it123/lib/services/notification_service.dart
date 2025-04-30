import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:async';
import 'package:intl/intl.dart';

// Mock RemoteMessage for demo purposes
class MockRemoteMessage {
  final MockNotification? notification;
  final Map<String, dynamic> data;
  
  MockRemoteMessage({
    this.notification,
    this.data = const {},
  });
}

// Mock Notification for demo purposes
class MockNotification {
  final String? title;
  final String? body;
  
  MockNotification({
    this.title,
    this.body,
  });
}

// Mock FirebaseMessaging for demo purposes
class MockFirebaseMessaging {
  static final MockFirebaseMessaging _instance = MockFirebaseMessaging._internal();
  static MockFirebaseMessaging get instance => _instance;
  MockFirebaseMessaging._internal();
  
  final StreamController<MockRemoteMessage> _onMessageController = 
      StreamController<MockRemoteMessage>.broadcast();
  final StreamController<MockRemoteMessage> _onMessageOpenedAppController = 
      StreamController<MockRemoteMessage>.broadcast();
  
  Stream<MockRemoteMessage> get onMessage => _onMessageController.stream;
  Stream<MockRemoteMessage> get onMessageOpenedApp => _onMessageOpenedAppController.stream;
  
  Future<void> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    // simulate permission request
    await Future.delayed(const Duration(milliseconds: 300));
    print('Notification permissions granted');
    return;
  }
  
  // simulate receiving a message
  void simulateMessage(String title, String body, {Map<String, dynamic> data = const {}}) {
    final message = MockRemoteMessage(
      notification: MockNotification(
        title: title,
        body: body,
      ),
      data: data,
    );
    
    _onMessageController.add(message);
  }
  
  // simulate opening app from notification
  void simulateOpenFromNotification(String title, String body, {Map<String, dynamic> data = const {}}) {
    final message = MockRemoteMessage(
      notification: MockNotification(
        title: title,
        body: body,
      ),
      data: data,
    );
    
    _onMessageOpenedAppController.add(message);
  }
}

class NotificationService {
  // singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final MockFirebaseMessaging _firebaseMessaging = MockFirebaseMessaging.instance;
  
  // initialize notification services
  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York')); // Set a default timezone
    
    // local notifications setup
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // firebase messaging setup (mocked)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    _firebaseMessaging.onMessage.listen(_handleFirebaseMessage);
    _firebaseMessaging.onMessageOpenedApp.listen(_handleFirebaseMessageOpenedApp);
    
    // check for expiring cards daily
    _scheduleExpirationCheckDaily();
  }
  
  // handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // handle navigation or actions based on notification payload
    print('Notification tapped: ${response.payload}');
  }
  
  // handle firebase messages when app is in foreground
  void _handleFirebaseMessage(MockRemoteMessage message) {
    print('Received message while in foreground: ${message.notification?.title}');
    
    // show local notification for the firebase message
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? 'New Message',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
  
  // handle firebase messages when app is opened from notification
  void _handleFirebaseMessageOpenedApp(MockRemoteMessage message) {
    print('App opened from notification: ${message.notification?.title}');
    // handle navigation or actions
  }
  
  // show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'loyalty_cards_channel',
      'Loyalty Cards',
      channelDescription: 'Notifications related to loyalty cards',
      importance: Importance.high,
      priority: Priority.high,
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
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  // check for expiring cards (run once a day)
  void _scheduleExpirationCheckDaily() {
    // this is a simplified version - in real app, use proper background processing
    Timer.periodic(const Duration(days: 1), (_) {
      // This is just a placeholder - the actual cards list would be passed from the provider
      checkForExpiringCards([]);
    });
  }
  
  // check for cards that are expiring soon and show notifications
  Future<void> checkForExpiringCards(List<LoyaltyCard> cards) async {
    for (final card in cards) {
      if (card.isExpiringSoon) {
        final daysLeft = card.expirationDate?.difference(DateTime.now()).inDays ?? 0;
        await showNotification(
          id: card.id.hashCode,
          title: 'Card Expiring Soon',
          body: '${card.name} will expire in $daysLeft days!',
          payload: card.id,
        );
      }
    }
  }
  
  // show notification for a new promotion (simulated)
  Future<void> showPromotion(String cardName, String promoDetails) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      title: 'New Promotion for $cardName',
      body: promoDetails,
    );
  }
  
  // show notification for reward milestone achievement
  Future<void> showRewardMilestone(String cardName, int points, String reward) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      title: 'Reward Milestone Reached! 🎉',
      body: 'You\'ve earned $points points on your $cardName card. Redeem for: $reward',
      payload: 'reward_milestone_$cardName',
    );
  }
  
  // show notification for points update
  Future<void> showPointsUpdate(String cardName, int newPoints, int pointsChange) async {
    if (pointsChange <= 0) return; // Only notify for positive changes
    
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      title: 'Points Updated',
      body: 'You\'ve earned +$pointsChange points on your $cardName card. New balance: $newPoints',
      payload: 'points_update_$cardName',
    );
  }
  
  // schedule expiration reminder well before the card expires
  Future<void> scheduleExpirationReminder(LoyaltyCard card) async {
    if (card.expirationDate == null) return;
    
    final daysUntilExpiration = card.expirationDate!.difference(DateTime.now()).inDays;
    
    // Schedule multiple reminders at different intervals before expiration
    if (daysUntilExpiration > 30) {
      // Schedule a reminder for 30 days before expiration
      final reminderDate = card.expirationDate!.subtract(const Duration(days: 30));
      await _scheduleNotification(
        id: '${card.id}_30days'.hashCode,
        title: 'Card Expiring Soon',
        body: '${card.name} will expire in 30 days on ${_dateFormat.format(card.expirationDate!)}',
        scheduledDate: reminderDate,
        payload: card.id,
      );
    }
    
    if (daysUntilExpiration > 7) {
      // Schedule a reminder for 7 days before expiration
      final reminderDate = card.expirationDate!.subtract(const Duration(days: 7));
      await _scheduleNotification(
        id: '${card.id}_7days'.hashCode,
        title: 'Card Expiring Very Soon',
        body: '${card.name} will expire in 7 days on ${_dateFormat.format(card.expirationDate!)}',
        scheduledDate: reminderDate,
        payload: card.id,
      );
    }
    
    // Final reminder 1 day before
    if (daysUntilExpiration > 1) {
      final reminderDate = card.expirationDate!.subtract(const Duration(days: 1));
      await _scheduleNotification(
        id: '${card.id}_1day'.hashCode,
        title: 'Card Expires Tomorrow',
        body: '${card.name} will expire tomorrow! Use it before it\'s too late.',
        scheduledDate: reminderDate,
        payload: card.id,
      );
    }
  }
  
  // schedule a notification for a specific date/time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Only proceed if date is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }
    
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'loyalty_cards_channel',
      'Loyalty Cards',
      channelDescription: 'Notifications related to loyalty cards',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // test date formatter
  final _dateFormat = DateFormat('MM/dd/yyyy');
  
  // simulate a push notification (for testing)
  void simulatePushNotification(String title, String body) {
    _firebaseMessaging.simulateMessage(title, body);
  }
}