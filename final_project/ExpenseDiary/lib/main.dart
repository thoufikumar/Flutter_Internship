import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/currency_provider.dart';
import 'provider/ExpenseProvider.dart';
import 'screens/intro_splash_image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider()..loadCurrency(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4F9792),
        scaffoldBackgroundColor: const Color(0xFFEFF9F7),
        useMaterial3: false,
      ),

      // 🎬 Splash screen first
      home: const IntroSplashImage(),
    );
  }
}
