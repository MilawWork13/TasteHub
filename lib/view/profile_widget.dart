import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            'Name: ${user?.displayName ?? 'Guest'}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Email: ${user?.email ?? 'No email'}',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
