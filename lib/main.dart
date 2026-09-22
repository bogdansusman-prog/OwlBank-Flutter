import 'package:flutter/material.dart';

import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/identity_verification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/statements_screen.dart';
import 'screens/transfer_screen.dart';
import 'widgets/auth_guard.dart';

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
      // Mirrors Angular's `app.routes.ts`: '/' redirects to '/login',
      // an unknown path also falls back to '/login', and home /
      // transfer / statements / account are guarded (see AuthGuard).
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),

        // Present in the original Angular codebase but not linked from
        // any route or page there either — kept for parity.
        '/identity-verification': (_) =>
            const IdentityVerificationScreen(),

        '/home': (_) => AuthGuard(
              builder: (_) => const HomeScreen(),
            ),

        '/transfer': (_) => AuthGuard(
              builder: (_) => const TransferScreen(),
            ),

        '/account': (_) => AuthGuard(
              builder: (_) => const AccountScreen(),
            ),

        '/statements': (_) => AuthGuard(
              builder: (_) => const StatementsScreen(),
            ),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}
