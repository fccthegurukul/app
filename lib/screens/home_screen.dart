import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_appbar.dart';
import 'courses_screen.dart';
import 'quiz_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Home content (dashboard)
    _Dashboard(),
    CoursesScreen(),
    QuizListScreen(),
    ProfileScreen(),
  ];

  void _onTap(int idx) {
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'FCC THE GURUKUL'),
      drawer: AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple, clean dashboard UI — expand as needed
    return SingleChildScrollView(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Daily practice, quizzes and progress tracking.', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 18),
          _SectionCard(title: 'Continue Course', subtitle: 'Geometry — Chapter 3'),
          SizedBox(height: 12),
          _SectionCard(title: 'Daily Quiz', subtitle: '10 Questions • 15 mins'),
          SizedBox(height: 12),
          _SectionCard(title: 'Explore Courses', subtitle: 'Math, GK, Reasoning'),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // navigation example
          if (title.contains('Quiz')) {
            Navigator.pushNamed(context, '/quiz_list');
          } else {
            Navigator.pushNamed(context, '/courses');
          }
        },
      ),
    );
  }
}
