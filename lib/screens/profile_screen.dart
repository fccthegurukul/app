import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            CircleAvatar(radius: 44, backgroundImage: AssetImage('assets/images/logo.png')),
            SizedBox(height: 12),
            Text('Your Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            SizedBox(height: 6),
            Text('student@example.com', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Progress'),
                subtitle: Text('Quizzes completed: 12'),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Account Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
