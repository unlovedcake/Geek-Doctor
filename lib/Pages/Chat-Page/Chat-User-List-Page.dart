import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ChatUserListPage extends StatefulWidget {
  const ChatUserListPage({Key? key}) : super(key: key);

  @override
  _ChatUserListPageState createState() => _ChatUserListPageState();
}

class _ChatUserListPageState extends State<ChatUserListPage> {
  User? user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName;
  String? imageUrl;
  UploadTask? tasks;

  final messageTextController = TextEditingController();
  String? messageText;
  bool? isLoading;
  String? nickname;

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
    _displayDialog(context);
  }

  uploadImage(String content, int type) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      Reference ref = storage.ref().child(fileName!);

      UploadTask? uploadTask = ref.putFile(imageFile!);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.collection('table-messages').add({
        'sender': nickname,
        'text': content,
        'id': user!.uid,
        'timestamp': DateTime.now().toString(),
        'type': type
      }).then((_) {
        print("success!");
        Fluttertoast.showToast(msg: "Image Save");
      });
    } on FirebaseException catch (error) {
      // print(error);
      //print(downloadUrl + "adasdadasdsadas");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.people,
              ),
              onPressed: () {
                //         Navigator
                //         .pushNamed(context, OnlineScreen.id),
                // }
              }),
        ],
        title: Row(
          children: <Widget>[
            // Image.asset(
            //   'images/booking.png',
            // ),
            Text('️Chat')
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 2.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: new EdgeInsets.symmetric(horizontal: 1.0),
                  child: new IconButton(
                      icon: new Icon(Icons.image, color: Colors.blue),
                      onPressed: () {
                        _upload('Gallery');
                      }),
                ),
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    onChanged: (value) {
                      //Do something with the user input.
                      messageText = value;
                    },
                    // decoration: kMessageTextFieldDecoration.copyWith(
                    //   hintText: 'Type your message here...',
                    //   hintStyle: TextStyle(color : Colors.grey),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    messageTextController.clear();

                    //Implement send functionality.
                    //messageText + sender
                    //onSendMessage(messageText,0);
                  },
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
