import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Route-level guard mirroring Angular's `authGuard`
/// (`guards/auth.guard.ts`): before showing a protected screen, checks
/// whether an auth token is stored, and redirects to `/login` if not.
///
/// Wrap any route that Angular protects with `canActivate: [authGuard]`
/// (home, transfer, statements, account) with this widget.
class AuthGuard extends StatelessWidget {
  final WidgetBuilder builder;

  const AuthGuard({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthGuardLoading();
        }

        final token = snapshot.data;

        if (token == null || token.trim().isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          });

          return const _AuthGuardLoading();
        }

        return builder(context);
      },
    );
  }
}

class _AuthGuardLoading extends StatelessWidget {
  const _AuthGuardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF060B18),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8B5CF6),
        ),
      ),
    );
  }
}
