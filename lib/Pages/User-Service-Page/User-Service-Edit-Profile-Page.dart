import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UserServiceEditProfilePage extends StatefulWidget {
  const UserServiceEditProfilePage({Key? key}) : super(key: key);

  @override
  _UserServiceEditProfilePageState createState() => _UserServiceEditProfilePageState();
}

class _UserServiceEditProfilePageState extends State<UserServiceEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _addressText = TextEditingController();
  final TextEditingController _contactText = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName = "image.jpg";
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          if (snapshot.data?.docs == 0) {
            return const Text("No Data Found");
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.orange),
              centerTitle: true,
              title: Text("Edit Profile", style: TextStyle(color: Colors.orange)),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
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
                                        tag: 'profileImage',
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
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nameText..text = currentUser![0]['fullName'],
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          cursorColor: Colors.orange,
                          //initialValue: "Okey",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Name is required ");
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.orange,
                            ),
                            hintText: "Name",
                            suffixIcon: Icon(Icons.done),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextFormField(
                          controller: _addressText..text = currentUser[0]['address'],
                          keyboardType: TextInputType.streetAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: Colors.orange,
                          //initialValue: currentUser[0]['fullName'],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Address is required");
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.add_location,
                              color: Colors.red,
                            ),
                            hintText: "Address",
                            suffixIcon: Icon(Icons.done),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextFormField(
                          controller: _contactText
                            ..text = currentUser[0]['contactNumber'],
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.orange,
                          //initialValue: currentUser[0]['fullName'],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Contact is required");
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.blue,
                            ),
                            hintText: "Contact Number",
                            suffixIcon: Icon(Icons.done),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.0,
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
                      ]),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white, // background
                      // foreground
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.acme(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        UserServiceProviderModel userServiceModel =
                            UserServiceProviderModel();
                        userServiceModel.fullName = _nameText.text;
                        userServiceModel.contactNumber = _contactText.text;
                        userServiceModel.address = _addressText.text;

                        try {
                          if (fileName == "image.jpg") {
                            print("defualt image");
                          } else {
                            Reference ref = storage.ref().child(fileName!);

                            UploadTask? uploadTask = ref.putFile(imageFile!);

                            await uploadTask.whenComplete(() async {
                              imageUrl = await ref.getDownloadURL();
                            });
                          }

                          await FirebaseFirestore.instance
                              .collection('table-user-service')
                              .doc(currentUser[0]['uid'])
                              .update({
                            "fullName": userServiceModel.fullName,
                            "contactNumber": userServiceModel.contactNumber,
                            "address": userServiceModel.address,
                            "imageUrl":
                                imageUrl == null ? currentUser[0]['imageUrl'] : imageUrl,
                          }).then((_) async {
                            //This function will update the table book
                            // with field image URL to User Service Provider
                            CherryToast.success(
                              title: 'Geek Doctor',
                              displayTitle: true,
                              autoDismiss: true,
                              description: 'Successfully Save Changes !!!',
                              animationType: ANIMATION_TYPE.fromRight,
                              actionStyle: TextStyle(color: Colors.green),
                              animationDuration: Duration(milliseconds: 1000),
                              action: '',
                              actionHandler: () {},
                            ).show(context);

                            await FirebaseFirestore.instance
                                .collection("table-book")
                                .where("userServiceModel.uid",
                                    isEqualTo: currentUser[0]['uid'])
                                .get()
                                .then((result) {
                              result.docs.forEach((result) {
                                print(result.id);

                                FirebaseFirestore.instance
                                    .collection('table-book')
                                    .doc(result.id)
                                    .update({
                                  "userServiceModel.imageUrl": imageUrl == null
                                      ? currentUser[0]['imageUrl']
                                      : imageUrl,
                                }).then((_) {
                                  //Fluttertoast.showToast(msg: "Image Save");
                                });
                              });
                            });

                            print("success!");
                            Fluttertoast.showToast(msg: "Success ");
                          });
                        } on FirebaseException catch (error) {
                          print("${imageFile}" + "adsadsadada");

                          // print(error);
                          //print(downloadUrl + "adasdadasdsadas");
                        }
                      }
                    },
                  ),
                )
              ],
            )),
          );
        });
  }
}
