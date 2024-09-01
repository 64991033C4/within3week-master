import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/student_widget.dart';
import '../components/teacher_widget.dart';

class Journey extends StatefulWidget {
  @override
  _JourneyState createState() => _JourneyState();
}

class _JourneyState extends State<Journey> {
  String _role = 'Anonymous';
  String _userEmail = 'Guest';

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email?.toLowerCase();
      setState(() {
        _userEmail = email ?? 'Guest';
      });

      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          _role = userDoc.docs.first.data()['role'] ?? 'Anonymous'; // how to get key role in this doc
        });
      } else {
        setState(() {
          _role = 'Anonymous';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User role not found. Please contact support.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget roleSpecificWidget;

    switch (_role) {
      case 'Student':
        roleSpecificWidget = StudentWidget(userEmail: _userEmail);
        break;
      case 'Teacher':
        roleSpecificWidget = TeacherWidget(userEmail: _userEmail);
        break;
      default:
        roleSpecificWidget = DefaultWidget();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/intro');
            },
          ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('$_role')),
            Center(child: Text(
              _userEmail,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),)
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
