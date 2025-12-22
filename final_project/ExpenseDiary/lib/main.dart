import 'package:expense_tracker_app/state/awareness_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// existing providers
import 'provider/currency_provider.dart';
import 'provider/ExpenseProvider.dart';

// PHASE 1 – unresolved inbox
import 'state/unresolved_store.dart';
import 'models/unresolved_transaction.dart';

// splash
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
        // 🔥 ADD THIS
    ChangeNotifierProvider(
      create: (_) => AwarenessProvider()..loadSuppression(),
    ),
        // 🧾 PHASE 1 – Unresolved Transactions Store
        ChangeNotifierProvider(
          create: (_) => UnresolvedStore(),
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
    // 🧪 PHASE 1 – Inject mock data safely AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unresolvedStore =
          Provider.of<UnresolvedStore>(context, listen: false);

      // prevent duplicate injection on hot reload
      if (unresolvedStore.pendingItems.isEmpty) {
        unresolvedStore.addMock(
          UnresolvedTransaction(
            id: 'tx1',
            amount: 240.0,
            dateTime: DateTime.now(),
            merchantRaw: 'Swiggy',
            source: DetectionSource.manualMock,
          ),
        );

        unresolvedStore.addMock(
          UnresolvedTransaction(
            id: 'tx2',
            amount: 120.0,
            dateTime: DateTime.now().subtract(const Duration(hours: 3)),
            merchantRaw: '',
            source: DetectionSource.manualMock,
          ),
        );
      }
    });

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4F9792),
        scaffoldBackgroundColor: const Color(0xFFEFF9F7),
        useMaterial3: false,
      ),

      // 🎬 Splash screen first (unchanged)
      home: const IntroSplashImage(),
    );
  }
}
