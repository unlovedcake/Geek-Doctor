import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class FlutterCalendar extends StatefulWidget {
  const FlutterCalendar({Key? key}) : super(key: key);

  @override
  _FlutterCalendarState createState() => _FlutterCalendarState();
}

class _FlutterCalendarState extends State<FlutterCalendar> {
  int currentDateSelectedIndex = 0; //For Horizontal Date
  ScrollController scrollController = ScrollController(); //To Track Scroll of ListView

  var _inputFormat = DateFormat('MMM');
  var _selectedDate = DateTime.now();

  String? dateSelected;

  DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now(); // TO tracking date
  List<String> listOfMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  List<String> listDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Text("Date",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey)),
              ),
              Container(
                  height: 30,
                  margin: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Provider.of<BookAGeekProvider>(context, listen: false)
                        .getSelectedDate,
                    // listOfMonths[selectedDate.month - 1] +
                    //     ' ' +
                    //     selectedDate.day.toString() +
                    //     ', ' +
                    //     selectedDate.year.toString(),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.indigo[700]),
                  )),
            ],
          ),
          //SizedBox(height: 10),
          Container(
              margin: EdgeInsets.all(6),
              height: 60,
              child: Container(
                  child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 10);
                },
                itemCount: 365,
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        currentDateSelectedIndex = index;
                        selectedDate = DateTime.now().add(Duration(days: index));
                      });
                      dateSelected = listOfMonths[selectedDate.month - 1] +
                          ' ' +
                          selectedDate.day.toString() +
                          ', ' +
                          selectedDate.year.toString();

                      context.read<BookAGeekProvider>().setSelectedDate(dateSelected!);

                      // selectedDate = listOfMonths[selectedDate.month - 1].toString();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey, offset: Offset(3, 3), blurRadius: 5)
                          ],
                          color: currentDateSelectedIndex == index
                              ? Colors.orange
                              : Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listOfMonths[
                                    DateTime.now().add(Duration(days: index)).month - 1]
                                .toString(),
                            style: TextStyle(
                                fontSize: 12,
                                color: currentDateSelectedIndex == index
                                    ? Colors.white
                                    : Colors.grey),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            DateTime.now().add(Duration(days: index)).day.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: currentDateSelectedIndex == index
                                    ? Colors.white
                                    : Colors.grey),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            listDays[
                                    DateTime.now().add(Duration(days: index)).weekday - 1]
                                .toString(),
                            style: TextStyle(
                                fontSize: 12,
                                color: currentDateSelectedIndex == index
                                    ? Colors.white
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ))),
        ],
      ),
    );
  }
}
