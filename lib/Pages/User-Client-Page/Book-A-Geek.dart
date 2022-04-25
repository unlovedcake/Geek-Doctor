import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/clean_calendar_event.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/User-Client-Page/View-Profile-User-Service.dart';
import 'package:geekdoctor/Pages/User-Service-Page/View-Profile-User-Client.dart';
import 'package:geekdoctor/Provider/AppProvider.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/TextFormFieldDateAndTime.dart';
import 'package:geekdoctor/constant.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';

class BookAGeekPage extends StatefulWidget {
  const BookAGeekPage({Key? key}) : super(key: key);

  @override
  _BookAGeekPageState createState() => _BookAGeekPageState();
}

class _BookAGeekPageState extends State<BookAGeekPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _serviceNeedText = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _endTime = DateFormat("hh:mm a").format(DateTime.now());
  String _startTime = DateFormat("hh:mm a").format(DateTime.now());

  String bookingDate = "";

  bool isEventEmpty = false;

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0])),
    );
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatTime = pickedTime!.format(context);

    if (pickedTime == null) {
      print("Time Canceled");
    } else if (isStartTime) {
      _startTime = _formatTime;

      setState(() {
        _startTime = _formatTime;
      });
    } else if (!isStartTime) {
      _endTime = _formatTime;

      setState(() {
        _endTime = _formatTime;
      });
    }
  }

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
  }

  final DateFormat formatTime = new DateFormat("hh:mm a");
  final DateFormat formatDate = new DateFormat("MMMM dd, y");
  List dataAll = [];

  Future dis() async {
    await FirebaseFirestore.instance
        .collection("table-book")
        .where("userServiceModel.email",
            isEqualTo: Provider.of<ControllerClientProvider>(context, listen: false)
                .getServiceEmail)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        dataAll.add(result.data());
      });
    });
    getAllData();
  }

  @override
  void initState() {
    super.initState();
    AppProviders.disposeAllDisposableProviders(context);
    dis();
  }

  getAllData() {
    for (int i = 0; i < dataAll.length; i++) {
      events.addAll({
        formatDate.parse((dataAll[i]['dateToBook'])): [
          CleanCalendarEvent(dataAll[i]['userModel']['clientAddress'],
              startTime: formatTime.parse(dataAll[i]['startTime']),
              endTime: formatTime.parse(dataAll[i]['endTime']),
              description: dataAll[i]['serviceNeed'],
              color: Colors.orange),
        ]
      });
    }
    print(events.length);
  }

  Future<Response> sendNotification(
      List<String> tokenIdList, String contents, String heading) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id":
            keyAppID, //kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids":
            tokenIdList, //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color": "FFA500",

        //"small_icon": "ic_stat_onesignal_default",

        "large_icon": loggedInUser.imageUrl,
        // "https://firebasestorage.googleapis.com/v0/b/geek-doctor-2dd82.appspot.com/o/scaled_image_picker6842236089939337044.png?alt=media&token=d8a07855-98e8-4a26-ac78-876fa2c2e278",

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("table-user-client")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());

      print(loggedInUser.fullName);
    });

    return Scaffold(
      body: StreamBuilder(
        stream: context.watch<ControllerClientProvider>().getUserServiceEmail(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          final currentUser = snapshot.data?.docs;
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.orange),
                centerTitle: true,
                title: Text("Book A Geek", style: TextStyle(color: Colors.orange)),
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ActionChip(
                        backgroundColor: Colors.orange,
                        shadowColor: Colors.black,
                        label: Text(
                          " View Profile ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          context.read<ControllerClientProvider>().setUserServiceEmail(
                                currentUser![0]['email'],
                              );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ViewProfileUSerService(),
                              ));
                        }),
                  ),
                  // OutlinedButton(
                  //   style: OutlinedButton.styleFrom(
                  //     primary: Colors.orange, // background
                  //   ),
                  //   onPressed: () {
                  //     context.read<ControllerClientProvider>().setUserServiceEmail(
                  //           currentUser![0]['email'],
                  //         );
                  //
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (BuildContext context) => ViewProfileUSerService(),
                  //         ));
                  //   },
                  //   child: Text(
                  //     'View Profile',
                  //     style: TextStyle(color: Colors.orange),
                  //   ),
                  // )
                ],
              ),
              body: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 400,
                    child: Calendar(
                      //todayButtonText: "Today",
                      startOnMonday: true,
                      selectedColor: Colors.blue,
                      todayColor: Colors.red,
                      eventColor: Colors.green,
                      eventDoneColor: Colors.amber,
                      bottomBarColor: Colors.deepOrange,

                      onDateSelected: (date) {
                        print(DateFormat.yMMMMd().format(date));

                        bookingDate = DateFormat.yMMMMd().format(date);
                        print(selectedEvent.isEmpty);
                        if (events[date] == null) {
                          isEventEmpty = true;
                          print("OKE");
                        } else {
                          isEventEmpty = false;
                        }
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
                      hideBottomBar: true,
                      hideArrows: false,
                      weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    ),
                  ),
                  isEventEmpty
                      ? SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputFieldDesign.inputField(
                                    bookingDate, "Service Need", _serviceNeedText,
                                    widget: null, validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Service is required");
                                  }
                                }),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InputFieldDesign.inputField(
                                          "Start Time",
                                          //'${context.watch<ControllerClientProvider>().getDisplayStartTime}',
                                          //appState.getDisplayStartTime,
                                          _startTime,
                                          null,
                                          widget: null,
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.access_time_rounded),
                                            color: Colors.grey,
                                            onPressed: () {
                                              _getTimeFromUser(isStartTime: true);
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                          validator: (value) {}),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: InputFieldDesign.inputField(
                                          "End Time", _endTime, null,
                                          widget: null,
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.access_time_rounded),
                                            color: Colors.grey,
                                            onPressed: () {
                                              _getTimeFromUser(isStartTime: false);
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                          validator: (value) {}),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  margin: EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade500,
                                          offset: Offset(5, 5),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                        BoxShadow(
                                          color: Colors.grey[300]!,
                                          offset: Offset(-2, -2),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white, // foreground
                                    ),
                                    onPressed: () async {
                                      BookModel bookModel = BookModel();
                                      bookModel.serviceNeed = _serviceNeedText.text;
                                      bookModel.dateToBook = bookingDate;
                                      bookModel.startTime = _startTime;
                                      bookModel.endTime = _endTime;
                                      bookModel.status = "Pending";
                                      bookModel.userModel = {
                                        "uid": loggedInUser.uid,
                                        "tokenId": loggedInUser.tokenId,
                                        "fullName": loggedInUser.fullName,
                                        "contactNumber": loggedInUser.contactNumber,
                                        "email": loggedInUser.email,
                                        "clientAddress": loggedInUser.address,
                                        "imageUrl": loggedInUser.imageUrl
                                      };
                                      bookModel.userServiceModel = {
                                        "uid": currentUser![0]['uid'],
                                        "fullName": currentUser[0]['fullName'],
                                        "email": currentUser[0]['email'],
                                        "imageUrl": currentUser[0]['imageUrl'],
                                      };

                                      if (_formKey.currentState!.validate()) {
                                        List listAllBooking = [];
                                        bool canBook = true;

                                        String? _dateNow = Provider.of<BookAGeekProvider>(
                                                context,
                                                listen: false)
                                            .getSelectedDate;

                                        final res = await FirebaseFirestore.instance
                                            .collection("table-book")
                                            .get();

                                        res.docs.forEach((doc) {
                                          listAllBooking.add(doc.data());
                                        });

                                        String sT = _startTime.split(":")[0];
                                        String eT = _endTime.split(":")[0];
                                        String _startTimeAmPm =
                                            _startTime.substring(5); // current time value
                                        String _endTimeAmPm =
                                            _endTime.substring(5); // current time value

                                        for (int i = 0; i < listAllBooking.length; i++) {
                                          String? dateToBook =
                                              listAllBooking[i]['dateToBook'];
                                          String? startTime =
                                              listAllBooking[i]['startTime'];
                                          String? endTime = listAllBooking[i]['endTime'];
                                          String? userServiceName = listAllBooking[i]
                                              ['userServiceModel']['fullName'];

                                          String startTimeValueToDatabase =
                                              startTime!.split(":")[0];
                                          int intStartTimeValueToDatabase =
                                              int.parse(startTimeValueToDatabase);
                                          String endTimeValueToDatabase =
                                              endTime!.split(":")[0];
                                          int intEndTimeValueToDatabase =
                                              int.parse(endTimeValueToDatabase);

                                          int startST = int.parse(sT);
                                          int endET = int.parse(eT);

                                          int limitTotalMaxBookTime = startST + endET;

                                          String startTimeAmPmDB =
                                              startTime.substring(5); //databse time value
                                          String endTimeAmPmDB =
                                              endTime.substring(5); //databse time value

                                          DateTime parsedEndTime24 =
                                              DateFormat.jm().parse(endTime);
                                          String formattedTime = DateFormat('HH:mm a')
                                              .format(parsedEndTime24);

                                          String endTime24 = formattedTime.split(":")[0];
                                          int _endTimeDB24 = int.parse(endTime24);

                                          DateTime parsedStartTime24 =
                                              DateFormat.jm().parse(startTime);
                                          String formattedTimeStart =
                                              DateFormat('HH:mm a')
                                                  .format(parsedStartTime24);

                                          String startTime24 =
                                              formattedTimeStart.split(":")[0];
                                          int _startTimeDB24 = int.parse(startTime24);

                                          DateTime _parsedEndTime24 =
                                              DateFormat.jm().parse(_endTime);
                                          String _formattedTime = DateFormat('HH:mm a')
                                              .format(_parsedEndTime24);

                                          String endTime24_ =
                                              _formattedTime.split(":")[0];
                                          int endSelectedTime24 = int.parse(endTime24_);

                                          DateTime _parsedStartTime24 =
                                              DateFormat.jm().parse(_startTime);
                                          String _formattedTimeStart =
                                              DateFormat('HH:mm a')
                                                  .format(_parsedStartTime24);

                                          String startTime24_ =
                                              _formattedTimeStart.split(":")[0];
                                          int startSelectedTime24 =
                                              int.parse(startTime24_);

                                          if (sT == eT) {
                                            canBook = false;
                                            Fluttertoast.showToast(
                                                msg:
                                                    " Start time and End Time Invalid. ");
                                            break;
                                          } else if (currentUser[0]['fullName'] ==
                                                  userServiceName &&
                                              dateToBook == _dateNow &&
                                              startSelectedTime24 >= _startTimeDB24 &&
                                              startSelectedTime24 <= _endTimeDB24) {
                                            canBook = false;

                                            Fluttertoast.showToast(
                                                toastLength: Toast.LENGTH_LONG,
                                                msg: "${currentUser[0]['fullName']}" +
                                                    " "
                                                        "is taken from" +
                                                    " "
                                                        "${startTime}" +
                                                    " "
                                                        "to" +
                                                    " " "${endTime}");
                                            break;
                                          } else if (currentUser[0]['fullName'] ==
                                                  userServiceName &&
                                              dateToBook == _dateNow &&
                                              startSelectedTime24 <= _startTimeDB24 &&
                                              endSelectedTime24 >= _startTimeDB24) {
                                            canBook = false;

                                            print(
                                                "${_dateNow}" + "${dateToBook}" + "HEY");
                                            Fluttertoast.showToast(
                                                toastLength: Toast.LENGTH_LONG,
                                                msg: "${currentUser[0]['fullName']}" +
                                                    " "
                                                        "is taken from" +
                                                    " "
                                                        "${startTime}" +
                                                    " "
                                                        "to" +
                                                    " " "${endTime}");
                                            break;
                                          } else if (currentUser[0]['fullName'] ==
                                                  userServiceName &&
                                              dateToBook == _dateNow &&
                                              startSelectedTime24 <= _startTimeDB24 &&
                                              endSelectedTime24 >= _endTimeDB24) {
                                            canBook = false;

                                            Fluttertoast.showToast(
                                                toastLength: Toast.LENGTH_LONG,
                                                msg: "${currentUser[0]['fullName']}" +
                                                    " "
                                                        "is taken from" +
                                                    " "
                                                        "${startTime}" +
                                                    " "
                                                        "to" +
                                                    " " "${endTime}");
                                            break;
                                          } else if (currentUser[0]['fullName'] ==
                                                  userServiceName &&
                                              dateToBook == _dateNow &&
                                              startSelectedTime24 >= endSelectedTime24) {
                                            canBook = false;

                                            Fluttertoast.showToast(
                                                toastLength: Toast.LENGTH_LONG,
                                                msg: "${currentUser[0]['fullName']}" +
                                                    " "
                                                        "is taken from" +
                                                    " "
                                                        "${startTime}" +
                                                    " "
                                                        "to" +
                                                    " " "${endTime}");
                                            break;
                                          }
                                        }

                                        if (listAllBooking.length == 0 &&
                                            sT == eT &&
                                            _startTimeAmPm == _endTimeAmPm) {
                                          canBook = false;
                                          Fluttertoast.showToast(
                                              msg: " Start time and End Time Invalid. ");
                                        }

                                        if (canBook) {
                                          context
                                              .read<BookAGeekProvider>()
                                              .bookingAdd(bookModel, context);
                                          sendNotification(
                                              ["${currentUser[0]['tokenId']}"],
                                              "${loggedInUser.fullName}" +
                                                  "  is Booking To You.",
                                              "Book A Geek");
                                        }
                                      }
                                    },
                                    child:
                                        context.watch<BookAGeekProvider>().loading == true
                                            ? Container(
                                                height: 15,
                                                width: 15,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 1,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                'Book Now',
                                                style: GoogleFonts.acme(
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 10,
                        ),
                ],
              )),
            );
          }

          return Text("");
        },
      ),
    );
  }
}
