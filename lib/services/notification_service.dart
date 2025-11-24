// 알림 서비스
//
// Firebase Cloud Messaging (FCM)을 사용하여 푸시 알림을 처리하는 서비스입니다.
// 앱이 켜져있을 때와 꺼져있을 때 모두 알림을 받을 수 있도록 구현합니다.
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 백그라운드 메시지 핸들러
///
/// 앱이 완전히 종료된 상태에서 알림을 받을 때 호출되는 함수입니다.
/// **주의:** 이 함수는 반드시 top-level 함수로 선언되어야 합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (백그라운드 핸들러는 별도의 isolate에서 실행되므로)
  // await Firebase.initializeApp();

  // 백그라운드 메시지 처리 로직
  // ignore: avoid_print
  print('백그라운드 메시지 수신: ${message.messageId}');
  // ignore: avoid_print
  print(
    '메시지 내용: ${message.notification?.title} - ${message.notification?.body}',
  );
}

/// 알림 서비스 클래스
///
/// Firebase Cloud Messaging을 사용하여 푸시 알림을 처리합니다.
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class NotificationService {
  /// 싱글톤 인스턴스
  static final NotificationService instance = NotificationService._internal();

  /// Firebase Messaging 인스턴스
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Flutter Local Notifications 인스턴스
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  /// 알림 서비스를 초기화합니다.
  ///
  /// 권한 요청, 포그라운드/백그라운드 메시지 핸들러를 설정합니다.
  Future<void> initialize() async {
    try {
      // 1. 알림 권한 요청
      final NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      // ignore: avoid_print
      print('알림 권한 상태: ${settings.authorizationStatus}');

      // 2. Flutter Local Notifications 초기화 (앱 실행 중 알림 표시용)
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // 알림 탭 시 처리 로직 (필요시 구현)
          // ignore: avoid_print
          print('알림 탭됨: ${response.payload}');
        },
      );

      // 3. 포그라운드 메시지 핸들러 설정 (앱이 켜져있을 때)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('포그라운드 메시지 수신: ${message.messageId}');
        // ignore: avoid_print
        print(
          '메시지 내용: ${message.notification?.title} - ${message.notification?.body}',
        );

        // 로컬 알림 표시
        _showLocalNotification(message);
      });

      // 4. 백그라운드 메시지 핸들러 설정 (앱이 꺼져있을 때)
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 5. 알림 탭 핸들러 설정 (앱이 백그라운드에 있을 때 알림을 탭한 경우)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('백그라운드 알림 탭됨: ${message.messageId}');
        // TODO: 특정 화면으로 이동하는 로직 구현
      });
    } catch (e) {
      // ignore: avoid_print
      print('알림 서비스 초기화 중 오류 발생: $e');
    }
  }

  /// 로컬 알림을 표시합니다.
  ///
  /// 앱이 실행 중일 때 FCM 메시지를 받으면 상단 알림을 띄웁니다.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mochi_channel', // 채널 ID
          'Mochi 알림', // 채널 이름
          channelDescription: '모찌 앱의 푸시 알림 채널입니다.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode, // 고유한 알림 ID
      message.notification?.title ?? '알림',
      message.notification?.body ?? '새 메시지가 도착했습니다.',
      notificationDetails,
      payload: message.data.toString(), // 추가 데이터 (선택사항)
    );
  }

  /// FCM 토큰을 가져와서 콘솔에 출력합니다.
  ///
  /// 이 토큰을 사용하여 특정 기기에 알림을 보낼 수 있습니다.
  Future<void> getToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      // ignore: avoid_print
      print('FCM 토큰: $token');

      // 토큰 갱신 시 자동으로 출력
      _firebaseMessaging.onTokenRefresh.listen((String newToken) {
        // ignore: avoid_print
        print('FCM 토큰 갱신됨: $newToken');
      });
    } catch (e) {
      // ignore: avoid_print
      print('FCM 토큰 가져오기 중 오류 발생: $e');
    }
  }
}
