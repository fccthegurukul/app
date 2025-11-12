import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/user_service.dart';
import '../services/onesignal_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentPage = 0;
  bool _loading = false;

  // Form Controllers
  final _classCtrl = TextEditingController();
  final _boardCtrl = TextEditingController();
  final _mediumCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String? selectedClass;
  String? selectedBoard;
  String? selectedMedium;
  List<String> selectedSubjects = [];

  // Options for dropdowns
  final List<String> classes = ['6th', '7th', '8th', '9th', '10th', '11th', '12th', 'B.Com', 'Other'];
  final List<String> boards = ['CBSE', 'ICSE', 'State Board (Bihar)', 'State Board (UP)', 'Other'];
  final List<String> mediums = ['English', 'Hindi', 'Both'];
  final List<String> subjects = ['Mathematics', 'Science', 'Social Science', 'English', 'Hindi', 'Commerce', 'Physics', 'Chemistry', 'Biology'];

  @override
  void dispose() {
    _pageController.dispose();
    _classCtrl.dispose();
    _boardCtrl.dispose();
    _mediumCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await OneSignalService().initialize();

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await OneSignalService().loginUser(user.id);

        // Update profile with notification permission status
        final userRow = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('auth_user_id', user.id)
            .single();

        await Supabase.instance.client
            .from('user_profiles')
            .update({
          'notifications_enabled': true,
          'permission_asked_count': 1,
          'last_permission_ask': DateTime.now().toIso8601String(),
        })
            .eq('user_id', userRow['id']);
      }

      _showSnack('✅ Notifications enabled successfully!');
    } catch (e) {
      debugPrint('❌ Notification permission error: $e');
      _showSnack('Could not enable notifications');
    }
  }

  Future<void> _saveOnboardingData() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedClass == null || selectedBoard == null || selectedMedium == null) {
      _showSnack('Please select all required fields');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not found');

      // Get user ID from users table
      final userRow = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      final userId = userRow['id'] as String;

      // Update user profile with onboarding data
      await UserService().updateUserProfile(
        userId: userId,
        studentClass: selectedClass!,
        board: selectedBoard!,
        medium: selectedMedium!,
        subjects: selectedSubjects,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      );

      // Mark onboarding as completed
      await Supabase.instance.client
          .from('user_profiles')
          .update({
        'is_onboarding_completed': true,
        'profile_completion_percentage': 70,
      })
          .eq('user_id', userId);

      // Set OneSignal tags for targeting
      await OneSignalService().setUserTags({
        'class': selectedClass!,
        'board': selectedBoard!,
        'medium': selectedMedium!,
        'subjects': selectedSubjects.join(','),
      });

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      _showSnack('Error saving data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildNotificationPage(),
                  _buildProfileSetupPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 100, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            'Welcome to FCC THE GURUKUL',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your journey to knowledge starts here. Let\'s personalize your experience!',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active, size: 100, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            'Stay Updated',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get notified about new courses, quiz results, and important updates!',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await _requestNotificationPermission();
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Enable Notifications'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Class Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Your Class *',
                border: OutlineInputBorder(),
              ),
              value: selectedClass,
              items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => selectedClass = val),
              validator: (v) => v == null ? 'Select class' : null,
            ),
            const SizedBox(height: 16),

            // Board Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Your Board *',
                border: OutlineInputBorder(),
              ),
              value: selectedBoard,
              items: boards.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() => selectedBoard = val),
              validator: (v) => v == null ? 'Select board' : null,
            ),
            const SizedBox(height: 16),

            // Medium Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Medium *',
                border: OutlineInputBorder(),
              ),
              value: selectedMedium,
              items: mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedMedium = val),
              validator: (v) => v == null ? 'Select medium' : null,
            ),
            const SizedBox(height: 16),

            // Subjects Multi-select
            Text('Interested Subjects:', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: subjects.map((subject) {
                final isSelected = selectedSubjects.contains(subject);
                return FilterChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSubjects.add(subject);
                      } else {
                        selectedSubjects.remove(subject);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // City (Optional)
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveOnboardingData,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Complete Setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
