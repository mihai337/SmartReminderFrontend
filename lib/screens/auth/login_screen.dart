import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/screens/home/home_screen.dart';

import '../../services/task_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    final bool user = await _authService.loginWithGoogle();

    if(user) {
      await _taskService.loadTasks();
    }
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (user) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B7FFF), Color(0xFF8B7FFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.notifications, size: 50, color: Color(0xFF5B7FFF)),
              ),
              const SizedBox(height: 32),
              const Text(
                'SmartRemind',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Never miss what matters with location, time,\nand WiFi-based reminders',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sign in to manage your smart\nreminders',
                        style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: SvgPicture.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Color(0xFFE8E8E8)),
                                  foregroundColor: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                      const SizedBox(height: 24),
                      const Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                        style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
