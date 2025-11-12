// lib/integration_check_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase Import

class IntegrationCheckScreen extends StatelessWidget {
  const IntegrationCheckScreen({super.key});

  // Firebase Auth उपलब्धता जांच
  bool _isAuthAvailable() {
    try {
      FirebaseAuth.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Cloud Firestore उपलब्धता जांच
  bool _isFirestoreAvailable() {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Supabase Client उपलब्धता जांच
  bool _isSupabaseAvailable() {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // विजेट जो UI पर चेक की स्थिति दिखाता है (Reusable Tile)
  Widget _buildCheckTile({
    required String title,
    required String description,
    required bool isSuccess
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isSuccess ? Colors.green.shade300 : Colors.red.shade300,
              width: 2
          )
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isSuccess ? Colors.green[700] : Colors.red[700],
          size: 36,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isSuccess ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isSuccess ? Colors.green[900] : Colors.red[900],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // सारे चेक की स्थिति
    final isCoreSuccess = Firebase.apps.isNotEmpty;
    final isAuthSuccess = _isAuthAvailable();
    final isFirestoreSuccess = _isFirestoreAvailable();
    final isSupabaseSuccess = _isSupabaseAvailable();

    // अंतिम समग्र स्थिति
    final isOverallSuccess = isCoreSuccess && isAuthSuccess && isFirestoreSuccess && isSupabaseSuccess;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integration Status Check'),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Backend Connectivity Test (Firebase & Supabase)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 30),

              // Firebase Checks Section
              const Text('--- Firebase Services ---', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              const SizedBox(height: 10),

              _buildCheckTile(
                title: '1. Firebase Core (Base)',
                description: 'Checks if main initialization is complete.',
                isSuccess: isCoreSuccess,
              ),
              const SizedBox(height: 15),

              _buildCheckTile(
                title: '2. Firebase Auth',
                description: 'Checks if the Authentication service instance can be successfully created.',
                isSuccess: isAuthSuccess,
              ),
              const SizedBox(height: 15),

              _buildCheckTile(
                title: '3. Cloud Firestore',
                description: 'Checks if the Firestore service instance can be successfully created.',
                isSuccess: isFirestoreSuccess,
              ),

              const SizedBox(height: 30),

              // Supabase Check Section
              const Text('--- Supabase Service ---', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              const SizedBox(height: 10),

              _buildCheckTile(
                title: '4. Supabase Client',
                description: 'Checks if the Supabase client instance is available after initialization.',
                isSuccess: isSupabaseSuccess,
              ),

              const SizedBox(height: 40),
              // Final Result Message
              Text(
                isOverallSuccess
                    ? '✅ All Services Connected! Integration is successful.'
                    : '❌ Integration Failed. Check the Console (Terminal) and main.dart for correct keys.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOverallSuccess ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}