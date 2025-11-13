import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCC THE GURUKUL - Courses'),
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
                'Available Courses 🎓',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Course List
              _buildCourseCard(
                title: 'Advanced Mathematics',
                instructor: 'Mr. Sharma',
                rating: 4.8,
                students: 1250,
                lessons: 24,
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                title: 'Science Fundamentals',
                instructor: 'Dr. Patel',
                rating: 4.7,
                students: 980,
                lessons: 20,
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                title: 'English Communication',
                instructor: 'Ms. Gupta',
                rating: 4.9,
                students: 1500,
                lessons: 18,
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                title: 'Computer Science Basics',
                instructor: 'Mr. Singh',
                rating: 4.6,
                students: 2000,
                lessons: 30,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required double rating,
    required int students,
    required int lessons,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $title...')),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.school,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Course Details
            Padding(
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
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: $instructor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Rating
                      Chip(
                        label: Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(rating.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Students
                      Chip(
                        label: Text('$students Students'),
                        avatar: const Icon(Icons.people, size: 14),
                      ),
                      const SizedBox(width: 8),
                      // Lessons
                      Chip(
                        label: Text('$lessons Lessons'),
                        avatar: const Icon(Icons.book, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enrolling in $title...')),
                        );
                      },
                      child: const Text('Enroll Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
