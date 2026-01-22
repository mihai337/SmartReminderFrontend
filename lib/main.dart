import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartreminders/services/background_manager.dart';
import 'package:smartreminders/services/location_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/theme.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/notification_service.dart';
import 'package:smartreminders/screens/auth/login_screen.dart';
import 'package:smartreminders/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // TODO: Store Firebase config securely
    FirebaseOptions options = const FirebaseOptions(
      apiKey: "AIzaSyBSqwhR1UbNxDVJr9uDfjW7bTjDT6xmP5o",
      appId: "1:482369567349:web:3d99d42764e0504f2b963c",
      messagingSenderId: "482369567349",
      projectId: "482369567349"
    );
    await Firebase.initializeApp(options: options);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  await LocationService.requestPermission();
  BackgroundManager(); // Initialize BackgroundManager
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Reminders',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  static final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          _taskService.loadTasks();
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
