import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'dart:async';

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
        final daysLeft = card.expirationDate.difference(DateTime.now()).inDays;
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
  
  // simulate a push notification (for testing)
  void simulatePushNotification(String title, String body) {
    _firebaseMessaging.simulateMessage(title, body);
  }
}