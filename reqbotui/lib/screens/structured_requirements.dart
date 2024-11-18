import 'package:flutter/material.dart';

class StructuredRequirementsScreen extends StatelessWidget {
  const StructuredRequirementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requirements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
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
                        style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Pending Tasks",
                        style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTaskItem(context, iconColor: Colors.blue, title: "Use Case", status: "Pending", statusColor: Colors.red),
                _buildTaskItem(context, iconColor: Colors.pink, title: "SRS", status: "Completed", statusColor: Colors.green),
                _buildTaskItem(context, iconColor: Colors.green, title: "UML", status: "Pending", statusColor: Colors.red),
                _buildTaskItem(context, iconColor: Colors.orange, title: "Requirements", status: "Completed", statusColor: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, {required Color iconColor, required String title, required String status, required Color statusColor}) {
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Text(
            status,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ],
      ),
    );
  }
}