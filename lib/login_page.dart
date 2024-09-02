import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screen/journey.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  String _role = 'Anonymous';
  String _displayedEmail = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Query Firestore to get the role
        final userDoc = await _firestore
            .collection('Students')
            .doc(email)
            .get();

        if (userDoc.exists) {
          setState(() {
            _role = userDoc.data()?['role'] ?? 'Student';
            _displayedEmail = email;
          });
        } else {
          final teacherDoc = await _firestore
              .collection('Teachers')
              .doc(email)
              .get();

          if (teacherDoc.exists) {
            setState(() {
              _role = teacherDoc.data()?['role'] ?? 'Teacher';
              _displayedEmail = email;
            });
          } else {
            setState(() {
              _role = 'Anonymous';
              _displayedEmail = email;
            });
          }
        }

        Navigator.pushReplacementNamed(
          context,
          '/journey',
          arguments: Journey(),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Email or password is incorrect';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            color: Color(0xFFEEEEEE), // Title text color
          ),
        ),
        backgroundColor: Color(0xFF222831), // AppBar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFEEEEEE), // Icon color
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/intro');
          },
        ),
      ),
      backgroundColor: Color(0xFF393E46), // Background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'Thank you. ChatGPT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEEEEEE), // Text color
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)), // Label color
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color on error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color on focus with error
                  ),
                  errorStyle: TextStyle(color: Color(0xFF00ADB5)), // Error text color
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Color(0xFFEEEEEE)), // Text color
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
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
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)), // Label color
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color on error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5), width: 2.0), // Outline color on focus with error
                  ),
                  errorStyle: TextStyle(color: Color(0xFF00ADB5)), // Error text color
                ),
                obscureText: true,
                style: TextStyle(color: Color(0xFFEEEEEE)), // Text color
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Color(0xFF00ADB5), // Error text color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 15), // Reduced the space here
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ADB5), // Button color
                  foregroundColor: const Color(0xFFEEEEEE), // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15.0), // Increased the padding for height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0), // Border radius
                  ),
                  minimumSize: Size(220.0, 50.0), // Set width and minimum height
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Font size
                ),
              ),
              SizedBox(height: 10), // Reduced the space here
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent), // Removes hover effect
                ),
                child: Text(
                  'Don\'t have an account? Register here.',
                  style: TextStyle(color: Color(0xFFEEEEEE)), // Text color
                ),
              ),
              SizedBox(height: 20),
              Text(
                _displayedEmail.isNotEmpty
                    ? 'Logged in as: $_displayedEmail ($_role)'
                    : '',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFEEEEEE), // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
