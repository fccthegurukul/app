import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courses = [
      {'title': 'Math Foundation', 'subtitle': 'Basics to Advanced'},
      {'title': 'General Studies', 'subtitle': 'History, Polity, Geography'},
      {'title': 'Reasoning & Aptitude', 'subtitle': 'Practice sets & tricks'},
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'Courses'),
      body: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: courses.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, idx) {
          final item = courses[idx];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(item['title']!, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item['subtitle']!),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // TODO: open course detail
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open ${item['title']}')));
              },
            ),
          );
        },
      ),
    );
  }
}
