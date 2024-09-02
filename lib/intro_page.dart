import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:within3week/screen/journey.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleMouseEnter() {
    _controller?.forward();
  }

  void _handleMouseExit() {
    _controller?.reverse();
  }

  void _handleNavigation(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/journey',
        (Route<dynamic> route) => false,
        arguments: Journey(),
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const LatLng kosenkmitl = LatLng(13.72699, 100.7789);

    return Scaffold(
      backgroundColor: const Color(0xFF393E46), // Background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831), // AppBar color
        title: const Text(
          'Event Subscriber Service',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEEEEEE), // Title text color
          ),
        ),
        actions: [
          MouseRegion(
            onEnter: (_) => _handleMouseEnter(),
            onExit: (_) => _handleMouseExit(),
            child: Transform.scale(
              scale: _scaleAnimation?.value ?? 1.0,
              child: IconButton(
                icon: Container(
                  margin: const EdgeInsets.all(5.0),
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications, // Bell icon
                    color: const Color(0xFF00ADB5), // Icon color
                  ),
                ),
                onPressed: () => _handleNavigation(context),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'KOSEN-KMITL is an educational institution that was established according to '
                    'the project to develop manpower in engineering, technology, and innovation. '
                    'Divided into three branches: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFEEEEEE), // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Mechatronics Engineering',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFEEEEEE), // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '• Computer Engineering',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFEEEEEE), // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '• Electrical Engineering and Electronic Engineering',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFEEEEEE), // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222831), // Container color
                      borderRadius: BorderRadius.circular(8.0),
                      // Removed boxShadow to eliminate white shadow
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'KOSEN-KMITL Location',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFEEEEEE), // Text color
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: kosenkmitl,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('KosenKmitl'),
                                position: kosenkmitl,
                                infoWindow:
                                    const InfoWindow(title: 'KOSEN-KMITL'),
                              ),
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Coordinates: 13.72699, 100.7789',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFEEEEEE), // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Added space to ensure the button is visible
                ],
              ),
            ),
          ),
          Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: SizedBox(
      width: 200.0, // Set your desired width here
      child: TextButton(
        onPressed: () => _handleNavigation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00ADB5), // Button color
          foregroundColor: const Color(0xFFEEEEEE), // Text color
          padding: const EdgeInsets.symmetric(vertical: 15.0), // Adjust padding as needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0), // Border radius
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Font size
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
