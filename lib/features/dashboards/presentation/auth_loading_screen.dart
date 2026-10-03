import 'package:flutter/material.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF164F43),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, color: Color(0xFFBDE9D8), size: 72),
            SizedBox(height: 24),
            Text(
              'scooper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chargement de votre espace...',
              style: TextStyle(color: Color(0xFFBDE9D8), fontSize: 16),
            ),
            SizedBox(height: 36),
            CircularProgressIndicator(
              color: Color(0xFFBDE9D8),
            ),
          ],
        ),
      ),
    );
  }
}
