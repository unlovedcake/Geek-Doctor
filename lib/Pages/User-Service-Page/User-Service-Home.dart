import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Drawer/User-Service-Drawer.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Login-Page.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class UserServiceHome extends StatefulWidget {
  const UserServiceHome({Key? key}) : super(key: key);

  @override
  _UserServiceHomeState createState() => _UserServiceHomeState();
}

class _UserServiceHomeState extends State<UserServiceHome> with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  UserServiceProviderModel? loggedInUser = UserServiceProviderModel();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  loggedIn() async {
    await FirebaseFirestore.instance
        .collection("table-user-service")
        .doc(user!.uid)
        .get()
        .then((value) async {
      this.loggedInUser = UserServiceProviderModel.fromMap(value.data());

      var deviceState = await OneSignal.shared.getDeviceState();
      if (deviceState == null || deviceState.userId == null) return;

      var tokenId = deviceState.userId!;

      if (tokenId != value.data()!['tokenId']) {
        await FirebaseFirestore.instance
            .collection("table-user-service")
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
    loggedIn();
    _checkVersion();
    super.initState();

    FirebaseFirestore.instance
        .collection("table-user-service")
        .doc(user!.uid)
        .get()
        .then((value) async {
      print("${user!.uid}" "OKEOEKEKE");

      this.loggedInUser = await UserServiceProviderModel.fromMap(value.data());

      WidgetsBinding.instance?.addObserver(this);
      FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
        "status": "Active",
      }, SetOptions(merge: true)).then((_) async {});
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    setState(() {
      if (state == AppLifecycleState.resumed) {
        print("RESUME");
        FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
          "status": "Active",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.inactive) {
        print("INACTIVE");
        FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
          "status": "Inactive",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.detached) {
        print("DETACHED");
        FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
          "status": "Offline",
        }, SetOptions(merge: true)).then((_) async {});
      } else if (state == AppLifecycleState.paused) {
        print("$state: PAUSE");
        FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
          "status": "Inactive",
        }, SetOptions(merge: true)).then((_) async {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FirebaseFirestore.instance.collection('table-user-service').doc(user!.uid).set({
      "status": "Offline",
    }, SetOptions(merge: true)).then((_) async {});
    WidgetsBinding.instance!.removeObserver(this);
    print('dispose called.............');
  }

  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          Fluttertoast.showToast(msg: 'Press Back button again to Exit');

          return false;
        } else {
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: UserServiceDrawer(),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-user-service")
              .where('email', isEqualTo: user!.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            final currentUser = snapshot.data?.docs;

            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset("images/animate-text.json", animate: true),
                      SizedBox(height: 20),
                      Text(
                        loggedInUser!.fullName == null
                            ? ""
                            : "Hi" + "  " + "${loggedInUser!.fullName}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: "Welcome to ",
                                style: TextStyle(fontSize: 16.0, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Geek Doctor  ",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                ]),
                          ),
                          Image.asset(
                            "images/geeklogo.png",
                            height: 40,
                            width: 40,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          const Text(
                            'Geek',
                            style: TextStyle(fontSize: 40.0),
                          ),
                          const SizedBox(width: 20.0, height: 50.0),
                          DefaultTextStyle(
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Horizon',
                                color: Colors.black),
                            child: AnimatedTextKit(
                              stopPauseOnTap: false,
                              repeatForever: true,
                              animatedTexts: [
                                RotateAnimatedText('AWESOME',
                                    textStyle: TextStyle(color: Colors.orange)),
                                RotateAnimatedText('OPTIMISTIC',
                                    textStyle: TextStyle(color: Colors.blue)),
                                RotateAnimatedText('DIFFERENT',
                                    textStyle: TextStyle(color: Colors.teal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }
          },
        ),
      ),
    );
  }
}

// the logout function
Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => UserLoginClientPage()));
}
