import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:society_gate_app/authentication/phone.dart';
import 'package:society_gate_app/authentication/registration_screen.dart';
import 'package:society_gate_app/firebase_config.dart';
import 'package:society_gate_app/provider/NotificationProvider.dart';
import 'package:society_gate_app/screens/homescreen.dart';
import 'package:society_gate_app/onboarding/onboarding_view.dart';
import 'package:society_gate_app/splash_screen.dart';
import 'package:society_gate_app/authentication/login_screen.dart';
import 'package:society_gate_app/authentication/verify.dart';
import 'package:society_gate_app/local_notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:society_gate_app/screens/setting_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");
  print("Notification title: ${message.notification?.title}");
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notification service
  LocalNotificationService.initialize();

  // Get FCM token
  FirebaseMessaging.instance.getToken().then((token) {
    print("FCM Token: $token");
  });

  runApp(
    // Wrap MaterialApp with NotificationProvider
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('es'),
        Locale('hi'),
        Locale('mr'),
      ],
      initialRoute: 'splashscreen',
      debugShowCheckedModeBanner: false,
      routes: {
        'phone': (context) => MyPhone(),
        'verify': (context) => MyVerify(),
        'home': (context) => HomeScreen(),
        'onboarding': (context) => OnboardingView(),
        'splashscreen': (context) => SplashScreen(),
        'registration': (context) => RegistrationScreen(),
        'login': (context) => LoginScreen(),
        'settings': (context) => SettingScreen(setLocale: _setLocale), // Pass _setLocale to SettingScreen
      },
    );
  }
}
