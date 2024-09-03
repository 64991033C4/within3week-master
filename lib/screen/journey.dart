import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/student_widget.dart';
import '../components/teacher_widget.dart';
import '../components/teacher_event_widget.dart';

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
          _role = userDoc.docs.first.data()['role'] ?? 'Anonymous';
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
        roleSpecificWidget = TeacherEventPage(userEmail: _userEmail);
        break;
      default:
        roleSpecificWidget = DefaultWidget();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF222831), // Set the AppBar color here
        iconTheme: IconThemeData(color: Color(0xFFEEEEEE)), // Set the icon color here
        titleTextStyle: TextStyle(
          color: Color(0xFFEEEEEE), // Set the text color here
          fontSize: 16, // Set the font size here
        ),
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
            Center(
              child: Text(
                _userEmail,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
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

class DefaultWidget extends StatefulWidget {
  @override
  _DefaultWidgetState createState() => _DefaultWidgetState();
}

class _DefaultWidgetState extends State<DefaultWidget> {
  bool _isHovered = false;

  Future<void> _handleLogoutAndRedirect() async {
    try {
      // Sign out the user
      await FirebaseAuth.instance.signOut();
      // Navigate to the intro page
      Navigator.pushReplacementNamed(context, '/intro');
    } catch (e) {
      // Show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF393E46), // Background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Congratulations',
              style: TextStyle(
                fontSize: 40, // Font size
                color: Color(0xFFEEEEEE), // Text color
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0), // Removed space
            Text(
              'You are failure.',
              style: TextStyle(
                fontSize: 40, // Font size
                color: Color(0xFFEEEEEE), // Text color
              ),
            ),
            SizedBox(height: 0), // Removed space
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHovered = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isHovered = false;
                });
              },
              child: ElevatedButton(
                onPressed: _handleLogoutAndRedirect, // Handle logout and redirect
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ADB5), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'EMOTIONAL DAMAGE!!!!',
                  style: TextStyle(
                    fontSize: 40, // Font size
                    color: _isHovered ? Color(0xFFEEEEEE) : Color(0xFF00ADB5), // Text color changes on hover
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    required this.creator,
  });
}
