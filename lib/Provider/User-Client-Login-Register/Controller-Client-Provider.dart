import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:geekdoctor/Abstract/Disposal-Value-Provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Home-Page.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControllerClientProvider extends DisposableProvider {
  String? errorMessage;
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;

  String? userEmail;

  String? userClientEmail;

  DateTime? _selectedDate = DateTime.now();
  String? _startTime = "";
  String? _endTime = "";

  bool isLoading = false;
  int selectedIndex = 0;

  setSelectedBottomNav(int _selectedBottomNav) {
    selectedIndex = _selectedBottomNav;
    notifyListeners();
  }

  bool get loading => isLoading;

  int get getSelectedBottomNav => selectedIndex;

  setUserServiceEmail(String? _email) {
    userEmail = _email;
    notifyListeners();
  }

  String get getServiceEmail => userEmail!;

  setUserClientEmail(String? _email) {
    userClientEmail = _email;
    notifyListeners();
  }

  String get getClientEmail => userClientEmail!;

  Stream<QuerySnapshot> getUserServiceEmail() {
    return FirebaseFirestore.instance
        .collection("table-user-service")
        .where('email', isEqualTo: userEmail)
        .snapshots();
  }

  //Using Future Builder
  getUserClientDetails() {
    return FirebaseFirestore.instance
        .collection("table-user-client")
        .doc(user!.uid)
        .get();
  }

  Stream<QuerySnapshot> editUserClientDetails() {
    return FirebaseFirestore.instance
        .collection("table-user-client")
        .where('email', isEqualTo: user!.email)
        .snapshots();
  }

  //Using Stream Builder
  Stream<QuerySnapshot> userClientCurrentLoggedIn() {
    return FirebaseFirestore.instance
        .collection("table-user-client")
        .where('email', isEqualTo: user!.email)
        .snapshots();
  }

  signUp(
      String email, String password, UserModel? userModel, BuildContext context) async {
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

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      await user!.updateDisplayName("User Client");
      await user!.reload();
      user = _auth.currentUser;

      if (user != null) {
        postDetailsToFirestore(userModel!);
        Navigator.pushNamed(context, '/client-home-page');

        CherryToast.success(
          title: 'Geek Doctor',
          displayTitle: false,
          autoDismiss: true,
          description: 'You are now logged in !!!',
          animationType: ANIMATION_TYPE.fromTop,
          actionStyle: TextStyle(color: Colors.green),
          animationDuration: Duration(milliseconds: 500),
          action: '',
          actionHandler: () {},
        ).show(context);
      }

      notifyListeners();
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
          errorMessage = "Check Your Internet Access.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  postDetailsToFirestore(UserModel userModel) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    var deviceState = await OneSignal.shared.getDeviceState();
    if (deviceState == null || deviceState.userId == null) return;

    var tokenId = deviceState.userId!;

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.fullName = userModel.fullName;
    userModel.address = userModel.address;
    userModel.contactNumber = userModel.contactNumber;
    userModel.tokenId = tokenId;
    userModel.imageUrl =
        "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";

    await firebaseFirestore
        .collection("table-user-client")
        .doc(user.uid)
        .set(userModel.toMap());
    // Fluttertoast.showToast(msg: "Account created successfully :) ");
  }

  Future signIn(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating, Please wait...",
          );
        });
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) async {
        User? usr = await FirebaseAuth.instance.currentUser;
        if (email == "admin@gmail.com" && password == "admin143") {
          Navigator.pushNamed(context, '/user-service-login-page');
        } else if (usr!.displayName == "User Client") {
          Navigator.pushNamed(context, '/client-home-page');
        } else {
          Navigator.pushNamed(context, '/user-service-home-page');
        }

        CherryToast.success(
          title: 'Geek Doctor',
          displayTitle: false,
          autoDismiss: true,
          description: 'You are now logged in !!!',
          animationType: ANIMATION_TYPE.fromTop,
          actionStyle: TextStyle(color: Colors.green),
          animationDuration: Duration(milliseconds: 500),
          action: '',
          actionHandler: () {},
        ).show(context);
        //Fluttertoast.showToast(msg: "Login Successful");
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
          errorMessage = "Check Your Internet Access.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  editProfile(
      String? uid, String? imageUrl, UserModel userModel, BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    isLoading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('table-user-client').doc(uid).update({
        "fullName": userModel.fullName,
        "address": userModel.address,
        "contactNumber": userModel.contactNumber,
        "imageUrl": imageUrl,
      }).then((_) async {
        //This function will update the table book
        // with field image URL to User Client

        await FirebaseFirestore.instance
            .collection("table-book")
            .where("userModel.uid", isEqualTo: uid)
            .get()
            .then((result) {
          result.docs.forEach((result) {
            print(result.id);

            FirebaseFirestore.instance.collection('table-book').doc(result.id).update({
              "userModel.imageUrl": imageUrl,
            }).whenComplete(() {
              isLoading = false;
              notifyListeners();

              //Fluttertoast.showToast(msg: "Image Save");
            });
          });
        });

        print("success!");
      });
    } on FirebaseException catch (error) {
      // print(error);
      Fluttertoast.showToast(msg: "Something went wrong !!!");
    }

    CherryToast.success(
      title: 'Geek Doctor',
      displayTitle: true,
      autoDismiss: true,
      description: 'Successfully Save Changes !!!',
      animationType: ANIMATION_TYPE.fromTop,
      actionStyle: TextStyle(color: Colors.green),
      animationDuration: Duration(milliseconds: 500),
      action: '',
      actionHandler: () {},
    ).show(context);
  }

  uploadImage(String? uid, String? fileName, String? imageUrl, File? imageFile,
      BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    isLoading = true;
    notifyListeners();
    try {
      Reference ref = storage.ref().child(fileName!);

      UploadTask? uploadTask = ref.putFile(imageFile!);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.collection('table-user-client').doc(uid).update({
        "imageUrl": imageUrl,
      }).then((_) async {
        //This function will update the table book
        // with field image URL to User Client

        await FirebaseFirestore.instance
            .collection("table-book")
            .where("userModel.uid", isEqualTo: uid)
            .get()
            .then((result) {
          result.docs.forEach((result) {
            print(result.id);

            FirebaseFirestore.instance.collection('table-book').doc(result.id).update({
              "userModel.imageUrl": imageUrl,
            }).whenComplete(() {
              isLoading = false;
              notifyListeners();
            });
          });
        });

        print("success!");
      });
    } on FirebaseException catch (error) {
      // print(error);
      Fluttertoast.showToast(msg: "Something went wrong !!!");
    }

    CherryToast.success(
      title: 'Geek Doctor',
      displayTitle: true,
      autoDismiss: true,
      description: 'Image Save !!!',
      animationType: ANIMATION_TYPE.fromTop,
      actionStyle: TextStyle(color: Colors.green),
      animationDuration: Duration(milliseconds: 500),
      action: '',
      actionHandler: () {},
    ).show(context);
  }

  //This is for Book Function Provider

  void setDisplayDate(DateTime? selectedDate) {
    _selectedDate = selectedDate;
    notifyListeners();
  }

  String get getDisplayDate => DateFormat.yMMMMd().format(_selectedDate!);
  //DateFormat.yMd().format(_selectedDate!);

  void setDisplayStartTime(String? startTime) {
    _startTime = startTime;
    notifyListeners();
  }

  String get getDisplayStartTime => _startTime!;

  void setDisplayEndTime(String? endTime) {
    _endTime = endTime;
    notifyListeners();
  }

  String get getDisplayEndTime => _endTime!;

  @override
  void disposeValues() {
    isLoading = false;
  }
}

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      backgroundColor: Colors.orange,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                width: 6.0,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(
                width: 26.0,
              ),
              Text(
                message,
                style: TextStyle(color: Colors.black, fontSize: 10.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
