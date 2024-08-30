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
              // Uncomment and configure GoogleProvider if you want to support Google sign-in
              // GoogleProvider(clientId: "YOUR_CLIENT_ID"),
            ],
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to FlutterFire, please register!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in or registering, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            // Optional: Customize additional properties if needed
          );
        }

        final user = snapshot.data!;
        final email = user.email ?? '';

        // Check if the email ends with '@kmitl.ac.th'
        if (email.endsWith('@kmitl.ac.th')) {
          return const Journey(role: 'Student');
        } else if (email.endsWith('@gmail.com')){
          return const Journey(role: 'Teacher');
        } else {
          return const Journey(role: 'Other');
        }
      },
    );
  }
}
