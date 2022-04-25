import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ControllerUserServiceProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String? errorMessage;
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;

  String? userEmail;

  GeoFirePoint? myLocation;

  //Using Future Builder
  getUserClientDetails() async {
    var snapshots = await FirebaseFirestore.instance.collection('jobs').get();
    var snapshotDocuments = snapshots.docs;
    List<UserServiceProviderModel> jobs = [];
    for (var docs in snapshotDocuments) {
      docs.data()['fullName'];
    }
  }

  //Using Stream Builder
  Stream<QuerySnapshot> userClientCurrentLoggedIn() {
    return FirebaseFirestore.instance
        .collection("table-user-service")
        .where('email', isEqualTo: user!.email)
        .snapshots();
  }

  final List<Map<String, dynamic>> _allUsers = [];
  Future<List<Map<String, dynamic>>> getAllUser() async {
    final res = await FirebaseFirestore.instance.collection("table-user-service").get();

    res.docs.forEach((doc) {
      _allUsers.add(doc.data());
    });

    return _allUsers;
  }

  List<Map<String, dynamic>> get searchGeek => _allUsers;

  Future<QuerySnapshot> loggedInUser() async {
    return await FirebaseFirestore.instance
        .collection("table-user-service")
        .where('email', isEqualTo: user!.email)
        .get();
  }

  signUp(String email, String password, UserServiceProviderModel? userModel,
      BuildContext context) async {
    final _auth = FirebaseAuth.instance;

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        {
          postDetailsToFirestore(userModel!, context);
          userClientCurrentLoggedIn();

          userEmail = email;
          notifyListeners();
        }
      }).catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "You don't have internet access.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  postDetailsToFirestore(UserServiceProviderModel userModel, BuildContext context) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    var deviceState = await OneSignal.shared.getDeviceState();
    if (deviceState == null || deviceState.userId == null) return;

    var tokenId = deviceState.userId!;

    try {
      Position? pos =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      myLocation = GeoFirePoint(pos.latitude, pos.longitude);
    } catch (e) {
      print(e);
    }

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.fullName = userModel.fullName;
    userModel.address = userModel.address;
    userModel.contactNumber = userModel.contactNumber;
    userModel.vaccinated = userModel.vaccinated;
    userModel.tokenId = tokenId;
    userModel.imageUrl =
        "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";

    userModel.position = {
      'latitude': myLocation!.latitude,
      'longitude': myLocation!.longitude
    };
    await firebaseFirestore
        .collection("table-user-service")
        .doc(user.uid)
        .set(userModel.toMap());

    notifyListeners();
    Navigator.pushNamed(context, '/user-service-home-page');

    CherryToast.success(
      title: 'Geek Doctor',
      displayTitle: false,
      autoDismiss: true,
      description: 'You are now logged in !!!',
      animationType: ANIMATION_TYPE.fromTop,
      actionStyle: TextStyle(color: Colors.green),
      animationDuration: Duration(milliseconds: 600),
      action: '',
      actionHandler: () {},
    ).show(context);

    //Fluttertoast.showToast(msg: "Account created successfully :) ");
  }

  signIn(String email, String password, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) {
        Navigator.pushNamed(context, '/user-service-home-page');

        userClientCurrentLoggedIn();

        notifyListeners();
        Fluttertoast.showToast(msg: "Login Successful");
      });
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";

          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  String get _userEmail => userEmail!;

  uploadImage(String? uid, String? fileName, String? imageUrl, File? imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      Reference ref = storage.ref().child(fileName!);

      UploadTask? uploadTask = ref.putFile(imageFile!);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.collection("table-user-service").doc(uid).update({
        "imageUrl": imageUrl,
      }).then((_) {
        print("success!");
        Fluttertoast.showToast(msg: "Image Save");
      });
    } on FirebaseException catch (error) {
      print(error);
    }
  }
}
