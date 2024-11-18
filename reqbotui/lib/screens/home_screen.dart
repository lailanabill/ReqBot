import 'package:flutter/material.dart';
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
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
            