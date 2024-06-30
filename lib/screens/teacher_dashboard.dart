import 'dart:convert';
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
          userType: '',userDept: '',userName: '',userPrn: '',userNotify: [], userAlloc: [],exchangeRequest:[] 
        );
      },
    ),
  ));
}
Future<void> markAttendance(String prn, int status, int examId) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/attendance/'),
      body: {'prn': prn, 'status': status.toString(), 'exam_id': examId.toString()},
    );

    if (response.statusCode == 200) {
    } else {
      // Optionally, you can throw an exception or handle the error further
      // throw Exception('Failed to mark attendance'); // Uncomment to throw an exception
    }
  } catch (e) {
    // Handle exception if HTTP request fails
    // For example, you can show a snackbar or toast with an error message
  }
}

class TeacherDashboard extends StatefulWidget {
  final String userType;
  final String userDept;
  final String userName;
  final String userPrn;
  final List<String> userNotify;
  final  List<Map<String, dynamic>> userAlloc;

  final  List<dynamic>exchangeRequest;
  

  const TeacherDashboard({
    Key? key,
    required this.userType,
    required this.userDept,
    required this.userName,
    required this.userPrn,
    required this.userNotify,
    required this.userAlloc,
 
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
   List<bool> attendanceStatus = [];
  List<String> teacherNames = [];
   bool _isVisible = true;
  @override
  void initState() {
    super.initState();
    countFridays();
    _loadingFuture = Future.delayed(const Duration(seconds: 0));
  }
  Future<void> fetchInitialAttendanceStatus(selectedDateIndex) async {
    int studentCount = widget.userAlloc[selectedDateIndex]['student_prns'].length;
    List<bool> initialStatus = List<bool>.filled(studentCount, false);
    List prn = widget.userAlloc[selectedDateIndex]['student_prns'];
    
      final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/attendance/status/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prn': prn,'exam_id':widget.userAlloc[selectedDateIndex]['exam_id']}),
  );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<int> statusList = List<int>.from(data['status']);
        setState(() {
      for (int i = 0; i < studentCount; i++) {
        initialStatus[i] = statusList[i] == 1; // Update the initialStatus list based on the statusList
      }
      attendanceStatus = initialStatus;
    });
      } else {
        // Handle error response if needed
      }
    
  }
Future<void> grabTeacherNames(selectedDateIndex) async {
  
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/grab_teacher_names/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': widget.userPrn,
      'exam_id': widget.userAlloc[selectedDateIndex]['exam_id'],
      'exam_date': widget.userAlloc[selectedDateIndex]['date'],
    }),
  );

  if (response.statusCode == 200) {
    setState(() {
        teacherNames = List<String>.from(jsonDecode(response.body)['teacher_names']);
      });
  } else {
  }
}


  void initializeCardVisibility(selectedDateIndex) {
    cardVisibility = List.generate(
      widget.userAlloc[selectedDateIndex]['student_prns'].length,
      (index) => true,
    );
  }
void countFridays() {
    for (int i = 0; i < widget.userAlloc.length; i++) {
      String date = widget.userAlloc[i]['day']; 
      if (date == 'Friday') {
        fridayCounter++; 
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor:const Color(0xFFF2F2F2),
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
          DateTime thirteenThirty = DateTime(today.year, today.month, today.day, 13, 30);
          DateTime? upcomingDate; 
          for (var allocation in widget.userAlloc) {
            
            DateTime allocDate = DateTime.parse(allocation['date']);
            if (allocDate.isAfter(thirteenThirty) &&
                (upcomingDate == null || allocDate.isBefore(upcomingDate))) {
              upcomingDate = allocDate;
            }
          }
          DateTime? displayDate = upcomingDate;
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
                        padding: const EdgeInsets.all(20),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Department',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Raleway',
                                    ),
                                  ),
                                  Text(
                                    widget.userDept,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Raleway',
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
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
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
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                       const Padding(
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
                                // 'upcoming invigilation duty date : ${DateFormat('dd-MM-yyyy').format(displayDate).toString().split(' ')[0]}', 
                                 'Next Duty: ${displayDate==null?'None':displayDate.toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontSize: 12,fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),
                      
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          for (var i = 0; i < widget.userAlloc.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust the horizontal spacing as needed
                              child: dateButton(
                                widget.userAlloc[i]['date'].split('-').last, // Display only the day part
                                widget.userAlloc[i]['day'].substring(0, 3), // Function to get day of week
                                true, // Assuming this value should always be true
                                () {
                                  setState(() {
                                    showInvigilationInfo = true;
                                    selectedDateIndex = i;
                                    fetchInitialAttendanceStatus(selectedDateIndex);
                                    initializeCardVisibility(selectedDateIndex);
                                    grabTeacherNames(selectedDateIndex);
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                  
                      const SizedBox(height: 30),

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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color:const Color.fromARGB(230, 111, 194, 239),borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
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
                                      title: const Text("Change this Duty"),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Text("Your exchange duty message goes here."),

                                              const SizedBox(height: 20), // Add spacing between message and dropdown

                                              DropdownButtonFormField<String>(
                                                value: selectedName,
                                                items:teacherNames.map((String value) {
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
                                                decoration: const InputDecoration(
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
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (selectedName != null) {
                                              // Make HTTP POST request
                                              http.post(
                                                Uri.parse('http://127.0.0.1:8000/dutychange/'),
                                                body: {
                                                  'exchange_for':  widget.userPrn,
                                                  'exchange_by': selectedName,
                                                  'exam_id':widget.userAlloc[selectedDateIndex]['exam_id'].toString(),
                                                  // 'request_date':widget.userAlloc[selectedDateIndex]['date'],
                                                }
                                              );
                                            }
                                            Navigator.of(context).pop();
                                            if (!mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Success'),
                                                content: const Text('Exchange request has been sent.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                              
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Room Name',
                                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userAlloc[selectedDateIndex]['room_name'] ?? '' , 
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Slot',
                                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userAlloc[selectedDateIndex]['slot'] ?? '' , 
                                      style: const TextStyle(fontSize: 18),
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

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(prn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                                        Switch(
                                          value: attendanceStatus.isNotEmpty && index < attendanceStatus.length ? attendanceStatus[index] : false,
                                          onChanged: (bool value) {
                                            markAttendance(prn, value ? 1 : 0,widget.userAlloc[selectedDateIndex]['exam_id']);
                                            setState(() {
                                              attendanceStatus[index] = value;
                                            });
                                          },
                                          activeColor: const Color(0xFF74D4A6), // Color when switch is on (Present)
                                          inactiveThumbColor: const Color(0xFFE46D6D), // Color when switch is off (Absent), // Color when switch is off (Absent)
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                            ],
                          ),
                        ),

                      ] else ...[
                        if(widget.userNotify.isNotEmpty)
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
                                  color: const Color(0xFFF2F2F2),borderRadius: BorderRadius.circular(8),
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
                                  color: const Color(0xFFF2F2F2),
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
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    roomName,
                                    style: const TextStyle(fontSize: 16),
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

                    
                    if ( widget.exchangeRequest.isNotEmpty)
                    
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
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          child: Column(
                            children: List.generate(widget.exchangeRequest.length, (index) {
                              var exchangeItem = widget.exchangeRequest[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Exchange request from ${exchangeItem[5]} on ${exchangeItem[3]} and at ${exchangeItem[4]}',
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(width: 8), // Add some space between text and buttons
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final response = await http.post(
                                            Uri.parse('http://127.0.0.1:8000/exchange_accept/'),
                                            body: {
                                              'user_prn': widget.userPrn,
                                              'exchange_for': exchangeItem[1],
                                              'exam_id': exchangeItem[0].toString(), // Ensure exam_id is converted to String if it's not already
                                              'friday_duty': exchangeItem[2],
                                            },
                                          );

                                          if (response.statusCode == 200) {
                                            // Handle successful response
                                           
                                             setState(() {
                                            _isVisible = false; // Set visibility to false to hide the container
                                          });
                                          if (!mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Success'),
                                                content: const Text('Exchange request accepted successfully.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          } else {
                                            // Handle HTTP error response
                                            
                                            // Optionally, show a snackbar or toast with error message
                                          }
                                        } catch (e) {
                                          // Handle network or server errors
                                         
                                          // Optionally, show a snackbar or toast with error message
                                        }
                                      },
                                      child: const Text('Accept'),
                                    ),
                                    const SizedBox(width: 8), // Add some space between buttons
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final response = await http.post(
                                            Uri.parse('http://127.0.0.1:8000/exchange_reject/'),
                                            body: {
                                              'user_prn': widget.userPrn,
                                              'exchange_for': exchangeItem[1],
                                              'exam_id': exchangeItem[0].toString(), // Ensure exam_id is converted to String if it's not already
                                              'friday_duty': exchangeItem[2],
                                            },
                                          );

                                          if (response.statusCode == 200) {
                                            setState(() {
                                              _isVisible = false; // Set visibility to false to hide the container
                                            });
                                            if (!mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Rejected'),
                                                content: const Text('Exchange request rejected.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          } else {
                                           
                                          }
                                        } catch (e) {
                                          // Handle network or server errors
                                          // Optionally, show a snackbar or toast with error message
                                        }
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      )



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
  return Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10,0),child: Container(
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
    minimumSize: const Size(100,105),
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
          color: Colors.black,fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        day,
        style: const TextStyle(
          color: Colors.black,fontSize: 14,
        ),
      ),
    ],
  ),
),
      ],
    ),
  )
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
                  title: const Text('Alert'),
                  content: Text(
                    message,
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

// String getDayOfWeek(String dateStr) {
//   DateTime date = DateTime.parse(dateStr);
//   return DateFormat('E').format(date); // 'E' represents the abbreviated day of week (e.g., "Mon", "Tue")
// }