import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(FccApp());
}

class FccApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCC THE GURUKUL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0D47A1)),
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
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
      ),
      initialRoute: Routes.splash,
      routes: Routes.getAll(),
    );
  }
}
