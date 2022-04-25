import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Drawer/User-Client-Drawer.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/src/provider.dart';

import '../../Internet-Connection.dart';
import 'package:new_version/new_version.dart';

import '../../Permission-Location.dart';

class UserClientHomePage extends StatefulWidget {
  const UserClientHomePage({Key? key}) : super(key: key);

  @override
  _UserClientHomePageState createState() => _UserClientHomePageState();
}

class _UserClientHomePageState extends State<UserClientHomePage>
    with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  DateTime pre_backpress = DateTime.now();

  loggedIn() async {
    await FirebaseFirestore.instance
        .collection("table-user-client")
        .doc(user!.uid)
        .get()
        .then((value) async {
      //loggedInUser = UserModel.fromMap(value.data());

      var deviceState = await OneSignal.shared.getDeviceState();
      if (deviceState == null || deviceState.userId == null) return;

      var tokenId = deviceState.userId!;

      if (tokenId != value.data()!['tokenId']) {
        await FirebaseFirestore.instance
            .collection("table-user-client")
            .doc(user!.uid)
            .update({
              'tokenId': tokenId,
            })
            .then((result) {})
            .catchError((error) {
              print("Error!");
            });
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    loggedIn(); // update token ID if user use another phone device
    super.initState();

    _checkVersion();
    WidgetsBinding.instance?.addObserver(this);
    FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
      "status": "Active",
    }, SetOptions(merge: true)).then((_) async {});
    print("RESUME");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    setState(() {
      if (state == AppLifecycleState.resumed) {
        print("RESUME");
        FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
          "status": "Active",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.inactive) {
        print("INACTIVE");
        FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
          "status": "Inactive",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.paused) {
        print(" PAUSE");
        FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
          "status": "Inactive",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.detached) {
        print("DETACHED");
        FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
          "status": "Offline",
        }, SetOptions(merge: true)).then((_) async {});
      }
    });
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      androidId: "com.geekdoctor.co",
    );
    final status = await newVersion.getVersionStatus();

    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status!,
      dialogTitle: "Update Available !!!",
      updateButtonText: "Update",
      dismissButtonText: "Maybe Later",
      dialogText: "Please update the app to Play Store from " +
          "${status.localVersion}" +
          " to " +
          "${status.storeVersion}" +
          " version.",
      dismissAction: () {
        //SystemNavigator.pop();
        Navigator.pop(context);
      },
    );

    print("DEVICE : " + status.localVersion);
    print("STORE : " + status.storeVersion);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
    FirebaseFirestore.instance.collection('table-user-client').doc(user!.uid).set({
      "status": "Offline",
    }, SetOptions(merge: true)).then((_) async {});

    print('dispose called.............');
  }

  @override
  Widget build(BuildContext context) {
    context.read<ChatControllerProvider>().checkInternetConnection();

    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          //show snackbar
          Fluttertoast.showToast(msg: 'Press Back button again to Exit');

          return false;
        } else {
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange),
          elevation: 0,
          // centerTitle: true,
          // title: Text("Home", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.white,
        ),
        drawer: UserClientDrawer(),
        bottomNavigationBar: BottomNavBar(index: 0),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("images/welcome-screen.json", animate: true),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/geeklogo.png",
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  TextLiquidFill(
                    text: 'GEEK DOCTOR',
                    waveColor: Colors.orange,
                    boxBackgroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    boxHeight: 50.0,
                  ),
                  // RichText(
                  //   text: TextSpan(
                  //       text: "",
                  //       style: TextStyle(fontSize: 20.0, color: Colors.black),
                  //       children: <TextSpan>[
                  //         TextSpan(
                  //           text: "Geek Doctor  ",
                  //           style: TextStyle(
                  //               fontSize: 22.0,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.orange),
                  //         ),
                  //       ]),
                  // ),
                  SizedBox(height: 20),
                  context.watch<ChatControllerProvider>().hasInternet == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Internet Connection",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.wifi_off,
                              color: Colors.red,
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 60),
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
                    // onPrimary: Colors.white,
                    primary: Colors.white, // foreground
                  ),
                  onPressed: () {
                    PermissionLocation.determinePosition(context);
                    Navigator.pushNamed(context, '/geek-a-book-list-page');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Book A Geek Now',
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
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
