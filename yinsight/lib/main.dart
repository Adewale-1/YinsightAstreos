import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yinsight/Screens/HomePage/views/home/home_screen.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/ForgetPassword.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignInScreen.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignUpScreen.dart';
import 'package:yinsight/Screens/Onboarding/onboarding_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yinsight/navigationBar.dart';
import 'firebase_options.dart';

/// The main entry point of the application.
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "basic_channel_group",
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "basic_channel_group",
        channelGroupName: "Basic group",
      )
    ],
  );
  // Check notification permission
  bool isAllowedToSendNotifictions = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotifictions) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app
  runApp(const ProviderScope(
    child: MyApp(),
  ));
  // Handle Flutter errors with Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}



/// The main application widget.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black54),
        ),
      ),
      
      // Direct to MainNavigationScreen if a user is logged in
      initialRoute: FirebaseAuth.instance.currentUser != null ? MainNavigationScreen.id : OnboardingController.id,
      routes: {
        MainNavigationScreen.id: (context) => const MainNavigationScreen(),
        SignInScreen.id: (context) => const SignInScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        ForgetPasswordScreen.id: (context) => const ForgetPasswordScreen(),
        OnboardingController.id: (context) => const OnboardingController(),
      },
    );
  }

}


