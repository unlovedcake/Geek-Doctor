import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geekdoctor/Pages/User-Service-Page/User-Service-History.dart';
import 'package:geekdoctor/Permission-Location.dart';
import 'package:geekdoctor/Router.dart';
import 'package:geekdoctor/constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geekdoctor/Pages/Admin/admin-home-page.dart';
import 'package:geekdoctor/Pages/Chat-Page/Chat-To-User-Client.dart';
import 'package:geekdoctor/Pages/Chat-Page/Chat-To-User-Service.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Book-A-Geek.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Booking-List.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Edit-Booking.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Geek-A-Book-List.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-History-Page.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Profile-Page.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Register-Page.dart';
import 'package:geekdoctor/Pages/User-Service-Page/Booking-Client-Page.dart';
import 'package:geekdoctor/Pages/User-Service-Page/User-Service-Login.dart';
import 'package:geekdoctor/Pages/User-Service-Page/User-Service-Register-Page.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Provider/User-Service-Login-Register/Controller-User-Service-Provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'Pages/User-Client-Page/Search-User-SerVice-Provider.dart';
import 'Pages/User-Client-Page/User-Client-EditProfile-Page.dart';
import 'Pages/User-Client-Page/User-Client-Home-Page.dart';
import 'Pages/User-Client-Page/User-Client-Login-Page.dart';
import 'Pages/User-Service-Page/User-Service-Edit-Profile-Page.dart';
import 'Pages/User-Service-Page/User-Service-Home.dart';
import 'Pages/User-Service-Page/User-Service-Profile-Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

// Initialize our global NavigatorKey
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown
  // ]); //disable lanscape mode
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControllerClientProvider()),
        ChangeNotifierProvider(create: (_) => ControllerUserServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookAGeekProvider()),
        ChangeNotifierProvider(create: (_) => ChatControllerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        openAppSettings();
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      openAppSettings();

      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  var userss;
  @override
  void initState() {
    super.initState();
    PermissionLocation.determinePosition(context);
    configOneSignel();

    // _determinePosition();

    userss = FirebaseAuth.instance.currentUser;
    if (userss == null) {
      userss = null;
    } else {
      if (FirebaseAuth.instance.currentUser!.displayName == "User Client") {
        userss = "User Client";
      } else if (FirebaseAuth.instance.currentUser!.displayName != "User Client" &&
          FirebaseAuth.instance.currentUser!.email != "admin@gmail.com") {
        userss = "User Service";
      } else if (FirebaseAuth.instance.currentUser!.email == "admin@gmail.com") {
        userss = "Admin";
      }
    }

    initPlatformState();
  }

  void configOneSignel() {
    OneSignal.shared.setAppId(keyAppID);
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    //when user tap the notification bar it will redirect to set particular page
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      if (userss == "User Client") {
        navigatorKey.currentState?.pushNamed('/booking-list-page');
      } else {
        navigatorKey.currentState?.pushNamed('/booking-client-page');
      }

      print('NOTIFICATION OPENED HANDLER CALLED WITH: ${result}');
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Geek Doctor',
      home: userss == "User Client"
          ? UserClientHomePage()
          : userss == "User Service"
              ? UserServiceHome()
              : userss == "Admin"
                  ? AdminHomePage()
                  : SplassScreen(),

      routes: {
        //'/': (context) => UserLoginClientPage(),
        '/user-register-client-page': (context) => UserRegisterClientPage(),
        '/client-home-page': (context) => UserClientHomePage(),
        '/user-client-profile-page': (context) => UserClientProfilePage(),
        '/user-client-edit-profile-page': (context) => UserClientEditProfilePage(),
        '/geek-a-book-list-page': (context) => GeekABookListServicePage(),
        '/book-a-geek-page': (context) => BookAGeekPage(),
        '/booking-list-page': (context) => BookingListPage(),
        '/edit-booking-page': (context) => EditBookingPage(),
        '/search-user-service-provider-page': (context) => SearchUserServiceProvider(),
        '/user-client-history-page': (context) => UserClientHistoryPage(),
        //'/chat-to-user-service': (context) => ChatToUserService(),

        //Service User
        '/user-service-login-page': (context) => UserServiceLoginPage(),
        '/user-service-registration-page': (context) => UserServiceRegistrationPage(),
        '/user-service-home-page': (context) => UserServiceHome(),
        '/user-service-profile-page': (context) => UserServiceProfilePage(),
        '/user-service-edit-profile-page': (context) => UserServiceEditProfilePage(),
        '/booking-client-page': (context) => BookingClientPage(),
        '/user-service-history': (context) => UserServiceHistory(),
        //'/chat-to-user-client': (context) => ChatToUserClientPage(),
      },
    );
  }
}

class SplassScreen extends StatefulWidget {
  const SplassScreen({Key? key}) : super(key: key);

  @override
  _SplassScreenState createState() => _SplassScreenState();
}

class _SplassScreenState extends State<SplassScreen> {
  var user;
  @override
  void initState() {
    super.initState();

    Timer(
        Duration(seconds: 3),
        () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserLoginClientPage(),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            "images/geeklogo.png",
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
