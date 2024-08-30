import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import 'screen/journey.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: "466200760101-7ekla5g4b8oooql11qj03a1cjh6h4udh.apps.googleusercontent.com"),
            ],
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }

        final user = snapshot.data!;
        final email = user.email ?? '';

        // Check if the email ends with '@kmitl.ac.th'
        if (email.endsWith('@kmitl.ac.th')) {
          return const Journey(role: 'Student');
        } else if (email.endsWith('@gmail.com')){
          return const Journey(role: 'Teacher');
        }else {
          return const Journey(role: 'Log inR');
        }
      },
    );
  }
}
