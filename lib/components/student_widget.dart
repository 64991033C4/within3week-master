import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '.././screen/journey.dart'; // Import the Event class

class StudentWidget extends StatefulWidget {
  final String userEmail;

  const StudentWidget({Key? key, required this.userEmail}) : super(key: key);

  @override
  _StudentWidgetState createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final CalendarFormat _calendarFormat;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _studentRoom;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _selectedEvents = ValueNotifier([]);
    _fetchStudentRoom(); // Fetch student room information
    _fetchEventsForDay(_selectedDay); // Fetch events initially
  }

  Future<void> _fetchStudentRoom() async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: widget.userEmail.toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _studentRoom = data['room'];
      });
      _fetchEventsForDay(_selectedDay); // Fetch events after getting the room
    }
  }

  Future<void> _fetchEventsForDay(DateTime day) async {
    if (_studentRoom == null) return;

    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('room', isEqualTo: _studentRoom)
        .get();

    final events = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();

      final creatorDoc = await _firestore
        .collection('users')
        .doc(data['creator'])
        .get();
      final creatorName = creatorDoc.exists ? creatorDoc.data()!['name'] ?? 'Loading...' : 'Loading...';

      return Event(
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        room: data['room'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        creator: creatorName ?? ''
      );
    }).toList());

    setState(() {
      _selectedEvents.value = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF393E46), // Set the background color
      child: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _fetchEventsForDay(
                      selectedDay); // Fetch events for the new selected day
                });
              }
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => [], // Return an empty list to hide dots
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Color(0xFFEEEEEE)), // Set the header title text color
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFEEEEEE)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFEEEEEE)),
              headerPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              // Hide dots
              markersMaxCount: 0,
              markerDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              defaultTextStyle: TextStyle(color: Color(0xFFEEEEEE)), // Set the default weekday text color
              weekendTextStyle: TextStyle(color: Color(0xFFEEEEEE)), // Set the weekend text color
              todayTextStyle: TextStyle(color: Color(0xFFEEEEEE)), // Set the today's text color
              selectedTextStyle: TextStyle(color: Color(0xFFEEEEEE)), // Set the selected day text color
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                return ListView(
                  children: events.map((event) {
                    return Card(
                      color: Color(0xFF00ADB5), // Set the card background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                        title: Text(
                          event.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEEEEEE)), // Set the title text color
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.description,
                              style: TextStyle(fontSize: 16, color: Color(0xFFEEEEEE)), // Set the description text color
                            ),
                            Text(
                              '${event.creator}',
                              style: TextStyle(color: Color(0xFFEEEEEE)), // Set the creator text color
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          child: Icon(Icons.event),
                          backgroundColor: Color(0xFF393E46),
                          foregroundColor: Colors.white,
                        ),
                        onTap: () {
                          // Empty function for now
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
