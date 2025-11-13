// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data
  Map<String, dynamic>? _userProfile;
  String? _userId;

  // UI State
  bool _loading = true;
  String? _error;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;

      if (authUser == null) throw Exception('User not authenticated');

      // Get user row
      final userRow = await supabase
          .from('users')
          .select('id, email')
          .eq('auth_user_id', authUser.id)
          .single() as Map<String, dynamic>;

      final dbUserId = userRow['id'] as String;

      // Get user profile
      final profileData = await supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', dbUserId)
          .maybeSingle() as Map<String, dynamic>?;

      // Merge user and profile data
      final fullProfile = {
        ...userRow,
        ...?profileData,
      };

      if (!mounted) return;

      setState(() {
        _userProfile = fullProfile;
        _userId = dbUserId;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load user data. Please try again.';
      });
    }
  }

  // ========== GETTERS ==========
  String get _userName {
    final name = (_userProfile?['full_name'] as String?)?.trim();
    return (name == null || name.isEmpty) ? 'Student' : name;
  }

  String get _userEmail => _userProfile?['email'] ?? '';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _studentClass => _userProfile?['student_class'] ?? 'N/A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _loading
          ? null
          : AppDrawer(
        userName: _userName,
        userEmail: _userEmail,
        userClass: _studentClass,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ========== APP BAR ==========
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('FCC THE GURUKUL'),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            );
          },
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  // ========== BODY ==========
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Welcome message
            _buildWelcomeSection(),
          ],
        ),
      ),
    );
  }

  // ========== HEADER CARD ==========
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $_userName 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Class: $_studentClass',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== WELCOME SECTION ==========
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to FCC THE GURUKUL! 🎓',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your learning journey starts here. Explore courses, take quizzes, and track your progress.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.school, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Learn at your own pace',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Test your knowledge',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.leaderboard, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Track your progress',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== BOTTOM NAV (Home, Quiz, Course, News) ==========
  Widget _buildBottomNav() {
    return const BottomNavBar(currentIndex: 0);
  }
}
