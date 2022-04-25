import 'dart:async';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:geekdoctor/Animation/page-animation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/Chat-Page/Chat-To-User-Service.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:provider/src/provider.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({Key? key}) : super(key: key);

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  User? user = FirebaseAuth.instance.currentUser;

  BookModel loggedInUser = BookModel();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  List listUsers = [];
  Future<void> dis() async {
    await FirebaseFirestore.instance
        .collection("table-book")
        .where('userModel.uid', isEqualTo: user!.uid)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        listUsers.add(result.data());
        loggedInUser = BookModel.fromMap(result.data());

        print(loggedInUser.userModel!['email']);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    dis();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ControllerClientProvider>().setSelectedBottomNav(0);

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange),
          centerTitle: true,
          title: Text("Booking List", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBar: BottomNavBar(index: 2),
        body: StreamBuilder(
            stream: context.watch<BookAGeekProvider>().bookingList(),
            builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: const CircularProgressIndicator(color: Colors.orange));
              }
              if (snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            final userService = snapshot.data!.docs[index];

                            final DocumentSnapshot bookingData =
                                snapshot.data!.docs[index];

                            return InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    elevation: 20,
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.orange,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () async {
                                                    _displayDialogCancel(
                                                        bookingData.id,
                                                        userService.get('status'),
                                                        context,
                                                        BookModel.fromMap(
                                                            userService.data()));
                                                  },
                                                  child: Text(
                                                    userService.get('status') ==
                                                            "Completed"
                                                        ? "Finish Transaction"
                                                        : "Cancel Transaction",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.blue,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();

                                                    Navigator.push(
                                                        context,
                                                        BouncyPageRoute(
                                                            widget: ChatToUserService(
                                                                serviceInfo:
                                                                    BookModel.fromMap(
                                                                        userService
                                                                            .data()))));

                                                    context
                                                        .read<ChatControllerProvider>()
                                                        .setUserServiceID(
                                                            userService.get('id'));
                                                  },
                                                  child: Text(
                                                    "Send Message",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.green,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    Navigator.pushNamed(
                                                        context, '/edit-booking-page');
                                                    context
                                                        .read<BookAGeekProvider>()
                                                        .setBookingID(
                                                            userService.get('id'));
                                                  },
                                                  child: Text(
                                                    "Edit Booking",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.orangeAccent, Colors.black26],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.all(Radius.circular(24)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              ClipOval(
                                                child: CachedNetworkImage(
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  imageUrl: userService
                                                      .get('userServiceModel.imageUrl'),
                                                  progressIndicatorBuilder:
                                                      (context, url, downloadProgress) =>
                                                          CircularProgressIndicator(
                                                    value: downloadProgress.progress,
                                                    color: Colors.orange,
                                                  ),
                                                  errorWidget: (context, url, error) =>
                                                      Icon(
                                                    Icons.error,
                                                    size: 100,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      FittedBox(
                                                        child: Container(
                                                          width: 250,
                                                          child: Text(
                                                            "${userService.get('userServiceModel.fullName')} ",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: 'avenir',
                                                              fontSize: 16.0,
                                                            ),
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      FittedBox(
                                                        child: Container(
                                                          width: 250,
                                                          child: Text(
                                                            "${userService.get('userServiceModel.email')} ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.orangeAccent,
                                                                fontFamily: 'avenir'),
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: RichText(
                                          text: TextSpan(
                                              text: "Status: ",
                                              style: TextStyle(
                                                  fontSize: 16.0, color: Colors.black),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: "${userService.get('status')}",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: userService.get('status') ==
                                                              "Pending"
                                                          ? Colors.red
                                                          : Colors.green),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "${userService.get('dateToBook')}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir',
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            "${userService.get('startTime')} - ${userService.get('endTime')}",
                                            style: TextStyle(
                                                color: Colors.orangeAccent,
                                                fontFamily: 'avenir'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
              }
              return Center(child: Text("No Booking List Yet"));
            }),
      ),
    );
  }

  _displayDialogCancel(
      String bookID, String status, BuildContext context, BookModel bookModel) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(status == "Completed"
                ? "Transaction finish?"
                : 'You want to cancel transaction?'),
            actions: <Widget>[
              OutlinedButton(
                child: new Text('Yes'),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("table-book")
                      .doc(bookID)
                      .delete()
                      .then((e) {
                    FirebaseFirestore.instance.collection("table-history").add({
                      "clientName": loggedInUser.userModel!['fullName'],
                      "clientEmail": loggedInUser.userModel!['email'],
                      "clientImage": loggedInUser.userModel!['imageUrl'],
                      "userServiceName": bookModel.userServiceModel!['fullName'],
                      "userServiceEmail": bookModel.userServiceModel!['email'],
                      "serviceImage": bookModel.userServiceModel!['imageUrl'],
                      "status": status == "Completed"
                          ? "Transaction Completed"
                          : "Transaction Cancelled",
                      "dateFinished": DateFormat.yMMMMd().format(DateTime.now()),
                    }).then((_) {});
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: status == "Completed"
                            ? "Transaction Completed"
                            : "Transaction Cancelled ");
                  }).catchError((err) {
                    Fluttertoast.showToast(msg: "Transaction Error");
                    print(err.message);
                  });
                },
              ),
              new OutlinedButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
