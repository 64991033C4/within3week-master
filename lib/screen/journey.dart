import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Journey extends StatelessWidget {
  final String role;

  const Journey({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget roleSpecificWidget;

    switch (role) {
      case 'Student':
        roleSpecificWidget = StudentWidget();
        break;
      case 'Teacher':
        roleSpecificWidget = TeacherWidget();
        break;
      case 'Anonymous':
        roleSpecificWidget = AnonymousWidget();
        break;
      default:
        roleSpecificWidget =
            DefaultWidget(); // Fallback in case of an unknown role
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$role Journey'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Replace this with sign-out logic and navigation to the home page.
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: roleSpecificWidget,
    );
  }
}

class StudentWidget extends StatefulWidget {
  @override
  _StudentWidgetState createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock data for events
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2024, 8, 25): ['Math Homework', 'Science Project'],
    DateTime.utc(2024, 8, 26): ['English Essay', 'History Presentation'],
    DateTime.utc(2024, 8, 27): ['Music Practice', 'Art Workshop'],
  };

  @override
  Widget build(BuildContext context) {
    List<String> _selectedEvents = _events[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
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
            ),
          ),
        ),
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Events on ${_selectedDay?.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18),
            ),
          ),
        if (_selectedEvents.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_selectedEvents[index]),
                  ),
                );
              },
            ),
          )
        else if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No events on this day.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

class TeacherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome asdfjlaskjdf, Teacher!', style: TextStyle(fontSize: 24));
  }
}

class AnonymousWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome, Anonymous!', style: TextStyle(fontSize: 24));
  }
}

class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome to the Journey!', style: TextStyle(fontSize: 24));
  }
}
