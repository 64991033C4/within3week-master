import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:within3week/screen/journey.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Our App!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // User is logged in, navigate to the Journey page
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/journey',
                    (Route<dynamic> route) => false,
                    arguments: Journey(),
                  ); // or 'Teacher', depending on the user's role
                } else {
                  // User is not logged in, navigate to the LoginPage
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
