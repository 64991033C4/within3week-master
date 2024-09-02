import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'Student';
  String? _selectedRoom;
  final List<String> _rooms = [
    'C1/1', 'C1/2', 'M1/1', 'M1/2', 
    'C2/1', 'C2/2', 'M2/1', 'M2/2', 
    'C3/1', 'C3/2', 'M3/1', 'M3/2', 
    'C4/1', 'C4/2', 'M4/1', 'M4/2', 
    'M5/1', 'M5/2'
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define the error text style
  TextStyle get _errorTextStyle => TextStyle(color: Color(0xFF00ADB5));

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;

      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        Map<String, dynamic> userData = {
          'email': email,
          'name': name,
          'role': _selectedRole,
        };

        if (_selectedRole == 'Student' && _selectedRoom != null) {
          userData['room'] = _selectedRoom;
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .set(userData);

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Color(0xFFEEEEEE))),  // Set AppBar text color to #EEEEEE
        backgroundColor: Color(0xFF222831),  // Set the AppBar color to #222831
      ),
      backgroundColor: Color(0xFF393E46),  // Set background color to #393E46
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Color(0xFFEEEEEE)),  // Set text color to #EEEEEE
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)),  // Set label text color to #EEEEEE
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  errorStyle: _errorTextStyle,  // Set error text style
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Color(0xFFEEEEEE)),  // Set text color to #EEEEEE
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)),  // Set label text color to #EEEEEE
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  errorStyle: _errorTextStyle,  // Set error text style
                ),
                keyboardType: TextInputType.emailAddress,
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
                style: TextStyle(color: Color(0xFFEEEEEE)),  // Set text color to #EEEEEE
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)),  // Set label text color to #EEEEEE
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5 when error
                  ),
                  errorStyle: _errorTextStyle,  // Set error text style
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
              DropdownButtonFormField<String>(
                value: _selectedRole,
                style: TextStyle(color: Color(0xFFEEEEEE)),  // Set dropdown text color to #EEEEEE
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)),  // Set label text color to #EEEEEE
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                  ),
                  errorStyle: _errorTextStyle,  // Set error text style
                ),
                dropdownColor: Color(0xFF222831),  // Set dropdown menu color
                items: ['Student', 'Teacher'].map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    if (_selectedRole != 'Student') {
                      _selectedRoom = null;  // Reset room if role is not Student
                    }
                  });
                },
              ),
              if (_selectedRole == 'Student') ...[
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedRoom,
                  style: TextStyle(color: Color(0xFFEEEEEE)),  // Set dropdown text color to #EEEEEE
                  decoration: InputDecoration(
                    labelText: 'Room',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),  // Set label text color to #EEEEEE
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00ADB5)),  // Set outline color to #00ADB5
                    ),
                    errorStyle: _errorTextStyle,  // Set error text style
                  ),
                  dropdownColor: Color(0xFF222831),  // Set dropdown menu color
                  items: _rooms.map((room) {
                    return DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoom = value;
                    });
                  },
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ADB5),  // Set button color to #00ADB5
                  foregroundColor: Colors.white,  // Set text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
