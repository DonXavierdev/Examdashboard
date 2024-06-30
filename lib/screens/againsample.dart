import 'package:flutter/material.dart';


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
        body:BoxGrid(
          columns: 3*2,
          rows: 5,
          studentRow:4,
          studentCol: 1,
          studentSeat: 1,
        ),
      ),
    );
  }
}

class BoxGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final int studentRow;
  final int studentCol;
  final int studentSeat;

  const BoxGrid({super.key, required this.rows, required this.columns ,required this.studentRow ,required this.studentCol,required this.studentSeat});

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
              Expanded(child: Box(rowIndex: rowIndex, columnIndex: columnIndex,studentRow:studentRow,studentCol:studentCol,studentSeat:studentSeat)),
              Expanded(child: Box(rowIndex: rowIndex, columnIndex: columnIndex + 1,studentRow:studentRow,studentCol:studentCol,studentSeat:studentSeat)),
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
  final int studentSeat;

  const Box({super.key, required this.rowIndex, required this.columnIndex,required this.studentRow,required this.studentCol,required this.studentSeat});

  @override
  Widget build(BuildContext context) {
    bool isGreen = rowIndex == studentRow && columnIndex  == (studentCol*2)+studentSeat; 
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        color: isGreen ? const Color(0xFFA0E4C3) : Colors.white, 
      ),
      height: 20, 
    );
  }
}