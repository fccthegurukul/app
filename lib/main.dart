// lib/main.dart

import 'package:fccthegurukul_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔹 Initialize Supabase
    await Supabase.initialize(
      url: 'https://rpepfhdxkqvpbzejylrc.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwZXBmaGR4a3F2cGJ6ZWp5bHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNDYxNjYsImV4cCI6MjA3NzkyMjE2Nn0.dObdS8RkgZIqWehPNTUl66croZ-pBLKL_IXrRjWH7LA',
    );
    debugPrint('✅ Supabase initialized successfully');

    // 🔹 Initialize OneSignal
    await OneSignalService().initialize();
    debugPrint('✅ OneSignal initialized successfully');
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }

  runApp(const FccApp());
}

class FccApp extends StatelessWidget {
  const FccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCC THE GURUKUL',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF0D47A1);
    const secondaryColor = Color(0xFFF57C00);

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
      ),
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}


