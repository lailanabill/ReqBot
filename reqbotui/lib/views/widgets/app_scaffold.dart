import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title; // Title for the AppBar
  final Widget body; // Main content of the Scaffold
  final Widget? floatingActionButton; // Optional floating action button
  final bool showDrawer; // Whether to show the drawer

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: showDrawer ? _buildDrawer(context) : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/HomeScreen');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pushNamed(context, '/FavoritesScreen');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Mail'),
            onTap: () {
              Navigator.pushNamed(context, '/MailPage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pushNamed(context, '/sign-in');
            },
          ),
        ],
      ),
    );
  }
}
