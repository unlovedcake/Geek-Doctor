import 'dart:io';

class InternetConnection {
  static Future<bool?> checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.kindacode.com');
      if (response.isNotEmpty) {
        return true;
      }
    } on SocketException catch (err) {
      //print("No Internet Connection");
      return false;

      //print(err);
    }
  }
}
