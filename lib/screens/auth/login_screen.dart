import 'package:flutter/material.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.signInWithGoogle();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (user != null) {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.notifications_active,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Smart Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Never forget what matters',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
              const Spacer(),
              Text(
                'Location, time, and WiFi-based reminders',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
