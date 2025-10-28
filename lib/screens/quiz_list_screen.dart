import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class QuizListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizzes = [
      {'title': 'Daily Quiz - 10 Q', 'time': '15 min'},
      {'title': 'Speed Test - 20 Q', 'time': '10 min'},
      {'title': 'Mock Test - 50 Q', 'time': '60 min'},
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'Quizzes'),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: quizzes.length,
        itemBuilder: (context, idx) {
          final q = quizzes[idx];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(q['title']!, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${q['time']} • ${20 + idx * 10} attempts'),
              trailing: ElevatedButton(
                child: Text('Start'),
                onPressed: () {
                  // placeholder navigation to quiz runner screen
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start ${q['title']}')));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
