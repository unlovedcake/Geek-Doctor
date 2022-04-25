import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class UserClientProfilePage extends StatefulWidget {
  const UserClientProfilePage({Key? key}) : super(key: key);

  @override
  _UserClientProfilePageState createState() => _UserClientProfilePageState();
}

class _UserClientProfilePageState extends State<UserClientProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName;
  String? imageUrl;
  UploadTask? tasks;

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

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return null;
    final paths = result.files.single.path!;

    setState(() => imageFile = File(paths));
  }

  Future uploadFileVideo() async {
    if (imageFile == null) return;
    final fileName = path.basename(imageFile!.path);
    final destination = 'files/$fileName';

    try {
      Reference ref = storage.ref().child(destination);
      tasks = ref.putFile(imageFile!);

      setState(() {});

      if (tasks == null) return;

      final snapShot = await tasks!.whenComplete(() async {
        //     imageUrl = await ref.getDownloadURL();
      });
      uploadFileVideoBytes();
      imageUrl = await snapShot.ref.getDownloadURL();
      print('Download URL: $imageUrl');
    } on FirebaseException catch (e) {
      return null;
    }
  }

  Future uploadFileVideoBytes() async {
    Uint8List? data;
    if (imageFile == null) return;
    final fileName = path.basename(imageFile!.path);
    final destination = 'files/$fileName';

    try {
      Reference ref = storage.ref().child(destination);
      tasks = ref.putData(data!);
    } on FirebaseException catch (e) {
      return null;
    }
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fileNameSelected =
        imageFile != null ? path.basename(imageFile!.path) : "No File Selected";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Profile", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(index: 1),
      body: StreamBuilder(
          //stream: context.watch<ControllerClientProvider>().editUserClientDetails(),

          stream: FirebaseFirestore.instance
              .collection("table-user-client")
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
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          imageUrl: currentUser![0]['imageUrl'],
                                          imageBuilder: (context, imageProvider) =>
                                              Container(
                                            height: 100,
                                            width: 100,
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
                                  scale: 1.7,
                                  child: IconButton(
                                      color: Colors.orange,
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
                                    child: context
                                                .watch<ControllerClientProvider>()
                                                .loading ==
                                            true
                                        ? Container(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: Colors.orange,
                                            ),
                                          )
                                        : Text(
                                            'Save Image',
                                          ),
                                    style: TextButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    onPressed: () async {
                                      context
                                          .read<ControllerClientProvider>()
                                          .uploadImage(currentUser![0]['uid'], fileName,
                                              imageUrl, imageFile, context);
                                    },
                                  )
                                : null)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Column(
                  children: [
                    textField("${currentUser![0]['fullName']}",
                        icon: Icon(
                          Icons.account_circle,
                          color: Colors.orange,
                        )),

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
                    child: Text(
                      'Go To Edit',
                      style: GoogleFonts.acme(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/user-client-edit-profile-page');
                    },
                  ),
                )
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

  Widget buildUploadStatus(UploadTask? task) => StreamBuilder<TaskSnapshot>(
        stream: task!.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Text("$percentage %");
          } else {
            return Container();
          }
        },
      );
}
