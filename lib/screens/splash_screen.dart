import 'dart:async';
import 'package:flutter/material.dart';
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // logo
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              SizedBox(height: 14),
Text(
  'FCC THE GURUKUL',
  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
),
SizedBox(height: 6),
Text(
  'Learn. Practice. Succeed.',
  style: theme.textTheme.bodyMedium,
),

            ],
          ),
        ),
      ),
    );
  }
}
