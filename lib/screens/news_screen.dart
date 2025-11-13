import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCC THE GURUKUL - News'),
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
                'Latest News & Updates 📰',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // News List
              _buildNewsCard(
                title: 'New Quiz Competition Launched',
                description: 'Participate in our monthly quiz competition and win exciting prizes!',
                date: 'Today',
                category: 'Event',
              ),
              const SizedBox(height: 12),
              _buildNewsCard(
                title: 'Course Updates & Improvements',
                description: 'We have added 5 new courses to our platform. Check them out now!',
                date: 'Yesterday',
                category: 'Update',
              ),
              const SizedBox(height: 12),
              _buildNewsCard(
                title: 'Student Success Story',
                description: 'Congratulations to Rahul for scoring 98% in the final exam!',
                date: '2 days ago',
                category: 'Achievement',
              ),
              const SizedBox(height: 12),
              _buildNewsCard(
                title: 'New Feature: Discussion Forum',
                description: 'Connect with other students and discuss course topics in our new forum.',
                date: '3 days ago',
                category: 'Feature',
              ),
              const SizedBox(height: 12),
              _buildNewsCard(
                title: 'Maintenance Scheduled',
                description: 'We will be performing system maintenance on Sunday. Thank you for your patience.',
                date: '4 days ago',
                category: 'Maintenance',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String description,
    required String date,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: $title')),
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
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(category),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reading: $title')),
                      );
                    },
                    child: const Text('Read More'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'event':
        return Colors.blue;
      case 'update':
        return Colors.orange;
      case 'achievement':
        return Colors.green;
      case 'feature':
        return Colors.purple;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
