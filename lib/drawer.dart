import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('User'),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('resources/avatars/person.png'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat'),
            onTap: () {
              // Handle new chat action
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Conversation 1'),
            onTap: () {
              // Handle conversation 1 action
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Conversation 2'),
            onTap: () {
              // Handle conversation 2 action
            },
          ),
          // Add more conversation areas here
        ],
      ),
    );
  }
}
