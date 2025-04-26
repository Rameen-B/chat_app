import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rameen FLutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              // Log user out
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(child: Text('Logged in!')),
    );
  }
}
