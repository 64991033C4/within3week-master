import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/student_widget.dart';
import '../components/teacher_widget.dart';

// Main Journey Class
class Journey extends StatelessWidget {
  final String role;

  const Journey({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Guest';

    Widget roleSpecificWidget;

    switch (role) {
      case 'Student':
        roleSpecificWidget = StudentWidget(userEmail: userEmail);
        break;
      case 'Teacher':
        roleSpecificWidget = TeacherWidget(userEmail: userEmail);
        break;
      default:
        roleSpecificWidget = DefaultWidget(); // Fallback in case of an unknown role
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$role Journey'),
            Text(
              userEmail,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: roleSpecificWidget,
    );
  }
}

// DefaultWidget Class
class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome to the Journey!', style: TextStyle(fontSize: 24));
  }
}

// Event Class
class Event {
  final String title;
  final String description;
  final String room;
  final DateTime date;
  final String creator;

  Event({
    required this.title,
    required this.description,
    required this.room,
    required this.date,
    required this.creator
  });
}
