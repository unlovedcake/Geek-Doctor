import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/Chat-Page/Chat-To-User-Client.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import '../../constant.dart';

class BookingClientPage extends StatefulWidget {
  const BookingClientPage({Key? key}) : super(key: key);

  @override
  _BookingClientPageState createState() => _BookingClientPageState();
}

class _BookingClientPageState extends State<BookingClientPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserServiceProviderModel loggedInUser = UserServiceProviderModel();
  UserModel getTokenId = UserModel();

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
        "android_accent_color": "FF9800FF",

        //"small_icon": "ic_stat_onesignal_default",

        "large_icon": loggedInUser.imageUrl,
        //"https://firebasestorage.googleapis.com/v0/b/geek-doctor-2dd82.appspot.com/o/scaled_image_picker6842236089939337044.png?alt=media&token=d8a07855-98e8-4a26-ac78-876fa2c2e278",

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("table-user-service")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserServiceProviderModel.fromMap(value.data());

      print(loggedInUser.fullName);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Booking Client", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("table-book")
                .where('userServiceModel.uid', isEqualTo: user!.uid)
                .orderBy('dateToBook', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: const CircularProgressIndicator(
                  color: Colors.orange,
                ));
              }
              if (snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            final userClient = snapshot.data!.docs[index];
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
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.orange,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection("table-book")
                                                        .doc(bookingData.id)
                                                        .update({
                                                      'status': "In-Progress",
                                                    }).then((result) {
                                                      Navigator.of(context).pop();
                                                      Fluttertoast.showToast(
                                                          msg: "Booking Accepted ");

                                                      sendNotification(
                                                          [
                                                            "${userClient['userModel']['tokenId']}"
                                                          ],
                                                          "${loggedInUser.fullName}" +
                                                              "  accepted your booking.",
                                                          "Book A Geek");

                                                      print(
                                                          "${userClient.get('userModel.tokenId')} ");
                                                    }).catchError((error) {
                                                      print("Error!");
                                                    });
                                                  },
                                                  child: Text(
                                                    "Accept",
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
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.blue,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ChatToUserClientPage(
                                                                  clientInfo:
                                                                      BookModel.fromMap(
                                                                          userClient
                                                                              .data())),
                                                        ));

                                                    context
                                                        .read<ChatControllerProvider>()
                                                        .setUserClientID(
                                                            userClient.get('id'));
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
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.all(8.0),
                                          //   child: Material(
                                          //     elevation: 5,
                                          //     borderRadius:
                                          //         BorderRadius.circular(30),
                                          //     color: Colors.red,
                                          //     child: MaterialButton(
                                          //         padding:
                                          //             EdgeInsets.fromLTRB(
                                          //                 20, 15, 20, 15),
                                          //         minWidth:
                                          //             MediaQuery.of(context)
                                          //                 .size
                                          //                 .width,
                                          //         onPressed: () async {},
                                          //         child: Text(
                                          //           "Cancel",
                                          //           textAlign:
                                          //               TextAlign.center,
                                          //           style: TextStyle(
                                          //             fontSize: 16,
                                          //             color: Colors.white,
                                          //           ),
                                          //         )),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.green,
                                              child: MaterialButton(
                                                  padding:
                                                      EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  minWidth:
                                                      MediaQuery.of(context).size.width,
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();

                                                    await FirebaseFirestore.instance
                                                        .collection("table-history")
                                                        .add({
                                                      "clientName": userClient
                                                          .get('userModel.fullName'),
                                                      "clientEmail": userClient
                                                          .get('userModel.email'),
                                                      "clientImage": userClient
                                                          .get('userModel.imageUrl'),
                                                      "userServiceName": userClient.get(
                                                          'userServiceModel.fullName'),
                                                      "userServiceEmail": user!.email,
                                                      "serviceImage": userClient.get(
                                                          'userServiceModel.imageUrl'),
                                                      "status": "Finished",
                                                      "dateFinished": DateFormat.yMMMMd()
                                                          .format(DateTime.now()),
                                                    }).then((value) {
                                                      FirebaseFirestore.instance
                                                          .collection('table-book')
                                                          .doc(bookingData.id)
                                                          .update({
                                                        "status": "Completed",
                                                      }).then((_) {});

                                                      Fluttertoast.showToast(
                                                          msg: "Transaction Completed");
                                                    });
                                                  },
                                                  child: Text(
                                                    "Finish Transaction",
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
                                  margin: const EdgeInsets.only(bottom: 5),
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
                                                  imageUrl: userClient
                                                      .get('userModel.imageUrl'),
                                                  progressIndicatorBuilder: (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress.progress),
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 250,
                                                    child: Text(
                                                      "${userClient.get('userModel.fullName')} ",
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'avenir',
                                                          fontSize: 18.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 250,
                                                    child: Text(
                                                      "${userClient.get('userModel.clientAddress')} ",
                                                      style: TextStyle(
                                                          color: Colors.orangeAccent,
                                                          fontFamily: 'avenir'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            text: "Service Need : \n",
                                            style: TextStyle(
                                                fontSize: 16.0, color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: "${userClient.get('serviceNeed')}",
                                                style: TextStyle(
                                                    fontSize: 16.0, color: Colors.white),
                                              ),
                                            ]),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                text: "Status: \n",
                                                style: TextStyle(
                                                    fontSize: 16.0, color: Colors.black),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "${userClient.get('status')}",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: userClient.get('status') ==
                                                                "Pending"
                                                            ? Colors.red
                                                            : Colors.white),
                                                  ),
                                                ]),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "${userClient.get('dateToBook')}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${userClient.get('startTime')}",
                                                    style: TextStyle(
                                                        color: Colors.orangeAccent,
                                                        fontFamily: 'avenir'),
                                                  ),
                                                  Text(" - ",
                                                      style: TextStyle(
                                                        color: Colors.orangeAccent,
                                                      )),
                                                  Text(
                                                    "${userClient.get('endTime')}",
                                                    style: TextStyle(
                                                        color: Colors.orangeAccent,
                                                        fontFamily: 'avenir'),
                                                  ),
                                                ],
                                              ),
                                            ],
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
              } else {
                return Center(child: Text("No Booking List Found"));
              }
            }),
      ),
    );
  }
}
