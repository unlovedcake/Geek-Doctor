import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/Bokk-A-Geek/Book-A-Geek.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/src/provider.dart';
import 'package:geekdoctor/string_extension.dart';

class UserServiceProfilePage extends StatefulWidget {
  const UserServiceProfilePage({Key? key}) : super(key: key);

  @override
  _UserServiceProfilePageState createState() => _UserServiceProfilePageState();
}

class _UserServiceProfilePageState extends State<UserServiceProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName;
  String? imageUrl;

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select a Photo From'),
            // content: TextField(
            //   controller: _textFieldController,
            //   textInputAction: TextInputAction.go,
            //   keyboardType: TextInputType.numberWithOptions(),
            //   decoration: InputDecoration(hintText: "Select a Photo From"),
            // ),
            actions: <Widget>[
              new OutlinedButton(
                child: new Text('Gallery'),
                onPressed: () {
                  _upload('Gallery');
                  Navigator.pop(context);
                },
              ),
              new OutlinedButton(
                child: new Text('Camera'),
                onPressed: () {
                  _upload('camera');
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    PickedFile? pickedImage;

    try {
      pickedImage = await picker.getImage(
          source: inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1920);

      setState(() {
        fileName = path.basename(pickedImage!.path);
        imageFile = File(pickedImage.path);
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Profile", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-user-service")
              .where('email', isEqualTo: user!.email)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            final currentUser = snapshot.data?.docs;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: const CircularProgressIndicator(
                color: Colors.orange,
              ));
            }
            return SingleChildScrollView(
                child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 1.8,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 200,
                                height: 200,
                                child: imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(75.0),
                                        child: Image.file(
                                          imageFile!,
                                          fit: BoxFit.cover,
                                          height: 200,
                                        ),
                                      )
                                    : Hero(
                                        tag: "tag1",
                                        child: CachedNetworkImage(
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          imageUrl: currentUser![0]['imageUrl'],
                                          imageBuilder: (context, imageProvider) =>
                                              Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.all(Radius.circular(80)),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
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
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: IconButton(
                                      onPressed: () {
                                        _displayDialog(context);
                                        //_upload("Gallery");
                                      },
                                      icon: Icon(
                                        Icons.add_box_rounded,
                                        color: Colors.orange,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            child: imageFile != null
                                ? OutlinedButton(
                                    child: Text(
                                      'Save Image',
                                    ),
                                    style: TextButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    onPressed: () async {
                                      context.read<BookAGeekProvider>().uploadImage(
                                          currentUser![0]['uid'],
                                          fileName,
                                          imageUrl,
                                          imageFile,
                                          context);
                                    },
                                  )
                                : null)
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    textField(
                      "${currentUser![0]['fullName']}",
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.orange,
                      ),
                    ),

                    SizedBox(
                      height: 15.0,
                    ),
                    textField("${currentUser[0]['email']}",
                        icon: Icon(Icons.email, color: Colors.blue)),

                    SizedBox(
                      height: 15.0,
                    ),
                    textField("${currentUser[0]['address']}",
                        icon: Icon(Icons.add_location, color: Colors.red)),

                    SizedBox(
                      height: 15.0,
                    ),

                    textField("${currentUser[0]['contactNumber']}",
                        icon: Icon(Icons.phone, color: Colors.black)),

                    SizedBox(
                      height: 15.0,
                    ),

                    textField(
                        "${currentUser[0]['skills']['expertise1'].toString().capitalize()}",
                        icon: Icon(Icons.accessibility_sharp, color: Colors.yellow)),
                    // Divider(
                    //   thickness: 2,
                    // ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade500,
                          offset: Offset(2, 2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        // BoxShadow(
                        //   color: Colors.orangeAccent,
                        //   offset: Offset(-2, -2),
                        //   blurRadius: 10,
                        //   spreadRadius: 1,
                        // ),
                      ]),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white, // background
                    ),
                    child: Text(
                      'Go To Edit',
                      style: GoogleFonts.acme(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/user-service-edit-profile-page');
                    },
                  ),
                ),
              ],
            ));
          }),
    );
  }

  Widget textField(String value, {required Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Column(
        children: [
          SizedBox(
            height: 4.0,
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                // textAlign: TextAlign.center,
                initialValue: value,
                enabled: false,
                readOnly: true,
                autofocus: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(50, 15, 50, 15),
                  prefixIcon: icon,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 0),
                  ),
                ),
              )),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
        ],
      ),
    );
  }

  final Widget textFormField = Padding(
    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10.0),
          alignment: Alignment.topLeft,
          child: Text(
            "adasd",
            style: TextStyle(
                fontSize: 16.0, color: Colors.blueGrey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                // readOnly: widget == null ? false : true,
                readOnly: true,
                autofocus: false,
                cursorColor: Colors.grey,

                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 4.0,
        ),
      ],
    ),
  );
}
