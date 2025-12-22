import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/auth_gate.dart';

class IntroSplashImage extends StatefulWidget {
  const IntroSplashImage({super.key});

  @override
  State<IntroSplashImage> createState() => _IntroSplashImageState();
}

class _IntroSplashImageState extends State<IntroSplashImage> {
  @override
  void initState() {
    super.initState();

    // 🔥 Draw behind status & navigation bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // ⏳ Splash duration
    Timer(const Duration(seconds: 2), _goToAuth);
  }

  void _goToAuth() {
    if (!mounted) return;

    // 🚀 Hand over control to AuthGate
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/splash screen.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
