import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCC THE GURUKUL - Quiz'),
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Quiz Section 📝',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Quiz List
              _buildQuizCard(
                title: 'General Knowledge Quiz',
                description: 'Test your general knowledge',
                questions: 10,
                timeLimit: 15,
              ),
              const SizedBox(height: 12),
              _buildQuizCard(
                title: 'Mathematics Quiz',
                description: 'Solve mathematical problems',
                questions: 15,
                timeLimit: 20,
              ),
              const SizedBox(height: 12),
              _buildQuizCard(
                title: 'Science Quiz',
                description: 'Explore science concepts',
                questions: 12,
                timeLimit: 18,
              ),
              const SizedBox(height: 12),
              _buildQuizCard(
                title: 'English Quiz',
                description: 'Improve your English skills',
                questions: 20,
                timeLimit: 25,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildQuizCard({
    required String title,
    required String description,
    required int questions,
    required int timeLimit,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting $title...')),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text('$questions Questions'),
                    avatar: const Icon(Icons.help, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('$timeLimit min'),
                    avatar: const Icon(Icons.timer, size: 18),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Starting $title...')),
                      );
                    },
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
