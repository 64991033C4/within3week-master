import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:within3week/components/teacher_widget.dart';

class TeacherEventPage extends StatefulWidget {
  final String userEmail;

  TeacherEventPage({required this.userEmail});

  @override
  _TeacherEventPageState createState() => _TeacherEventPageState();
}

class _TeacherEventPageState extends State<TeacherEventPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<List<Event>> _selectedEvents =
      ValueNotifier<List<Event>>([]);

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final userDoc = await _firestore
        .collection('users')
        .where('email', isEqualTo: widget.userEmail)
        .limit(1)
        .get();

    final snapshot = await _firestore
        .collection('events')
        .where('creator', isEqualTo: userDoc.docs.first.id)
        .get();

    final events = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();

      final creatorDoc =
          await _firestore.collection('users').doc(data['creator']).get();
      final creatorName = creatorDoc.exists
          ? creatorDoc.data()!['name'] ?? 'Loading...'
          : 'Loading...';

      return Event(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        room: data['room'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        creator: creatorName,
      );
    }).toList());

    setState(() {
      _selectedEvents.value = events;
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      // Refresh events after deletion
      _fetchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Scheduled Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddEventPage(userEmail: widget.userEmail)),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Event>>(
        valueListenable: _selectedEvents,
        builder: (context, events, _) {
          return ListView(
            children: events.map((event) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  title: Text(
                    event.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${event.room}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  leading: CircleAvatar(
                    child: Icon(Icons.event),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEvent(event.id);
                    },
                  ),
                  onTap: () {
                    // Action when event is tapped
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class Event {
  final String id; // Add this field to hold the document ID
  final String title;
  final String description;
  final String room;
  final DateTime date;
  final String creator;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.room,
    required this.date,
    required this.creator,
  });
}


// Replace this with your existing AddEventPage
class AddEventPage extends StatelessWidget {
  final String userEmail;

  AddEventPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: TeacherWidget(userEmail: userEmail)
    );
  }
}
