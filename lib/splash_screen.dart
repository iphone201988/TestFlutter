import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'firebase_auth_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show dashboard if user is logged in, otherwise show login
        if (snapshot.hasData && snapshot.data != null) {
          return Dashboard();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}