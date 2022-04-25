import 'dart:math';
import 'package:geekdoctor/string_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/AppProvider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/src/provider.dart';

import '../../Permission-Location.dart';
import 'Search-User-SerVice-Provider.dart';

class GeekABookListServicePage extends StatefulWidget {
  const GeekABookListServicePage({Key? key}) : super(key: key);

  @override
  _GeekABookListServicePageState createState() => _GeekABookListServicePageState();
}

class _GeekABookListServicePageState extends State<GeekABookListServicePage> {
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;
  double defualtValue = 1.0;
  List listUsers = [];
  String? _currentAddress;

  List<int> res = [];
  List rateStar = [];
  String ratings = "0";
  int max_index = 0;
  int max_value = 0;

  bool refreshPage = true;

  Future getAlluser() async {
    try {
      final res = await FirebaseFirestore.instance.collection("table-user-service").get();

      res.docs.forEach((doc) {
        listUsers.add(doc.data());
      });

      return res;
    } catch (e) {
      return null;
    }
  }

  Future getDis() async {
    try {
      _currentUserPosition =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (listUsers.length != 0) {
        for (int i = 0; i < listUsers.length; i++) {
          double? storelat = listUsers[i]['position']['latitude'];
          double? storelng = listUsers[i]['position']['longitude'];

          distanceImMeter = await Geolocator.distanceBetween(
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude,
            storelat!,
            storelng!,
          );
          double? distance = distanceImMeter?.round().toDouble();

          listUsers[i]['distance'] = (distance! / 1000).round().toDouble();

          List<Placemark> placemarks = await placemarkFromCoordinates(
              listUsers[i]['position']['latitude'],
              listUsers[i]['position']['longitude']);

          Placemark place = placemarks[0];

          _currentAddress = "${place.locality}, ${place.country}";
          listUsers[i]['address'] = _currentAddress;

          setState(() {});
        }
      }

      listUsers.sort((a, b) => a["distance"].compareTo(b["distance"]));
    } catch (e) {}
  }

  Future getRate() async {
    try {
      for (int i = 0; i < listUsers.length; i++) {
        res = [
          listUsers[i]['rating']['rate1'].round(),
          listUsers[i]['rating']['rate2'].round(),
          listUsers[i]['rating']['rate3'].round(),
          listUsers[i]['rating']['rate4'].round(),
          listUsers[i]['rating']['rate5'].round(),
        ];

        max_value = res.reduce(max);

        max_index = res.indexOf(max_value);

        rateStar.add(max_index + 1);
        listUsers[i]['highScoreRating'] = max_index + 1.toDouble();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    getAlluser();

    getDis();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getRate();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Services Provider", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SearchUserServiceProvider()));
            },
            icon: Icon(Icons.search),
          ),
        ],
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.red),
        //   onPressed: () {
        //     // passing this to our root
        //     Navigator.of(context).pop();
        //   },
        // ),
      ),
      body: FutureBuilder(
        future: getDis(),
        builder: (context, projectSnap) {
          // if (projectSnap.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator(color: Colors.black));
          // }

          if (listUsers.length == 0) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          } else {
            return ListView.builder(
              itemCount: listUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/book-a-geek-page');
                    context
                        .read<ControllerClientProvider>()
                        .setUserServiceEmail(listUsers[index]['email']);
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              child: CachedNetworkImage(
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                imageUrl: listUsers[index]['imageUrl'],
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    child: Container(
                                      width: 250,
                                      child: Text(
                                        listUsers[index]['fullName'],
                                        style: GoogleFonts.spectral(
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  FittedBox(
                                    child: Container(
                                      width: 260,
                                      child: Text(
                                        listUsers[index]['address'] == null
                                            ? "Philippines"
                                            : listUsers[index]['address'],
                                        style: TextStyle(color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    listUsers[index]['vaccinated'].toString() == "Yes"
                                        ? "Vaccinated"
                                        : "Unvaccinated",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: listUsers[index]['vaccinated'].toString() ==
                                              "Yes"
                                          ? Colors.green
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.blueGrey,
                                  ),
                                  Text(
                                    "${listUsers[index]['distance']}"
                                    ' km away',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  RatingBarIndicator(
                                    // rating: double.parse(rateStar[index].toString()),
                                    rating: listUsers[index]['highScoreRating'],
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Expertise with:",
                          style: GoogleFonts.spectral(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.start,
                          direction: Axis.horizontal,
                          spacing: 4,
                          children: [
                            ActionChip(
                                backgroundColor: Colors.orange,
                                shadowColor: Colors.black,
                                label: Text(
                                  listUsers[index]['skills']['expertise1'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {}),
                            //Text(listUsers[index]['skills']['expertise1']),
                            listUsers[index]['skills']['expertise2'] == ""
                                ? Container()
                                : ActionChip(
                                    backgroundColor: Colors.blue,
                                    shadowColor: Colors.black,
                                    label: Text(
                                      listUsers[index]['skills']['expertise2'] ?? "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {}),
                            listUsers[index]['skills']['expertise3'] == ""
                                ? Container()
                                : ActionChip(
                                    backgroundColor: Colors.red,
                                    shadowColor: Colors.black,
                                    label: Text(
                                      listUsers[index]['skills']['expertise3'] ?? "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {}),
                            listUsers[index]['skills']['expertise4'] == ""
                                ? Container()
                                : ActionChip(
                                    backgroundColor: Colors.blueGrey,
                                    shadowColor: Colors.black,
                                    label: Text(
                                      listUsers[index]['skills']['expertise4'] ?? "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {}),
                            listUsers[index]['skills']['expertise5'] == ""
                                ? Container()
                                : ActionChip(
                                    backgroundColor: Colors.teal,
                                    shadowColor: Colors.black,
                                    label: Text(
                                      listUsers[index]['skills']['expertise5'] ?? "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {}),
                          ],
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
