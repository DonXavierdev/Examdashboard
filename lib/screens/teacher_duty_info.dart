import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (BuildContext context) {
        return TeacherDuty();
      },
    ),
  ));
}

Widget dateButton(String date, String day, isHighlighted) {
  return Container(
    padding: isHighlighted ? EdgeInsets.all(4) : null,
    decoration: isHighlighted
        ? BoxDecoration(
            color: Color(0xFFA0E4C3),
            borderRadius: BorderRadius.circular(10),
          )
        : null,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () {
            print('$date pressed');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: 15, right: 15),
            minimumSize: Size(20, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: isHighlighted ? Color(0xFFA0E4C3) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            date,
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
        ),
        Text(
          day,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class TeacherDuty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Teacher Dashboard',
            style: TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Handle menu button pressed
                print('Menu Button Pressed');
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Handle user icon button pressed
                print('User Icon Button Pressed');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                const Text(
                  'SPK03445',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Raleway',
                  ),
                ),
                const Text(
                  'Department',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Raleway',
                  ),
                ),
                const Text(
                  'Computer Science',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Raleway',
                  ),
                ),
                const Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Number of Duties',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Friday duties',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'You have an upcoming invigilation duty on 27/02/2024',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Raleway',
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    dateButton("25", "SAT", true),
                    dateButton("26", "SUN", false),
                    dateButton("27", "MON", true),
                    dateButton("28", "TUE", false),
                  ],
                ),
                SizedBox(height: 20),
                const Text(
                  'Invigilation Duty Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Raleway',
                  ),
                ),
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Text 1',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 2',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Text 3',
                    style: TextStyle(fontSize: 18),
                  ),
                  // Add more Text widgets as needed
                ],
              )

              ],
            ),
          ),
        ),
      );
  }
}
