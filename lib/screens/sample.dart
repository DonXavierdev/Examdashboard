import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Table',
      home: CGPATable(),
    );
  }
}

class CGPATable extends StatefulWidget {
  @override
  _CGPATableState createState() => _CGPATableState();
}

class _CGPATableState extends State<CGPATable> {
  List<List<String>> sampleData = [];

  void _addData(String course, String grade, String scpa) {
    setState(() {
      sampleData.add([course, grade, scpa]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CGPA Table'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                            padding: EdgeInsets.symmetric(vertical: 0),
                            child: Text(datas[0] ?? ''), // Handle potential null value
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(datas[1] ?? ''), // Handle potential null value
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(datas[2] ?? ''), // Handle potential null value
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddDataDialog(context);
                },
                child: Text('Add Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDataDialog(BuildContext context) async {
    String course = '';
    String grade = '';
    String scpa = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Course'),
                onChanged: (value) {
                  course = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Grade'),
                onChanged: (value) {
                  grade = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'SCPA'),
                onChanged: (value) {
                  scpa = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addData(course, grade, scpa);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
