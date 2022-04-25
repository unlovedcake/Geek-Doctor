import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:geekdoctor/Widgets/TextFormField.dart';
import 'package:geekdoctor/Widgets/TextFormFieldDateAndTime.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

class EditBookingPage extends StatefulWidget {
  const EditBookingPage({Key? key}) : super(key: key);

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  User? user = FirebaseAuth.instance.currentUser;
  BookModel loggedInUser = BookModel();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _serviceNeedText = TextEditingController(text: " ");

  DateTime _selectedDate = DateTime.now();
  String _endTime = DateFormat("hh:mm a").format(DateTime.now());
  String _startTime = DateFormat("hh:mm a").format(DateTime.now());

  bool isLoading = false;
  bool? _selectedEditTime = false;
  bool? _selectedEditDate = false;

  DateTime? _pickerDate;
  var pickedTime;

  _getDateFromUser() async {
    _selectedEditDate = true;
    _pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2121),
    );

    if (_pickerDate == null) {
      DateTime? d;
      _selectedDate = d!;
    } else {
      setState(() {
        _selectedDate = _pickerDate!;
      });
    }
  }

  _showTimePicker() {
    _selectedEditTime = true;
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0])),
    );
  }

  _getTimeFromUser({required bool isStartTime}) async {
    pickedTime = await _showTimePicker();
    String _formatTime = pickedTime!.format(context);

    // DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
    // //converting to DateTime so that we can further format on different pattern.
    // print(parsedTime); //output 1970-01-01 22:53:00.000
    // String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
    // print(formattedTime); //output 14:59:00

    if (pickedTime == null) {
      // _startTime = loggedInUser.startTime!;
      // _endTime = loggedInUser.endTime!;
      print("Time Canceled");
    } else if (isStartTime) {
      _startTime = _formatTime;
      //context.read<ControllerClientProvider>().setDisplayStartTime(_startTime);

      setState(() {
        _startTime = _formatTime;
      });
    } else if (!isStartTime) {
      _endTime = _formatTime;
      // context.read<ControllerClientProvider>().setDisplayEndTime(_endTime);

      setState(() {
        _endTime = _formatTime;
      });
    }
  }

  getId() {
    FirebaseFirestore.instance
        .collection("table-book")
        .doc(context.watch<BookAGeekProvider>().bookId)
        .get()
        .then((value) {
      return this.loggedInUser = BookModel.fromMap(value.data());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Edit Booking", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: context.watch<BookAGeekProvider>().getBooking(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot bookingData = snapshot.data!.docs[index];
                return Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Text(
                          //   "${bookingData['userServiceModel']['fullName']}",
                          //   style: TextStyle(
                          //       color: Colors.black,
                          //       fontFamily: 'avenir',
                          //       fontSize: 24,
                          //       fontWeight: FontWeight.w700),
                          // ),
                          // SizedBox(
                          //   height: 50,
                          // ),

                          //Service Need Text Field

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Service Need',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _serviceNeedText != " "
                                      ? _serviceNeedText
                                      : _serviceNeedText
                                    ..text = bookingData['serviceNeed'],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return ("Service is required");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          // InputFieldDesign.inputField(
                          //     "Service Need",
                          //     "Service Need",
                          //     _serviceNeedText..text = bookingData['serviceNeed'],
                          //     widget: null, validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return ("Service is required");
                          //   }
                          // }),
                          InputFieldDesign.inputField(
                              "Date",
                              _pickerDate == null
                                  ? bookingData['dateToBook']
                                  : DateFormat.yMMMMd().format(_selectedDate),
                              //DateFormat.yMd().format(_selectedDate),
                              null,
                              widget: null,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today_outlined),
                                color: Colors.grey,
                                onPressed: () {
                                  _getDateFromUser();
                                },
                              ),
                              validator: (value) {}),
                          Row(
                            children: [
                              Expanded(
                                child: InputFieldDesign.inputField(
                                    "Start Time",
                                    //'${context.watch<ControllerClientProvider>().getDisplayStartTime}',
                                    //appState.getDisplayStartTime,
                                    pickedTime == null
                                        ? bookingData['startTime']
                                        : _startTime,
                                    null,
                                    widget: null,
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.access_time_rounded),
                                      color: Colors.grey,
                                      onPressed: () {
                                        _getTimeFromUser(isStartTime: true);
                                      },
                                    ),
                                    validator: (value) {}),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: InputFieldDesign.inputField(
                                    "End Time",
                                    //'${context.watch<ControllerClientProvider>().getDisplayEndTime}',

                                    // appState.getDisplayEndTime,
                                    pickedTime == null
                                        ? bookingData['endTime']
                                        : _endTime,
                                    null,
                                    widget: null,
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.access_time_rounded),
                                      color: Colors.grey,
                                      onPressed: () {
                                        _getTimeFromUser(isStartTime: false);
                                      },
                                    ),
                                    validator: (value) {}),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
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
                          primary: Colors.white, // background
                          // foreground
                        ),
                        onPressed: () async {
                          BookModel bookModel = BookModel();

                          bookModel.serviceNeed = _serviceNeedText.text;
                          bookModel.dateToBook = _pickerDate == null
                              ? bookingData['dateToBook']
                              : DateFormat.yMMMMd().format(_selectedDate);
                          bookModel.startTime =
                              pickedTime == null ? bookingData['startTime'] : _startTime;
                          bookModel.endTime =
                              pickedTime == null ? bookingData['endTime'] : _endTime;

                          if (_formKey.currentState!.validate()) {
                            List listAllBooking = [];
                            bool canBook = true;

                            String? _dateNow = DateFormat.yMMMMd().format(_selectedDate);
                            final res = await FirebaseFirestore.instance
                                .collection("table-book")
                                .get();

                            res.docs.forEach((doc) {
                              listAllBooking.add(doc.data());
                            });

                            String sT = _startTime.split(":")[0]; // Get only the hour
                            String eT = _endTime.split(":")[0];
                            String _startTimeAmPm =
                                _startTime.substring(5); // Get the pm or am value
                            String _endTimeAmPm = _endTime.substring(5);

                            for (int i = 0; i < listAllBooking.length; i++) {
                              String? dateToBook = listAllBooking[i]['dateToBook'];
                              String? startTime = listAllBooking[i]['startTime'];
                              String? endTime = listAllBooking[i]['endTime'];
                              String? userServiceName =
                                  listAllBooking[i]['userServiceModel']['fullName'];

                              String startTimeValueToDatabase = startTime!.split(":")[0];
                              int intStartTimeValueToDatabase =
                                  int.parse(startTimeValueToDatabase);
                              String endTimeValueToDatabase = endTime!.split(":")[0];
                              int intEndTimeValueToDatabase = int.parse(
                                  endTimeValueToDatabase); // Convert String Time to Int from Database Value

                              int startST = int.parse(sT);
                              int endET = int.parse(eT);

                              int limitTotalMaxBookTime = startST + endET;

                              //int hour = int.parse(_startTime.substring(0, 1));

                              String startTimeAmPmDB =
                                  startTime.substring(5); //databse time value
                              String endTimeAmPmDB =
                                  endTime.substring(5); //databse time value

                              DateTime parsedEndTime24 = DateFormat.jm().parse(endTime);
                              String formattedTime =
                                  DateFormat('HH:mm a').format(parsedEndTime24);

                              String endTime24 = formattedTime.split(":")[0];
                              int _endTimeDB24 = int.parse(endTime24);

                              DateTime parsedStartTime24 =
                                  DateFormat.jm().parse(startTime);
                              String formattedTimeStart =
                                  DateFormat('HH:mm a').format(parsedStartTime24);

                              String startTime24 = formattedTimeStart.split(":")[0];
                              int _startTimeDB24 = int.parse(startTime24);

                              DateTime _parsedEndTime24 = DateFormat.jm().parse(_endTime);
                              String _formattedTime =
                                  DateFormat('HH:mm a').format(_parsedEndTime24);

                              String endTime24_ = _formattedTime.split(":")[0];
                              int endSelectedTime24 = int.parse(endTime24_);

                              DateTime _parsedStartTime24 =
                                  DateFormat.jm().parse(_startTime);
                              String _formattedTimeStart =
                                  DateFormat('HH:mm a').format(_parsedStartTime24);

                              String startTime24_ = _formattedTimeStart.split(":")[0];
                              int startSelectedTime24 = int.parse(startTime24_);

                              if (sT == eT) {
                                canBook = false;
                                Fluttertoast.showToast(
                                    msg: " Start time and End Time Invalid. ");
                                break;
                              } else if (bookingData['userServiceModel']['fullName'] !=
                                      userServiceName &&
                                  bookingData['dateToBook'] == _selectedDate &&
                                  startSelectedTime24 >= _startTimeDB24 &&
                                  startSelectedTime24 <= _endTimeDB24) {
                                canBook = false;

                                print("${_dateNow}" +
                                    "${bookingData['dateToBook']}" +
                                    "HEY");
                                print("${bookingData['userServiceModel']['fullName']}" +
                                    "${userServiceName}" +
                                    "HEY");
                                Fluttertoast.showToast(msg: " Invalidsss. ");
                                break;
                              } else if (bookingData['userServiceModel']['fullName'] !=
                                      userServiceName &&
                                  bookingData['dateToBook'] == _selectedDate &&
                                  startSelectedTime24 < _startTimeDB24 &&
                                  endSelectedTime24 > _startTimeDB24) {
                                canBook = false;

                                print("${_dateNow}" + "${dateToBook}" + "HEY");
                                Fluttertoast.showToast(msg: " Invalids. ");
                                break;
                              } else if (bookingData['userServiceModel']['fullName'] !=
                                      userServiceName &&
                                  bookingData['dateToBook'] == _selectedDate &&
                                  startSelectedTime24 >= _startTimeDB24 &&
                                  startSelectedTime24 <= _endTimeDB24) {
                                canBook = false;

                                print(
                                    "${_selectedDate}" + "ok" + "${dateToBook}" + "HEYs");
                                Fluttertoast.showToast(msg: " Invalidd ");
                                break;
                              }
                            }

                            if (pickedTime != null && sT == eT) {
                              canBook = false;
                              Fluttertoast.showToast(
                                  msg: " Start time and End Time Invalid. ");
                              print("${sT}" + "${eT}" + "HEY");
                            }

                            if (canBook) {
                              context
                                  .read<BookAGeekProvider>()
                                  .bookingUpdate(bookModel, bookingData.id);
                            }

                            //Navigator.pushNamed(context, '/client-home-page');
                          }
                        },
                        child: Text('Edit'),
                      ),
                    )
                  ],
                );
              },
            );
          }

          return Text("");
        },
      ),
    );
  }
}
