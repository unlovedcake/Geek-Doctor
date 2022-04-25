import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ChatControllerProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String? userServiceUID;
  String? userClientUID;

  bool isLoading = false;
  double progress = 0;
  String? download = "Downloading...";

  bool? hasInternet;

  setDownload(String? downLoad) {
    download = downLoad!;
    notifyListeners();
  }

  String get getDownload => download!;

  setProgress(double prog) {
    progress = prog;
    notifyListeners();
  }

  double get getProgress => progress;

  setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  bool get getLoading => isLoading;

  setUserServiceID(String? _id) {
    userServiceUID = _id;
    notifyListeners();
  }

  setUserClientID(String? _id) {
    userClientUID = _id;
    notifyListeners();
  }

  String get userServiceId => userServiceUID!;
  String get userClientId => userClientUID!;

  Stream<QuerySnapshot> chatToUserClient() {
    return FirebaseFirestore.instance
        .collection("table-book")
        .where('id', isEqualTo: userClientUID)
        .snapshots();
  }

  Stream<QuerySnapshot> chatToUserService() {
    return FirebaseFirestore.instance
        .collection("table-book")
        .where('id', isEqualTo: userServiceUID)
        .snapshots();
  }

  String? chatId;

  setChatId(String? _chatId) {
    chatId = _chatId;
    notifyListeners();
  }

  String get getChatId => chatId!;

  checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.kindacode.com');
      if (response.isNotEmpty) {
        hasInternet = true;
      }
    } on SocketException catch (err) {
      print("No Internet Connection");
      hasInternet = false;
    }
    notifyListeners();
  }

  bool get isConnected => hasInternet!;
}
