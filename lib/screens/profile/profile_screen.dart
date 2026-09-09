import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
 

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _auth.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          Center(
            child: CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 45),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              user?.email ?? 'User',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? 'Not available'),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Account'),
              subtitle: const Text('Smart Expense Tracker'),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                _logout(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
