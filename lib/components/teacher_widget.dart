import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherWidget extends StatefulWidget {
  final String userEmail;

  const TeacherWidget({Key? key, required this.userEmail}) : super(key: key);

  @override
  _TeacherWidgetState createState() => _TeacherWidgetState();
}

class _TeacherWidgetState extends State<TeacherWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedRoom;

  DateTime _selectedDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _rooms = [
    'C1/1', 'C1/2', 'M1/1', 'M1/2', 
    'C2/1', 'C2/2', 'M2/1', 'M2/2', 
    'C3/1', 'C3/2', 'M3/1', 'M3/2', 
    'C4/1', 'C4/2', 'M4/1', 'M4/2', 
    'M5/1', 'M5/2'
  ];

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'room': _selectedRoom,
        'date': Timestamp.fromDate(_selectedDate),
        'creator': widget.userEmail
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully')),
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedRoom = _rooms[0]; // Reset to default value
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
    Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRoom,
              decoration: InputDecoration(labelText: 'Room'),
              items: _rooms.map((room) {
                return DropdownMenuItem<String>(
                  value: room,
                  child: Text(room),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoom = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a room';
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

       
