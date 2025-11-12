import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Future.delayed(const Duration(milliseconds: 300)); // tiny UX delay

      if (!mounted) return;
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login'); // ✅ ensure this exists in Routes
      } else {
        Navigator.of(context).pushReplacementNamed('/home');  // ✅ ensure this exists in Routes
      }
    } catch (e) {
      debugPrint('❌ Init failed: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
