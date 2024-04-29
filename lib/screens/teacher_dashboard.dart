import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (BuildContext context) {
        return const TeacherDashboard(
          userType: '',userDept: '',userName: '',userPrn: '',userNotify: [], userAlloc: [],teacherNames:[],exchangeRequest:'' 
        );
      },
    ),
  ));
}
Future<void> markAttendance(String prn, int status) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/attendance/'),
      body: {'prn': prn, 'status': status.toString()},
    );

    if (response.statusCode == 200) {
      // Handle successful response if needed
    } else {
      // Handle error response if needed
    }
  } catch (e) {
    // Handle exception if HTTP request fails
  }
}

class TeacherDashboard extends StatefulWidget {
  final String userType;
  final String userDept;
  final String userName;
  final String userPrn;
  final List<String> userNotify;
  final  List<Map<String, dynamic>> userAlloc;
  final List<String> teacherNames;
  final String exchangeRequest;

  const TeacherDashboard({
    Key? key,
    required this.userType,
    required this.userDept,
    required this.userName,
    required this.userPrn,
    required this.userNotify,
    required this.userAlloc,
    required this.teacherNames,
    required this.exchangeRequest,
    
  }) : super(key: key);

  @override
  TeacherDashboardState createState() => TeacherDashboardState();
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
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _size = _isGrowing ? 180.0 : 150.0;
        _isGrowing = !_isGrowing;
      });
    });
  }
  @override
  void dispose() {
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
            duration:const Duration(milliseconds: 500),
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

class TeacherDashboardState extends State<TeacherDashboard> {
  bool showInvigilationInfo = false;
  late Future<void> _loadingFuture;
  int selectedDateIndex = 0; 
  int fridayCounter = 0; 
   List<bool> cardVisibility = [];
   bool _isVisible = true;
  @override
  void initState() {
    super.initState();
    countFridays();
    _loadingFuture = Future.delayed(const Duration(seconds: 0));
    initializeCardVisibility();
  }
  void initializeCardVisibility() {
    // Initialize card visibility list with true values
    cardVisibility = List.generate(
      widget.userAlloc[selectedDateIndex]['student_prns'].length,
      (index) => true,
    );
  }
void countFridays() {
    for (int i = 0; i < widget.userAlloc.length; i++) {
      String date = widget.userAlloc[i]['date']; 
      String dayOfWeek = getDayOfWeek(date); 
      if (dayOfWeek == 'Fri') {
        fridayCounter++; 
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor:Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoadingScreen();
          } else {
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
            return Padding(
              
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                     Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            Text(
                              widget.userPrn,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Department',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Raleway',
                                    ),
                                  ),
                                  Text(
                                    widget.userDept,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Raleway',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 15,top: 5,right: 0,bottom: 0),
                                          child: Text(
                                            'Number of Duties',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Raleway',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 15,top: 0,right: 0,bottom: 5),
                                          child: Text(
                                            '${widget.userAlloc.length}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'Raleway',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 15,top: 5,right: 0,bottom: 0),
                                          child: Text(
                                            'Friday duties',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Raleway',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 15,top: 0,right: 0,bottom:5),
                                          child: Text(
                                            '$fridayCounter',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'Raleway',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),

                            Text(
                                'upcoming invigilation duty date : ${DateFormat('dd-MM-yyyy').format(displayDate).toString().split(' ')[0]}', 
                                style: const TextStyle(
                                  fontSize: 12,fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                      SizedBox(height: 20),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            for (var i = 0; i < widget.userAlloc.length; i++)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8), // Adjust the horizontal spacing as needed
                                child: dateButton(
                                  widget.userAlloc[i]['date'].split('-').last, // Display only the day part
                                  getDayOfWeek(widget.userAlloc[i]['date']), // Function to get day of week
                                  true, // Assuming this value should always be true
                                  () {
                                    setState(() {
                                      showInvigilationInfo = true;
                                      selectedDateIndex = i; // Update the selected date index
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                  
                      SizedBox(height: 30),

                      if (showInvigilationInfo) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showInvigilationInfo = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFA0E4C3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'See Alerts',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Raleway'),
                                ),
                              ),
                            ),

                            
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String? selectedName;
                                    return AlertDialog(
                                      title: Text("Change this Duty"),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text("Your exchange duty message goes here."),
                                              SizedBox(height: 20), // Add spacing between message and dropdown
                                              DropdownButtonFormField<String>(
                                                value: selectedName,
                                                items:widget.teacherNames.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    selectedName = newValue;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Select Teacher',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (selectedName != null) {
                                              // Make HTTP POST request
                                              http.post(
                                                Uri.parse('http://127.0.0.1:8000/dutychange/'),
                                                body: {
                                                  'exchange_for': selectedName,
                                                  'exchange_by': widget.userPrn,
                                                  'friday_duty':'0',
                                                  'request_date':widget.userAlloc[selectedDateIndex]['date'],
                                                }
                                              );
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Change this Duty',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Raleway',
                                ),
                              ),
                            ),





                          ],
                        ),

                          

                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Room Name',
                                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userAlloc[selectedDateIndex]['room_name'], 
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              const Text(
                                'Mark Attendance', 
                                style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                              ),
                           
                              ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.userAlloc[selectedDateIndex]['student_prns'].length,
                              itemBuilder: (BuildContext context, int index) {
                                var prn = widget.userAlloc[selectedDateIndex]['student_prns'][index];
                                return Visibility(
                                  visible: cardVisibility[index], // Check visibility
                                  child: Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Text(prn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                                          const SizedBox(width: 100),
                                          TextButton(
                                            onPressed: () {
                                              markAttendance(prn, 1);
                                              setState(() {
                                                cardVisibility[index] = false; // Hide the card
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF74D4A6)),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              minimumSize: MaterialStateProperty.all<Size>(Size(35, 25)),
                                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                            child: Text('Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                          SizedBox(width: 5),
                                          TextButton(
                                            onPressed: () {
                                              markAttendance(prn, 0);
                                              setState(() {
                                                cardVisibility[index] = false; // Hide the card
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFE46D6D)),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              minimumSize: MaterialStateProperty.all<Size>(Size(35, 25)),
                                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                            child: Text('Absent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

   
                              
                            ],
                          ),
                        ),

                      ] else ...[

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

                        Container(
                        decoration: BoxDecoration(
                            color: Colors.white,borderRadius: BorderRadius.circular(8),
                          ), 
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Previous Duty Info',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway',
                            ),
                          ),
                          const SizedBox(height: 20),
                          if ( widget.userAlloc.isNotEmpty)
                            ...widget.userAlloc.map((allocation) {
                              DateTime allocDate = DateTime.parse(allocation['date']);
                              if (allocDate.isBefore(DateTime.now())) {
                                String dayOfWeek = DateFormat('EEEE').format(allocDate);
                                String formattedDate = DateFormat('dd/MM/yyyy').format(allocDate);
                                String roomName = allocation['room_name'];
                                String displayText = '$formattedDate - $dayOfWeek  ';
                                
                               return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                width: double.infinity,
                               child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    displayText,
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    roomName,
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                              );
                              } else {
                                return Container();
                              }
                            }).toList(),
                        ],
                      ),


                    ),
                    const SizedBox(height: 20),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,borderRadius: BorderRadius.circular(8),
                          ), 
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Incoming Duty Changes',
                            style: TextStyle(
                              fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Raleway',
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                        Visibility(
  visible: _isVisible,
child: Container(
  decoration: BoxDecoration(
    color: Colors.grey[400],
    borderRadius: BorderRadius.circular(8),
  ),
  margin: const EdgeInsets.only(bottom: 8),
  padding: const EdgeInsets.all(8),
  width: double.infinity,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          widget.exchangeRequest,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.start,
        ),
      ),
      if (widget.exchangeRequest != '') // Conditionally show buttons if widget.exchangeRequest is not empty
        SizedBox(width: 8), // Add some space between text and buttons
        Visibility(
          visible: widget.exchangeRequest != '',
          child: ElevatedButton(
            onPressed: () {
              http.post(
                Uri.parse('http://127.0.0.1:8000/exchange_accept/'),
                body: {
                  'exchange_date': widget.exchangeRequest,
                  'exchange_for': widget.userPrn,
                  'exchange_by':'0',
                }
              );
              setState(() {
                _isVisible = false; // Set visibility to false to hide the container
              });
            },
            child: Text('Accept'),
          ),
        ),
        SizedBox(width: 8), // Add some space between buttons
        Visibility(
          visible: widget.exchangeRequest != '',
          child: ElevatedButton(
            onPressed: () {
              // Add logic for reject button
              setState(() {
                _isVisible = false; // Set visibility to false to hide the container
              });
            },
            child: Text('Reject'),
          ),
        ),
      ],
    ),
  ),
),


                        ],
                      ),
                    ),
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

String getDayOfWeek(String dateStr) {
  DateTime date = DateTime.parse(dateStr);
  return DateFormat('E').format(date); // 'E' represents the abbreviated day of week (e.g., "Mon", "Tue")
}