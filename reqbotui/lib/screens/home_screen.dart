import 'package:flutter/material.dart';
import 'package:reqbotui/screens/record.dart';
import 'package:reqbotui/screens/upload_convert.dart';
import 'project_name_input_screen.dart'; // Import the new screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFFF6F7FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xFF3F51B5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Projects Section
                  const Text(
                    'Recent Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        childAspectRatio: 1.5, // Aspect ratio of each card
                        crossAxisSpacing: 16, // Spacing between columns
                        mainAxisSpacing: 16, // Spacing between rows
                      ),
                      itemCount: 3, // Number of projects
                      itemBuilder: (context, index) {
                        final projectNames = [
                          'Project x',
                          'Project y',
                          'Project z'
                        ];
                        final projectStatuses = [
                          'completed',
                          'attention_needed',
                          'in_progress'
                        ];

                        // Add animations to cards
                        return AnimatedProjectCard(
                          projectName: projectNames[index],
                          status: projectStatuses[index],
                        );
                      },
                    ),
                  ),

                  // Notifications Section
                  const SizedBox(height: 16),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: const [
                        NotificationButton(
                            message: 'Feedback requested on Project x'),
                        SizedBox(height: 10),
                        NotificationButton(
                            message: 'Validation issue detected in Project y'),
                      ],
                    ),
                  ),

                  // Bottom Section - Single Large Button
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Project Name Input Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ProjectNameInputScreen()),
                          // const Record()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      child: const Text(
                        'New Project',
                        style: TextStyle(color: Color(0xFF3F51B5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Project Card with InkWell Splash
class AnimatedProjectCard extends StatelessWidget {
  final String projectName;
  final String status;

  const AnimatedProjectCard({required this.projectName, required this.status});

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

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.8, end: 1),
      curve: Curves.easeOut,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: () {
              // Handle card tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$projectName tapped')),
              );
            },
            splashColor: Colors.blue.withOpacity(0.3), // InkWell splash color
            borderRadius: BorderRadius.circular(8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(projectName),
                trailing: Icon(icon, color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Notification Buttons with Shadows
class NotificationButton extends StatelessWidget {
  final String message;

  const NotificationButton({required this.message});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message tapped')),
        );
      },
      splashColor: Colors.blue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF3F51B5)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
