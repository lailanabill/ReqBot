import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - Recent Projects
            const Text('Recent Projects', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ProjectCard(projectName: 'Project Alpha', status: 'completed'),
                  ProjectCard(projectName: 'Project Beta', status: 'attention_needed'),
                  ProjectCard(projectName: 'Project Gamma', status: 'in_progress'),
                ],
              ),
            ),
            // Middle Section - Notifications
            const SizedBox(height: 16),
            const Text('Notifications', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const NotificationTile(message: 'Feedback requested on Project Alpha'),
            NotificationTile(message: 'Validation issue detected in Project Beta'),
            // Bottom Section - Quick Actions
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuickActionButton(label: 'New Conversation'),
                QuickActionButton(label: 'Analyze Transcript'),
                QuickActionButton(label: 'View Specifications'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String status;

  const ProjectCard({required this.projectName, required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    // Determine icon and color based on the project status
    switch (status) {
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'attention_needed':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'in_progress':
      default:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(projectName),
        trailing: Icon(icon, color: color),
        onTap: () {
          // Navigate to project details
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String message;

  const NotificationTile({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(message),
        leading: const Icon(Icons.notifications),
        onTap: () {
          // Navigate to relevant project section
        },
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String label;

  const QuickActionButton({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          // Implement button action
        },
        child: Text(label),
      ),
    );
  }
}