import 'package:geekdoctor/string_extension.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geekdoctor/Provider/AppProvider.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';
import 'package:path/path.dart' as path;

class ViewProfileUSerService extends StatefulWidget {
  const ViewProfileUSerService();

  @override
  _ViewProfileUSerServiceState createState() => _ViewProfileUSerServiceState();
}

class _ViewProfileUSerServiceState extends State<ViewProfileUSerService> {
  bool isRatePress = false;

  var _ratingPageController = PageController();
  bool _starPosition = false;
  double rating = 3.0;
  int rate1 = 0;
  int rate2 = 0;
  int rate3 = 0;
  int rate4 = 0;
  int rate5 = 0;

  List<int> res = [];
  String ratings = "0";
  int max_index = 0;
  int max_value = 0;

  @override
  void initState() {
    AppProviders.disposeAllDisposableProviders(
        context); //reset the value from provider isRateStart to false
    var em = FirebaseFirestore.instance
        .collection("table-user-service")
        .where("email",
            isEqualTo: Provider.of<ControllerClientProvider>(context, listen: false)
                .getServiceEmail)
        .snapshots();

    em.first.then((value) {
      res = [
        value.docs.first.get('rating')['rate1'].round(),
        value.docs.first.get('rating')['rate2'].round(),
        value.docs.first.get('rating')['rate3'].round(),
        value.docs.first.get('rating')['rate4'].round(),
        value.docs.first.get('rating')['rate5'].round(),
      ];

      ratings = res.reduce((curr, next) => curr > next ? curr : next).toString();
      //res[1].toString()
      max_value = res.reduce(max);

      max_index = res.indexOf(max_value) + 1;

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-user-service")
              .where('email',
                  isEqualTo: context.watch<ControllerClientProvider>().getServiceEmail)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            final currentUser = snapshot.data?.docs;
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            }
            rate1 = currentUser![0]['rating']['rate1'].round();
            rate2 = currentUser[0]['rating']['rate2'].round();
            rate3 = currentUser[0]['rating']['rate3'].round();
            rate4 = currentUser[0]['rating']['rate4'].round();
            rate5 = currentUser[0]['rating']['rate5'].round();

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.orange),
                centerTitle: true,
                title: Text("View Profile", style: TextStyle(color: Colors.orange)),
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () {
                    // passing this to our root
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.phone, color: Colors.orange),
                      onPressed: () async {
                        await launch("tel:" "${currentUser[0]['contactNumber']}");
                      },
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                  child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 1.8,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: <Widget>[
                              Container(
                                width: 150,
                                height: 150,
                                child: Hero(
                                  tag: "tag1",
                                  child: CachedNetworkImage(
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    imageUrl: currentUser[0]['imageUrl'],
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(80)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      color: Colors.orange,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      size: 100,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                direction: Axis.horizontal,
                                spacing: 4,
                                children: [
                                  Text(
                                    "${currentUser[0]["skills"]['expertise1']}",
                                    style:
                                        TextStyle(fontSize: 14.0, color: Colors.orange),
                                  ),
                                  currentUser[0]["skills"]['expertise2'] == ""
                                      ? Container()
                                      : Text(
                                          "${currentUser[0]["skills"]['expertise2']}",
                                          style: TextStyle(
                                              fontSize: 14.0, color: Colors.blue),
                                        ),
                                  currentUser[0]["skills"]['expertise3'] == ""
                                      ? Container()
                                      : Text(
                                          "${currentUser[0]["skills"]['expertise3']}",
                                          style: TextStyle(
                                              fontSize: 14.0, color: Colors.red),
                                        ),
                                  currentUser[0]["skills"]['expertise4'] == ""
                                      ? Container()
                                      : Text(
                                          "${currentUser[0]["skills"]['expertise4']}",
                                          style: TextStyle(
                                              fontSize: 14.0, color: Colors.black),
                                        ),
                                  currentUser[0]["skills"]['expertise5'] == ""
                                      ? Container()
                                      : Text(
                                          "${currentUser[0]["skills"]['expertise5']}",
                                          style: TextStyle(
                                              fontSize: 14.0, color: Colors.green),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: RatingBarIndicator(
                          rating: double.parse(max_index.toString()),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      AnimatedContainer(
                        duration: Duration(microseconds: 200),
                        height: 50,
                        width: 50,
                        child: IconButton(
                          onPressed: () {
                            if (Provider.of<BookAGeekProvider>(context, listen: false)
                                    .getRateStar ==
                                false) {
                              context.read<BookAGeekProvider>().setRateStar(true);
                              //openRatingDialog(context);
                              _displayDialog(context, currentUser[0].id);
                            } else {
                              context.read<BookAGeekProvider>().setRateStar(false);
                            }
                          },
                          icon: Icon(
                            Icons.favorite,
                            size: 20,
                            color: context.watch<BookAGeekProvider>().getRateStar
                                ? Colors.orangeAccent
                                : Colors.red[400],
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: context.watch<BookAGeekProvider>().getRateStar
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade300),
                            boxShadow: context.watch<BookAGeekProvider>().getRateStar
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.grey.shade500,
                                      offset: Offset(6, 6),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(-6, -6),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                    ),
                                  ]),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text("Rate Me"),
                      Container(
                        width: 200,
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      textField(
                        "${currentUser[0]['fullName']}",
                        icon: Icon(
                          Icons.account_circle,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      textField("${currentUser[0]['email']}",
                          icon: Icon(Icons.email, color: Colors.blue)),
                      SizedBox(
                        height: 15.0,
                      ),
                      textField("${currentUser[0]['address']}",
                          icon: Icon(Icons.add_location, color: Colors.red)),
                      SizedBox(
                        height: 15.0,
                      ),
                      textField("${currentUser[0]['contactNumber']}",
                          icon: Icon(Icons.phone, color: Colors.orange)),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              )),
            );
          }),
    );
  }

  Widget textField(String value, {required Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Column(
        children: [
          SizedBox(
            height: 4.0,
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                // textAlign: TextAlign.center,
                initialValue: value,
                enabled: false,
                readOnly: true,
                autofocus: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20, 15, 50, 15),
                  prefixIcon: icon,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 0),
                  ),
                ),
              )),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
        ],
      ),
    );
  }

  _displayDialog(BuildContext context, String uid) async {
    return showModal(
        configuration: FadeScaleTransitionConfiguration(
          transitionDuration: Duration(seconds: 1),
          reverseTransitionDuration: Duration(seconds: 2),
        ),
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              height: max(300, MediaQuery.of(context).size.height * 0.3),
              child: PageView(
                controller: _ratingPageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Thanks for Booking ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text("We love to get your feedback. "),
                      context.watch<BookAGeekProvider>().getRateFace
                          ? AnimatedOpacity(
                              duration: Duration(milliseconds: 800),
                              opacity: context.watch<BookAGeekProvider>().getRateFace
                                  ? 1.0
                                  : 0.0,
                              child: context.watch<BookAGeekProvider>().getIconFace,
                            )
                          : Text(""),

                      RatingBar.builder(
                        initialRating: double.parse(max_index.toString()),
                        // Provider.of<BookAGeekProvider>(context, listen: false)
                        //     .getInitialRating,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.red.shade300,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                          }
                          return Text("");
                        },
                        onRatingUpdate: (rating) {
                          print(rating);
                          if (rating == 1.0) {
                            rateStar(1 + rate1.toDouble(), "rate1", uid);

                            context.read<BookAGeekProvider>().setIconFace(Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.red,
                                  size: 50,
                                ));
                            context.read<BookAGeekProvider>().setRateFace(true);
                            context.read<BookAGeekProvider>().setInitialRating(1);
                          } else if (rating == 2.0) {
                            rateStar(1 + rate1.toDouble(), "rate2", uid);
                            context.read<BookAGeekProvider>().setIconFace(Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.redAccent,
                                  size: 50,
                                ));
                            context.read<BookAGeekProvider>().setRateFace(true);
                            context.read<BookAGeekProvider>().setInitialRating(2);
                          } else if (rating == 3.0) {
                            rateStar(1 + rate3.toDouble(), "rate3", uid);

                            context.read<BookAGeekProvider>().setIconFace(Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.orangeAccent,
                                  size: 50,
                                ));
                            context.read<BookAGeekProvider>().setRateFace(true);
                            context.read<BookAGeekProvider>().setInitialRating(3);
                          } else if (rating == 4.0) {
                            rateStar(1 + rate4.toDouble(), "rate4", uid);
                            context.read<BookAGeekProvider>().setIconFace(Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.lightGreen,
                                  size: 50,
                                ));
                            context.read<BookAGeekProvider>().setRateFace(true);
                            context.read<BookAGeekProvider>().setInitialRating(4);
                          } else if (rating == 5.0) {
                            rateStar(1 + rate5.toDouble(), "rate5", uid);
                            context.read<BookAGeekProvider>().setIconFace(Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                  size: 50,
                                ));
                            context.read<BookAGeekProvider>().setRateFace(true);
                            context.read<BookAGeekProvider>().setInitialRating(5);
                          }
                        },
                      ),

                      //Done Button
                      Container(
                        width: double.infinity,
                        color: Colors.orange,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Done"),
                          textColor: Colors.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            //Star Rating
          );
        });
  }

  openRatingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              height: max(300, MediaQuery.of(context).size.height * 0.3),
              child: PageView(
                controller: _ratingPageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Thanks for Booking ",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text("We love to get your feedback. "),
                      context.watch<BookAGeekProvider>().getRateFace
                          ? AnimatedContainer(
                              duration: Duration(milliseconds: 600),
                              child: Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                                size: 60,
                              ),
                            )
                          : Text(""),

                      RatingBar.builder(
                        initialRating: 3,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.red.shade300,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                          }
                          return Text("");
                        },
                        onRatingUpdate: (rating) {
                          print(rating);
                          if (rating == 1.0) {
                            print("OKE");
                            context.read<BookAGeekProvider>().setRateFace(true);
                          }
                        },
                      ),

                      //Done Button
                      Container(
                        width: double.infinity,
                        color: Colors.orange,
                        child: MaterialButton(
                          onPressed: () {},
                          child: Text("Done"),
                          textColor: Colors.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            //Star Rating
          );
        });
  }

  rateStar(double rateValue, String key, String uid) {
    FirebaseFirestore.instance
        .collection('table-user-service')
        .doc(uid)
        .update({"rating." "$key": rateValue}).then((_) async {});
  }

  final Widget textFormField = Padding(
    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10.0),
          alignment: Alignment.topLeft,
          child: Text(
            "adasd",
            style: TextStyle(
                fontSize: 16.0, color: Colors.blueGrey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                // readOnly: widget == null ? false : true,
                readOnly: true,
                autofocus: false,
                cursorColor: Colors.grey,

                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 4.0,
        ),
      ],
    ),
  );
}
