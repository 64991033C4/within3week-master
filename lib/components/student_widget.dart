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
        .collection('Students')
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

    final events = snapshot.docs.map((doc) {
      final data = doc.data();
      return Event(
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        room: data['room'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
      );
    }).toList();

    setState(() {
      _selectedEvents.value = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return ListView(
                children: events.map((event) {
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text('${event.description}\nRoom: ${event.room}'),
                    leading: Icon(Icons.event),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
