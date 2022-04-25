import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:provider/src/provider.dart';

class CalendarBooking extends StatefulWidget {
  @override
  _CalendarBookingState createState() => _CalendarBookingState();
}

class _CalendarBookingState extends State<CalendarBooking> {
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

  DateTime? selectedDay;
  List<CleanCalendarEvent> selectedEvent = [];

  Map<DateTime, List<CleanCalendarEvent>> events = Map();

  void _handleData(date) {
    setState(() {
      selectedDay = date;
      selectedEvent = events[date] ?? [];
    });
    print(selectedDay);
  }

  final DateFormat formatTime = new DateFormat("hh:mm a");
  final DateFormat formatDate = new DateFormat("MMMM dd, y");
  List dataAll = [];

  Future dis() async {
    await FirebaseFirestore.instance
        .collection("table-book")
        //.where("userServiceModel.email", isEqualTo: "s@gmail.com")
        .where("userServiceModel.email",
            isEqualTo: Provider.of<ControllerClientProvider>(context, listen: false)
                .getServiceEmail)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        dataAll.add(result.data());
        //print(dataAll.length);
      });
    });
    getAllData();
  }

  @override
  void initState() {
    //
    // FirebaseFirestore.instance.collection("table-book").get().then((value) {
    //   value.docs.forEach((result) {
    //     var res = result.data()['dateToBook'];
    //
    //   });
    // });

    super.initState();
    dis();
  }

  getAllData() {
    for (int i = 0; i < dataAll.length; i++) {
      events.addAll({
        formatDate.parse((dataAll[i]['dateToBook'])): [
          CleanCalendarEvent(dataAll[i]['userServiceModel']['fullName'],
              startTime: formatTime.parse(dataAll[i]['startTime']),
              endTime: formatTime.parse(dataAll[i]['endTime']),
              description: dataAll[i]['serviceNeed'],
              color: Colors.orange),
        ]
      });
    }
    print(events.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: Calendar(
              //todayButtonText: "Today",
              startOnMonday: true,
              selectedColor: Colors.blue,
              todayColor: Colors.red,
              eventColor: Colors.green,
              eventDoneColor: Colors.amber,
              bottomBarColor: Colors.deepOrange,
              // onRangeSelected: (range) {
              //   print('selected Day ${range.from},${range.to}');
              // },
              onDateSelected: (date) {
                print(DateFormat.yMMMMd().format(date));
                return _handleData(date);
              },
              events: events,
              isExpanded: true,
              dayOfWeekStyle: TextStyle(
                fontSize: 15,
                overflow: TextOverflow.ellipsis,
                color: Colors.orange,
                fontWeight: FontWeight.w400,
              ),
              bottomBarTextStyle: TextStyle(
                color: Colors.orange,
              ),
              hideBottomBar: false,
              hideArrows: false,
              weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
          ),
        ),

        // Expanded(
        //   child: ListView.builder(
        //     //itemCount: events.length,
        //     itemCount: selectedEvent.length,
        //     padding: EdgeInsets.all(0.0),
        //     itemBuilder: (BuildContext context, int index) {
        //       if (selectedEvent.length == 0) {
        //         return Text("");
        //       } else {
        //         final List<CleanCalendarEvent>? event = selectedEvent;
        //         final String start =
        //             DateFormat('h:mm a').format(event![index].startTime).toString();
        //         final String end =
        //             DateFormat('h:mm a').format(event[index].endTime).toString();
        //
        //         return ListTile(
        //           contentPadding:
        //               EdgeInsets.only(left: 2.0, right: 8.0, top: 2.0, bottom: 2.0),
        //           leading: Container(
        //             width: 10.0,
        //             color: event[index].color,
        //           ),
        //           title: Text(event[index].summary),
        //           subtitle: event[index].description.isNotEmpty
        //               ? Text(event[index].description)
        //               : null,
        //           trailing: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [Text(start), Text(end)],
        //           ),
        //           onTap: () {},
        //         );
        //       }
        //     },
        //   ),
        // ),
      ],
    );
  }
}
