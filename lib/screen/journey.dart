import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main Journey Class
class Journey extends StatelessWidget {
  final String role;

  const Journey({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Guest';

    Widget roleSpecificWidget;

    switch (role) {
      case 'Student':
        roleSpecificWidget = StudentWidget(userEmail: userEmail);
        break;
      case 'Teacher':
        roleSpecificWidget = TeacherWidget();
        break;
      case 'Anonymous':
        roleSpecificWidget = AnonymousWidget();
        break;
      default:
        roleSpecificWidget = DefaultWidget(); // Fallback in case of an unknown role
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$role Journey'),
            Text(
              userEmail,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: roleSpecificWidget,
    );
  }
}

// StudentWidget Class
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
        .where('email', isEqualTo: widget.userEmail)
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
                _fetchEventsForDay(selectedDay); // Fetch events for the new selected day
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

// TeacherWidget Class
class TeacherWidget extends StatefulWidget {
  @override
  _TeacherWidgetState createState() => _TeacherWidgetState();
}

class _TeacherWidgetState extends State<TeacherWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'room': _roomController.text,
        'date': Timestamp.fromDate(_selectedDate),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _roomController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _roomController,
              decoration: InputDecoration(labelText: 'Room'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Selected Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null && selectedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                    }
                  },
                  child: Text('Select date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

// AnonymousWidget Class
class AnonymousWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome, Anonymous!', style: TextStyle(fontSize: 24));
  }
}

// DefaultWidget Class
class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome to the Journey!', style: TextStyle(fontSize: 24));
  }
}

// Event Class
class Event {
  final String title;
  final String description;
  final String room;
  final DateTime date;

  Event({
    required this.title,
    required this.description,
    required this.room,
    required this.date,
  });
}
