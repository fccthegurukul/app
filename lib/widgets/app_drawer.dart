import 'package:flutter/material.dart';
import '../routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/images/logo.png')),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tricky Math & GK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('student@example.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.home),
            ),
            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('Courses'),
              onTap: () => Navigator.pushNamed(context, Routes.courses),
            ),
            ListTile(
              leading: Icon(Icons.quiz),
              title: Text('Quizzes'),
              onTap: () => Navigator.pushNamed(context, Routes.quizList),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.pushNamed(context, Routes.profile),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.pushNamed(context, Routes.settings),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}
