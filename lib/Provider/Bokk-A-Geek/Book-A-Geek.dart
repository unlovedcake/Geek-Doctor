import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/clean_calendar_event.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Abstract/Disposal-Value-Provider.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class BookAGeekProvider extends DisposableProvider {
  bool _isLoading = false;

  bool isRateStar = false;
  bool rateFce = false;
  Icon? iconFace;
  double initialRating = 0.0;

  String startTime = DateFormat.jm().format(DateTime.now());
  String endTime = DateFormat.jm().format(DateTime.now());

  String? id;

  List<CleanCalendarEvent> _selectedEvents = [];
  setCalendarDate(List<CleanCalendarEvent> date) {
    _selectedEvents = date;
    notifyListeners();
  }

  List<CleanCalendarEvent> get getCalendarDate => _selectedEvents;

  String selectedDate = "";

  bool get loading => isLoading;

  setSelectedDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  String get getSelectedDate => selectedDate;

  setSelectedStartTime(String _startTime) {
    startTime = _startTime;
    notifyListeners();
  }

  String get getSelectedStartTime => startTime;

  setSelectedEndTime(String _endTime) {
    endTime = _endTime;
    notifyListeners();
  }

  String get getSelectedEndTime => endTime;

  setInitialRating(double initial) {
    initialRating = initial;
    notifyListeners();
  }

  double get getInitialRating => initialRating;

  setIconFace(Icon icon) {
    iconFace = icon;
    notifyListeners();
  }

  Icon get getIconFace => iconFace!;

  setRateFace(bool rate) {
    rateFce = rate;
    notifyListeners();
  }

  bool get getRateFace => rateFce;

  setRateStar(bool rate) {
    isRateStar = rate;
    notifyListeners();
  }

  bool get getRateStar => isRateStar;

  setBookingID(String? _id) {
    id = _id;
    notifyListeners();
  }

  Stream<QuerySnapshot> getBooking() {
    return FirebaseFirestore.instance
        .collection("table-book")
        .where('id', isEqualTo: id)
        .snapshots();
  }

  String get bookId => id!;

  bookingAdd(BookModel bookModel, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    String? id = Uuid().v4();

    await FirebaseFirestore.instance.collection("table-book").add({
      'id': id,
      'serviceNeed': bookModel.serviceNeed,
      'dateToBook': bookModel.dateToBook,
      'startTime': bookModel.startTime,
      'endTime': bookModel.endTime,
      'status': bookModel.status,
      'dateCreated': DateTime.now(),
      'userModel': bookModel.userModel,
      'userServiceModel': bookModel.userServiceModel,
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();

      print("Success!");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Something went wrong !!! ");
      print("Error!");
    });

    CherryToast.success(
      title: 'Geek Doctor',
      displayTitle: false,
      autoDismiss: true,
      description: 'Booking created successfully !!!',
      animationType: ANIMATION_TYPE.fromTop,
      actionStyle: TextStyle(color: Colors.green),
      animationDuration: Duration(milliseconds: 1000),
      action: '',
      actionHandler: () {},
    ).show(context);
  }

  bookingUpdate(BookModel bookModel, String? id) async {
    await FirebaseFirestore.instance.collection("table-book").doc(id!).update({
      'serviceNeed': bookModel.serviceNeed,
      'dateToBook': bookModel.dateToBook,
      'startTime': bookModel.startTime,
      'endTime': bookModel.endTime,
    }).then((result) {
      notifyListeners();
      Fluttertoast.showToast(msg: "Edit successfully change ");
      print("Success!");
    }).catchError((error) {
      print("Error!");
    });
  }

  bool get isLoading => _isLoading;

  Stream<QuerySnapshot> bookingList() {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection("table-book")
        .where('userModel.uid', isEqualTo: user!.uid)
        .orderBy('dateToBook', descending: true)
        .snapshots();
  }

  uploadImage(String? uid, String? fileName, String? imageUrl, File? imageFile,
      BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      Reference ref = storage.ref().child(fileName!);

      UploadTask? uploadTask = ref.putFile(imageFile!);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.collection('table-user-service').doc(uid).update({
        "imageUrl": imageUrl,
      }).then((_) async {
        //This function will update the table book
        // with field image URL to User Service Provider

        CherryToast.success(
          title: 'Geek Doctor',
          displayTitle: true,
          autoDismiss: true,
          description: 'Image Save !!!',
          animationType: ANIMATION_TYPE.fromRight,
          actionStyle: TextStyle(color: Colors.green),
          animationDuration: Duration(milliseconds: 1000),
          action: '',
          actionHandler: () {},
        ).show(context);

        await FirebaseFirestore.instance
            .collection("table-book")
            .where("userServiceModel.uid", isEqualTo: uid)
            .get()
            .then((result) {
          result.docs.forEach((result) {
            print(result.id);

            FirebaseFirestore.instance.collection('table-book').doc(result.id).update({
              "userServiceModel.imageUrl": imageUrl,
            }).then((_) {
              Fluttertoast.showToast(msg: "Image Save");
            });
          });
        });

        print("success!");
      });
    } on FirebaseException catch (error) {
      // print(error);

    }
  }

  @override
  void disposeValues() {
    selectedDate = "";
    isRateStar = false;
    _isLoading = false;
  }
}
