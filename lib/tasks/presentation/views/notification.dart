import 'package:flutter/material.dart';
import 'package:task_management/tasks/utils/notifications.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final emailPrefix = email.split('@').first.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationManager.showNotification(fileName: emailPrefix);
          },
          child: const Text(
            'Show Notifications',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
