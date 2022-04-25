import 'dart:math';
import 'package:geekdoctor/string_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/src/provider.dart';
import '../../Router.dart';
import 'Book-A-Geek.dart';

class SearchUserServiceProvider extends StatefulWidget {
  const SearchUserServiceProvider({Key? key}) : super(key: key);

  @override
  _SearchUserServiceProviderState createState() => _SearchUserServiceProviderState();
}

class _SearchUserServiceProviderState extends State<SearchUserServiceProvider> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  String searchKeyword = "";

  final List _allUsers = [];
  List _foundUsers = [];

  List<int> res = [];
  List skills = [];
  List listOfSkills = [];

  List results4 = [];

  List rateStar = [];
  String ratings = "0";
  int max_index = 0;
  int max_value = 0;

  double? distanceImMeter = 0.0;
  Position? _currentUserPosition;

  getAlluser() async {
    final res = await FirebaseFirestore.instance.collection("table-user-service").get();

    res.docs.forEach((doc) {
      _allUsers.add(doc.data());
    });
  }

  Future getRate() async {
    try {
      for (int i = 0; i < _allUsers.length; i++) {
        res = [
          _allUsers[i]['rating']['rate1'].round(),
          _allUsers[i]['rating']['rate2'].round(),
          _allUsers[i]['rating']['rate3'].round(),
          _allUsers[i]['rating']['rate4'].round(),
          _allUsers[i]['rating']['rate5'].round(),
        ];

        max_value = res.reduce(max); //get the max value of each data in list

        max_index = res.indexOf(max_value); //get the index of max value in list

        rateStar.add(max_index + 1); // getting the highest  rate star

      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getAlluser();

    _foundUsers = _allUsers;

    super.initState();

    print(_foundUsers);
  }

  Future getDis() async {
    try {
      _currentUserPosition =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      String? _currentAddress = "";

      if (_foundUsers.length != 0) {
        for (int i = 0; i < _foundUsers.length; i++) {
          double? storelat = _foundUsers[i]['position']['latitude'];
          double? storelng = _foundUsers[i]['position']['longitude'];

          distanceImMeter = await Geolocator.distanceBetween(
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude,
            storelat!,
            storelng!,
          );
          double? distance = distanceImMeter!.round().toDouble();

          _foundUsers[i]['distance'] = (distance / 1000).round().toDouble();

          List<Placemark> placemarks = await placemarkFromCoordinates(
              _foundUsers[i]['position']['latitude'],
              _foundUsers[i]['position']['longitude']);

          Placemark place = placemarks[0];

          _currentAddress = "${place.locality}, ${place.country}";
          _foundUsers[i]['address'] = _currentAddress;

          setState(() {});
        }
      }

      _foundUsers.sort((a, b) => a["distance"].compareTo(b["distance"]));
    } catch (e) {}
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List results1 = [];
    List results2 = [];
    List results3 = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      //results = _allUsers;

    } else {
      results4 = listOfSkills.where((element) {
        final r = element.toLowerCase();
        final input = enteredKeyword.toLowerCase();
        return r.contains(input);
      }).toList();

      results1 = _allUsers
          .where((user) =>
              user["skills"]['expertise1']
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              user["skills"]['expertise2']
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              user["skills"]['expertise3']
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              user["skills"]['expertise4']
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              user["skills"]['expertise5']
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      results2 = _allUsers
          .where((user) => user["skills"]['expertise2']
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();

      results3 = _allUsers
          .where((user) => user["skills"]['expertise3']
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();

      for (int i = 0; i < results1.length; i++) {
        res = [
          results1[i]['rating']['rate1'].round(),
          results1[i]['rating']['rate2'].round(),
          results1[i]['rating']['rate3'].round(),
          results1[i]['rating']['rate4'].round(),
          results1[i]['rating']['rate5'].round(),
        ];

        max_value = res.reduce(max);

        max_index = res.indexOf(max_value);

        rateStar.add(max_index + 1);

        results1[i]['highScoreRating'] = max_index + 1.toDouble();
      }

      for (int i = 0; i < results2.length; i++) {
        res = [
          results2[i]['rating']['rate1'].round(),
          results2[i]['rating']['rate2'].round(),
          results2[i]['rating']['rate3'].round(),
          results2[i]['rating']['rate4'].round(),
          results2[i]['rating']['rate5'].round(),
        ];

        max_value = res.reduce(max);

        max_index = res.indexOf(max_value);

        rateStar.add(max_index + 1);
        results2[i]['highScoreRating'] = max_index + 1.toDouble();
      }

      for (int i = 0; i < results3.length; i++) {
        res = [
          results3[i]['rating']['rate1'].round(),
          results3[i]['rating']['rate2'].round(),
          results3[i]['rating']['rate3'].round(),
          results3[i]['rating']['rate4'].round(),
          results3[i]['rating']['rate5'].round(),
        ];

        max_value = res.reduce(max);

        max_index = res.indexOf(max_value);

        rateStar.add(max_index + 1);
        results3[i]['highScoreRating'] = max_index + 1.toDouble();
      }

      setState(() {});
    }

    // Refresh the UI
    setState(() {
      searchKeyword = enteredKeyword;

      if (results1.isNotEmpty) {
        _foundUsers = results1;
        getDis();
      } else {
        _foundUsers = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //getRate();
    return WillPopScope(
      onWillPop: () async {
        context.read<ControllerClientProvider>().setSelectedBottomNav(0);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Container(
            height: 38,
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none),
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  hintText: "Search..."),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(index: 4),
        body: Column(
          children: [
            Expanded(
                child: (_foundUsers.isNotEmpty)
                    ? ListView.builder(
                        itemCount: _foundUsers.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/book-a-geek-page');
                              context
                                  .read<ControllerClientProvider>()
                                  .setUserServiceEmail(_foundUsers[index]['email']);
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
                                          imageUrl: _foundUsers[index]['imageUrl'],
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
                                            Text(
                                              _foundUsers[index]['fullName'],
                                              style: GoogleFonts.spectral(
                                                textStyle: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  letterSpacing: .5,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              _foundUsers[index]['address'] == null
                                                  ? "Philippines"
                                                  : _foundUsers[index]['address'],
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              _foundUsers[index]['vaccinated']
                                                          .toString() ==
                                                      "Yes"
                                                  ? "Vaccinated"
                                                  : "Unvaccinated",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _foundUsers[index]['vaccinated']
                                                            .toString() ==
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
                                              "${_foundUsers[index]['distance'] ?? "0.0"}"
                                              ' km away',
                                              style: TextStyle(color: Colors.redAccent),
                                            ),
                                            RatingBarIndicator(
                                              // rating: double.parse(rateStar[index].toString()),
                                              rating: _foundUsers[index]
                                                  ['highScoreRating'],
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
                                            _foundUsers[index]['skills']['expertise1'],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {}),
                                      //Text(listUsers[index]['skills']['expertise1']),
                                      _foundUsers[index]['skills']['expertise2'] == ""
                                          ? Container()
                                          : ActionChip(
                                              backgroundColor: Colors.blue,
                                              shadowColor: Colors.black,
                                              label: Text(
                                                _foundUsers[index]['skills']
                                                    ['expertise2'],
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {}),
                                      _foundUsers[index]['skills']['expertise3'] == ""
                                          ? Container()
                                          : ActionChip(
                                              backgroundColor: Colors.red,
                                              shadowColor: Colors.black,
                                              label: Text(
                                                _foundUsers[index]['skills']
                                                    ['expertise3'],
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {}),
                                      _foundUsers[index]['skills']['expertise4'] == ""
                                          ? Container()
                                          : ActionChip(
                                              backgroundColor: Colors.blueGrey,
                                              shadowColor: Colors.black,
                                              label: Text(
                                                _foundUsers[index]['skills']
                                                    ['expertise4'],
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {}),
                                      _foundUsers[index]['skills']['expertise5'] == ""
                                          ? Container()
                                          : ActionChip(
                                              backgroundColor: Colors.teal,
                                              shadowColor: Colors.black,
                                              label: Text(
                                                _foundUsers[index]['skills']
                                                    ['expertise5'],
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
                        })
                    : (searchKeyword.isNotEmpty)
                        ? Center(
                            child: Text(
                            "No Results Found",
                            style: TextStyle(fontSize: 18),
                          ))
                        : Center(
                            child: Text(
                            "Search Specific Skills",
                            style: TextStyle(fontSize: 18),
                          ))),
          ],
        ),
      ),
    );
  }
}
