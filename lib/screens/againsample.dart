import 'package:flutter/material.dart';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Upcoming Exam'),
          
        ),
        body: ExamScreen(),
      ),
    );
  }
}

class ExamScreen extends StatefulWidget {
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Map<String, dynamic>> userAlloc = [
    {'date': '2024-04-24'},
    {'date': '2024-05-10'},
    {'date': '2024-05-15'},
  ];

  @override
  Widget build(BuildContext context) {
      DateTime today = DateTime.now();

    DateTime? upcomingDate; 
    
    for (var allocation in userAlloc) {
      DateTime allocDate = DateTime.parse(allocation['date']);
        
     if (allocDate.year == today.year &&
        allocDate.month == today.month &&
        allocDate.day == today.day) {
        
        upcomingDate = today;
        break;
      }
      else if (allocDate.isAfter(today) &&
          (upcomingDate == null || allocDate.isBefore(upcomingDate))) {
        upcomingDate = allocDate;
        
      }
    }

    DateTime displayDate = upcomingDate ?? today;

    return Center(
      child: Text(
        'You have an upcoming exam on ${displayDate.toString().split(' ')[0]}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Raleway',
          
        ),
      ),
    );
  }
}
