import 'package:flutter/material.dart';

class StructuredRequirementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF3F51B5),
        elevation: 0,
        title: Text(
          "Requirements", // Placeholder, can be adjusted if needed
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/profile.jpg'), // Profile image
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Structured Requirements",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Pending Tasks", // "+" sign removed
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // FloatingActionButton Removed
                ],
              ),
            ),
          ),

          // Task List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTaskItem(
                  context,
                  iconColor: Colors.blue,
                  title: "Use Case",
                  status: "Pending",
                  statusColor: Colors.red,
                ),
                _buildTaskItem(
                  context,
                  iconColor: Colors.pink,
                  title: "SRS",
                  status: "Completed",
                  statusColor: Colors.green,
                ),
                _buildTaskItem(
                  context,
                  iconColor: Colors.green,
                  title: "UML",
                  status: "Pending",
                  statusColor: Colors.red,
                ),
                _buildTaskItem(
                  context,
                  iconColor: Colors.orange,
                  title: "Requirements",
                  status: "Completed",
                  statusColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context,
      {required Color iconColor,
      required String title,
      required String status,
      required Color statusColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Task Icon
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder, color: iconColor, size: 28),
          ),
          SizedBox(width: 16),
          // Task Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Task Status
          Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
