import 'package:flutter/material.dart';
import 'project_name_input_screen.dart'; // Import the new screen

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
            const Text('Recent Projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  childAspectRatio: 2, // Aspect ratio of each card
                  crossAxisSpacing: 16, // Spacing between columns
                  mainAxisSpacing: 16, // Spacing between rows
                ),
                itemCount: 3, // Number of projects
                itemBuilder: (context, index) {
                  final projectNames = ['Project x', 'Project y', 'Project z'];
                  final projectStatuses = [
                    'completed',
                    'attention_needed',
                    'in_progress'
                  ];

                  return ProjectCard(
                    projectName: projectNames[index],
                    status: projectStatuses[index],
                  );
                },
              ),
            ),
            // Middle Section - Notifications
            const SizedBox(height: 16),
            const Text('Notifications', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const NotificationTile(message: 'Feedback requested on Project x'),
            const NotificationTile(
                message: 'Validation issue detected in Project y'),
            // Bottom Section - Single Large Button
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Project Name Input Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProjectNameInputScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20), // Adjust padding for size
                  textStyle: const TextStyle(
                      fontSize:
                          20), // Increase font size for better readability
                ),
                child: const Text('New Project'),
              ),
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

  const ProjectCard(
      {required this.projectName, required this.status, super.key});

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
