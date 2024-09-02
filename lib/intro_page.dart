import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    const LatLng kosenkmitl = LatLng(13.72699, 100.7789);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Subscriber Service',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
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
              child: const Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
            onPressed: () {
              // Handle user profile button press
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      '       KOSEN-KMITL is an educational institution that was established according to '
                      'the project to develop manpower in engineering, technology, and innovation. '
                      'Divided into three branches: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Mechatronics Engineering',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '• Computer Engineering',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '• Electrical Engineering and Electronic Engineering',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'KOSEN-KMITL Location',
                      style: TextStyle(fontSize: 20),
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
                          const Marker(
                            markerId: MarkerId('KosenKmitl'),
                            position: kosenkmitl,
                            infoWindow: InfoWindow(title: 'KOSEN-KMITL'),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Coordinates: 13.72699, 100.7789',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
