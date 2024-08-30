import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screen/journey.dart'; // Import your Journey class

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _role;
  String? _email;

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch user role from Firestore
        final userEmail = userCredential.user?.email;
        if (userEmail != null) {
          _email = userEmail;
          await _fetchUserRole(userEmail);

          // Navigate to the Journey screen with the user's role
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Journey(role: _role ?? 'Anonymous'),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in as $email')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email or password is incorrect')),
        );
      }
    }
  }

  Future<void> _fetchUserRole(String email) async {
    try {
      final studentsDoc = await _firestore.collection('Students').where('email', isEqualTo: email).get();
      final teachersDoc = await _firestore.collection('Teachers').where('email', isEqualTo: email).get();

      if (studentsDoc.docs.isNotEmpty) {
        setState(() {
          _role = 'Student';
        });
      } else if (teachersDoc.docs.isNotEmpty) {
        setState(() {
          _role = 'Teacher';
        });
      } else {
        setState(() {
          _role = 'Unknown'; // Handle case where email is not found in either collection
        });
      }
    } catch (e) {
      setState(() {
        _role = 'Error fetching role';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Thank you. ChatGPT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                        caseSensitive: false,
                      );
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 20),
                  if (_email != null && _role != null)
                    Text(
                      'Email: $_email\nRole: $_role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
