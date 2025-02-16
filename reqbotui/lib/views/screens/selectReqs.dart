import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:reqbot/views/screens/structured_requirements.dart';

class SelectReqs extends StatefulWidget {
  final String myreqs;

  SelectReqs({required this.myreqs});

  @override
  _SelectReqsState createState() => _SelectReqsState();
}

class _SelectReqsState extends State<SelectReqs> {
  List<String> items = [];
  Map<String, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    sendPostRequest(); // Send request when page loads
  }

  Future<void> sendPostRequest() async {
    final url = Uri.parse(
        "https://oooo-1016128810332.us-central1.run.app/reqs"); // Replace with your API endpoint
    try {
      // Define your block of text
      String textBlock = widget.myreqs;

      // Send a POST request with the text payload in JSON format
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"inputString": textBlock}),
      );

      if (response.statusCode == 200) {
        List<String> responseList =
            List<String>.from(jsonDecode(response.body)["sentences"]);

        setState(() {
          items = responseList;
          selectedItems = {for (var item in items) item: false};
        });
      } else {
        print("Failed to fetch data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Second Page")),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: items.map((item) {
                      return CheckboxListTile(
                        title: Text(item),
                        value: selectedItems[item],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedItems[item] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StructuredRequirementsScreen(),
                      ),
                    ),
                    child: Text('Next'),
                  ),
                ),
              ],
            ),
    );
  }
}
