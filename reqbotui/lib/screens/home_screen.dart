import 'package:flutter/material.dart';
import 'project_name_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
            const Text('Recent Projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 3,
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
            const SizedBox(height: 16),
            const Text('Notifications', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const NotificationTile(message: 'Feedback requested on Project x'),
            const NotificationTile(
                message: 'Validation issue detected in Project y'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProjectNameInputScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
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

  const ProjectCard({Key? key, required this.projectName, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

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

  const NotificationTile({Key? key, required this.message}) : super(key: key);

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
