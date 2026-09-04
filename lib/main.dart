import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OwlBankApp());
}

class OwlBankApp extends StatelessWidget {
  const OwlBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OwlBank',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060B18),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),

        '/home': (_) => const HomeScreen(),

        '/register': (_) => const RegisterScreen(),

        '/reset-password': (_) => const PlaceholderScreen(
              title: 'Reset Password',
            ),
        '/account': (_) => const PlaceholderScreen(
            title: 'Account',
            ),

        '/transfer': (_) => const PlaceholderScreen(
            title: 'Transfer',
            ),
        '/statements': (_) => const PlaceholderScreen(
            title: 'Statements',
            ),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}