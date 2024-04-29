import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:async';
import 'package:intl/intl.dart';
// import 'dart:developer';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (BuildContext context) {
        return const StudentDashboard(
          userType: '',userDept: '',userName: '',userPrn: '',userNotify:[],userAlloc: [],
          );
      },
    ),
  ));
}

class CustomLoadingScreen extends StatefulWidget {
  const CustomLoadingScreen({super.key});
  @override
  CustomLoadingScreenState createState() => CustomLoadingScreenState();
}

class CustomLoadingScreenState extends State<CustomLoadingScreen> {
  double _size = 150.0;
  bool _isGrowing = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer to toggle the size of the logo
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _size = _isGrowing ? 180.0 : 150.0;
        _isGrowing = !_isGrowing;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: _size,
            height: _size,
            child: Image.asset(
              'assets/logo.png', 
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading...',style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}


class StudentDashboard extends StatefulWidget {
  final String userType;
  final String userDept;
  final String userName;
  final String userPrn;
  final List<String> userNotify;
  final  List<Map<String, dynamic>> userAlloc;
  
  

  const StudentDashboard({
    Key? key,
    required this.userType,
    required this.userDept,
    required this.userName,
    required this.userPrn,
    required this.userNotify,
    required this.userAlloc,
  }) : super(key: key);

  @override
  StudentDashboardState createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  bool showInvigilationInfo = false;
  late Future<void> _loadingFuture;
  int selectedDateIndex = 0; 
  @override
  void initState() {
    super.initState();
    _loadingFuture = Future.delayed(const Duration(seconds: 2)); // Simulating loading for 2 seconds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Student Dashboard',style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'logout',child: Text('Logout'),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),(route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          double containerWidth = MediaQuery.of(context).size.width * 1;
          DateTime today = DateTime.now();
          DateTime? upcomingDate; 
        
          for (var allocation in widget.userAlloc) {
            DateTime allocDate = DateTime.parse(allocation['date']);
            if (allocDate.isAfter(today) &&
                (upcomingDate == null || allocDate.isBefore(upcomingDate))) {
              upcomingDate = allocDate;
            }
          }
          DateTime displayDate = upcomingDate ?? today;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoadingScreen();
          } else {
            return SingleChildScrollView(
              
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, 
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle( fontSize: 24,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                            ),
                          ),
                          Text(
                            widget.userPrn,
                            style: const TextStyle(fontSize: 18,fontWeight: FontWeight.normal,fontFamily: 'Raleway',
                            ),
                          ),

                          const SizedBox(height: 30),

                          Container(
                            width: double.infinity, 
                            decoration: BoxDecoration(
                              color: Colors.grey[400],borderRadius: BorderRadius.circular(10), 
                            ),
                            padding: const EdgeInsets.all(10), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Programme',
                                  style: TextStyle(
                                    fontSize: 24,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                                  ),
                                ),
                                Text(
                                  widget.userDept,
                                  style: const TextStyle(
                                    fontSize: 18,fontWeight: FontWeight.normal,fontFamily: 'Raleway',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400], borderRadius: BorderRadius.circular(10), 
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Padding(
                                      padding: EdgeInsets.only(left: 15,top: 5,right: 0,bottom: 0,
                                      ), 
                                      child: Text(
                                        'Semester',
                                        style: TextStyle(
                                          fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',color: Colors.black, 
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(left: 15,top: 0,right: 0,bottom: 5,
                                      ), 
                                      child: Text(
                                        '4',
                                        style: TextStyle(
                                          fontSize: 18,fontWeight: FontWeight.normal,fontFamily: 'Raleway',color: Colors.black, 
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],borderRadius: BorderRadius.circular(10), 
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15,top: 5,right: 0,bottom: 0,
                                      ), 
                                      child: Text(
                                        'CGPA',
                                        style: TextStyle(
                                          fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',color: Colors.black, 
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15,top: 0,right: 0,bottom:5,
                                      ), 
                                      child: Text(
                                        '6.87',
                                        style: TextStyle(
                                          fontSize: 18,fontWeight: FontWeight.normal,fontFamily: 'Raleway',color: Colors.black, 
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                          const SizedBox(height: 15),

                              Text(
                                'upcoming exam date: ${displayDate.toString().split(' ')[0]}', 
                                style: const TextStyle(
                                  fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                                ),
                              ),
                        ],
                      ),
                    ),

                    
                    const SizedBox(height: 30),
                    
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    Row(
                        
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                        for (var i = 0; i < widget.userAlloc.length; i++)
                          dateButton(
                            widget.userAlloc[i]['date'].split('-').last,getDayOfWeek(widget.userAlloc[i]['date']), 
                            true,
                            () {
                              setState(() {
                                showInvigilationInfo = true;
                                selectedDateIndex = i; 
                              });
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    if (showInvigilationInfo) ...[
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              showInvigilationInfo = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color:const Color(0xFFA0E4C3),borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'See Alerts',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Raleway'),
                            ),
                          ),
                        ),

                    const SizedBox(height: 10),
                          
                         Container(
                            decoration: BoxDecoration(
                              color: Colors.white,borderRadius: BorderRadius.circular(10),
                                                    ),
                            padding: const EdgeInsets.all(20), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],borderRadius: BorderRadius.circular(10),
                                                    ), 
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Examination course code',
                                  style: TextStyle(fontSize: 14, color: Colors.black), 
                                ),
                                Text(
                                  widget.userAlloc[selectedDateIndex]['course_code'],
                                  style: const TextStyle(fontSize: 18, color: Colors.black), 
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],borderRadius: BorderRadius.circular(10),
                                              ), 
                      padding: const EdgeInsets.all(10), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Subject Name',
                            style: TextStyle(fontSize: 14, color: Colors.black), // Set text color to white
                          ),
                          Text(
                            widget.userAlloc[selectedDateIndex]['subject_name'],
                            style: const TextStyle(fontSize: 18, color: Colors.black), // Set text color to white
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],borderRadius: BorderRadius.circular(10),
                                              ), 
                      padding: const EdgeInsets.all(10), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Room Name',
                            style: TextStyle(fontSize: 14, color: Colors.black), // Set text color to white
                          ),
                          Text(
                            widget.userAlloc[selectedDateIndex]['room_name'],
                            style: const TextStyle(fontSize: 18, color: Colors.black), // Set text color to white
                          ),
                        ],
                      ),
                    ),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              'Facing this way',
                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 20),
                          
                          Container(
                            width:containerWidth,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(left:containerWidth * 0.15,right: containerWidth * 0.1), 
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            const SizedBox(height: 20),
                            BoxGrid(
                              columns: widget.userAlloc[selectedDateIndex]['room_columns'] * 2,
                              rows: widget.userAlloc[selectedDateIndex]['room_rows'],
                              studentRow: widget.userAlloc[selectedDateIndex]['student_row'],
                              studentCol: widget.userAlloc[selectedDateIndex]['student_col'],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                        ],
                      ),
                    ),    
                    ]   

                    else ...[

                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,borderRadius: BorderRadius.circular(8),
                          ), 
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.userNotify.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10), 
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],borderRadius: BorderRadius.circular(8),
                                ),  
                                padding: const EdgeInsets.all(10),
                                child: NotificationButton(
                                  icon: Icons.notifications_none,
                                  message: widget.userNotify[index],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                      const SizedBox(height: 20),
                      
                      const Text(
                        'Performance',
                        style: TextStyle(
                          fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                       decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(10), 
                        ),
                      padding: const EdgeInsets.all(20),
                      child:                   
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance',
                            style: TextStyle(
                              fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Semester 1 | CGPA 6.87',
                                  style: TextStyle(
                                    fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataTable(
                            columnSpacing: 20,
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Course')),
                              DataColumn(label: Text('Grade')),
                              DataColumn(label: Text('SCPA')),
                            ],
                            rows: sampleData
                                .map(
                                  (datas) => DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 0),
                                          child: Text(datas[0]),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(datas[1]),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(datas[2]),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    )

                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

Widget dateButton(
    String date, String day, bool isHighlighted, Function() onPressed) {
  return Container(
    decoration: isHighlighted
        ? BoxDecoration(
            color: Colors.white,borderRadius: BorderRadius.circular(10),
          )
        : null,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextButton(
  onPressed: onPressed,
  style: TextButton.styleFrom(
    padding: const EdgeInsets.only(top:10,bottom:10,left: 15, right: 15),
    minimumSize: const Size(20, 30),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: isHighlighted ? const Color(0xFFA0E4C3) : null,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        date,
        style: const TextStyle(
          color: Colors.black,fontSize: 25,
        ),
      ),
      Text(
        day,
        style: const TextStyle(
          color: Colors.black,fontSize: 10,
        ),
      ),
    ],
  ),
),
      ],
    ),
  );
}

class NotificationButton extends StatelessWidget {
  final IconData icon;
  final String message;

  const NotificationButton({Key? key, required this.icon, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, 
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 5),
        Flexible( 
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13, 
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Reminder'),
                  content: Text(
                    "This is a reminder for $message",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text(
            'See notification',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
class BoxGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final int studentRow;
  final int studentCol;

  const BoxGrid({super.key, required this.rows, required this.columns ,required this.studentRow ,required this.studentCol});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * columns, 
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
      ),
      itemBuilder: (BuildContext context, int index) {
        int rowIndex = index ~/ columns;
        int columnIndex = index % columns;
        if (columnIndex % 2 == 0) {
          return Row(
            children: [
              Expanded(child: Box(rowIndex: rowIndex, columnIndex: columnIndex,studentRow:studentRow,studentCol:studentCol)),
              Expanded(child: Box(rowIndex: rowIndex, columnIndex: columnIndex + 1,studentRow:studentRow,studentCol:studentCol)),
            ],
          );
        } else {
          return Container(); 
        }
      },
    );
  }
}

class Box extends StatelessWidget {
  final int rowIndex;
  final int columnIndex;
  final int studentRow;
  final int studentCol;

  const Box({super.key, required this.rowIndex, required this.columnIndex,required this.studentRow,required this.studentCol});

  @override
  Widget build(BuildContext context) {
    bool isGreen = rowIndex == studentRow && columnIndex  == studentCol; 
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        color: isGreen ? const Color(0xFFA0E4C3) : Colors.white, 
      ),
      height: 20, 
    );
  }
}
const List<List<String>> sampleData = [
  ['CCRCP05 - Optimization teChniques', 'A', '6.89'],
  ['COPCU70 - Fundamentals of Digital Science ', 'A', '4'],
  ['Physics', 'B', '3'],
  ['Computer Science', 'A', '3'],
  ['English', 'C', '3'],
];
String getDayOfWeek(String dateStr) {
  DateTime date = DateTime.parse(dateStr);
  return DateFormat('E').format(date); // 'E' represents the abbreviated day of week (e.g., "Mon", "Tue")
}