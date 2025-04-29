import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/new_message.dart';
import 'package:chat_app/widgets/chat_messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    
    fcm.subscribeToTopic('chat');
    // final token = await fcm.getToken();
    // print('FCM Token: $token');
  }

  @override
  void initState() {
    super.initState();
    if (!Platform.isWindows) {
      setupPushNotifications();
    }
  }

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
      body: Column(children: [Expanded(child: ChatMessages()), NewMessage()]),
    );
  }
}
