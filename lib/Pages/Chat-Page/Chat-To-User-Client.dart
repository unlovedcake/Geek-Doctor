import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/Chat-Page/View-Send-Image-Service.dart';
import 'package:geekdoctor/Pages/User-Service-Page/View-Profile-User-Client.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/src/provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:stacked/stacked.dart';
import '../../constant.dart';
import '../../stackvideomodel.dart';
import '../../utils.dart';
import '../../video-player.widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';

class ChatToUserClientPage extends StatefulWidget {
  final BookModel clientInfo;

  const ChatToUserClientPage({required this.clientInfo});

  @override
  _ChatToUserClientPageState createState() => _ChatToUserClientPageState();
}

class _ChatToUserClientPageState extends State<ChatToUserClientPage> {
  User? user = FirebaseAuth.instance.currentUser;
  BookModel loggedInUser = BookModel();

  final _formKey = GlobalKey<FormState>();
  FocusNode _focusNode = FocusNode();
  Map<String, PreviewData> datas = {};

  final TextEditingController _serviceNeedText = TextEditingController(text: " ");

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName;
  String? imageUrl;
  UploadTask? tasks;
  String? ids;
  String? userClientImage;

  final messageTextController = TextEditingController();
  String? messageText;
  bool? isLoading;
  String? nickname;
  var fileVideo;

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    PickedFile? pickedImage;

    // Pick a video
    final ImagePicker _picker = ImagePicker();

    try {
      if (inputSource == "fileVideo") {
        fileVideo = await _picker.getVideo(source: ImageSource.gallery);

        fileName = path.basename(fileVideo!.path);
        imageFile = File(fileVideo.path);
      } else {
        pickedImage = await picker.getImage(
            source: inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
            maxWidth: 1920);

        setState(() {
          fileName = path.basename(pickedImage!.path);
          imageFile = File(pickedImage.path);
        });
      }
      uploadImage();
    } catch (e) {}
  }

  uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      Reference ref = storage.ref().child(fileName!);

      UploadTask? uploadTask = ref.putFile(imageFile!);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });
      setState(() {});
      if (fileVideo == null) {
        onSendMessage(imageUrl!, 1, "emoji-default.jpg");
      } else {
        onSendMessage(imageUrl!, 0, "emoji-default.jpg");
      }
    } on FirebaseException catch (error) {
      print(error);
      return null;
    }
  }

  void onSendMessage(String? content, int? type, String emoji) async {
    await FirebaseFirestore.instance
        .collection('table-chat')
        .doc(Provider.of<ChatControllerProvider>(context, listen: false).userClientId)
        .set({
      'sender': user!.email,
      'id': user!.uid,
    }).then((value) {
      FirebaseFirestore.instance
          .collection("table-chat")
          .doc(Provider.of<ChatControllerProvider>(context, listen: false).userClientId)
          .collection("messages")
          .add({
        'sender': user!.email,
        'text': content,
        "type": type,
        "emoji": emoji,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
    });
  }

  bool _isLink(String input) {
    final matcher = new RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }

  bool _isLinkVideo(String input) {
    return input.contains("mp4");
  }

  List listUsers = [];
  String getTokenId = "";
  UserModel loggedInUserClient = UserModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("table-user-client")
        .where("email", isEqualTo: widget.clientInfo.userModel!['email'].toString())
        .get()
        .then((value) {
      getTokenId = value.docs.first.get('tokenId');

      setState(() {});
    });
  }

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  String? percentage;
  String? download;
  String? urlVideo;

  _saveVideo(String url) async {
    setState(() {
      loading = true;
      percentage = "0";
      download = "";
    });

    var status = await Permission.storage.request();
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";

    if (_isLinkVideo(url)) {
      savePath = appDocDir.path + "/temp.mp4";
    } else {
      savePath = appDocDir.path + "/temp.png";
    }

    if (status.isGranted) {
      await Dio().download(url, savePath, onReceiveProgress: (count, total) {
        progress = (count / total);
        print((count / total * 100).toStringAsFixed(0) + "%");

        percentage = (count / total * 100).toStringAsFixed(0) + "%";
        context.read<ChatControllerProvider>().setProgress(progress);

        if (percentage == "100%") {
          loading = false;
          download = "Download Completed";
          context.read<ChatControllerProvider>().setLoading(false);
          context.read<ChatControllerProvider>().setDownload(download!);
        } else {
          loading = true;
          download = "Downloading...";
          context.read<ChatControllerProvider>().setDownload(download!);
        }
      });
      final result = await ImageGallerySaver.saveFile(savePath, name: "Geek");

      if (result['isSuccess'] == true && _isLinkVideo(url)) {
        print("Save To Videos Folder");
        Fluttertoast.showToast(msg: "Save To Videos Folder");
      } else {
        Fluttertoast.showToast(msg: "Save To Images Folder");
        print("Save To Images Folder");
      }
    }
  }

  Future<Response> sendNotification(
      List<String> tokenIdList, String contents, String heading) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id":
            keyAppID, //kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids":
            tokenIdList, //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color": "FF9800FF",
        //"iosAttachments": {"id1": widget.serviceInfo.userServiceModel!['imageUrl']},
        "small_icon": "ic_stat_onesignal_default",
        "large_icon": widget.clientInfo.userModel!['imageUrl'],

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("table-user-client")
                .where("email",
                    isEqualTo: widget.clientInfo.userModel!['email'].toString())
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center();
              String status = "Offline";

              status = snapshot.data!.docs.first.get('status');

              return Wrap(
                alignment: WrapAlignment.start,
                direction: Axis.horizontal,
                children: [
                  Hero(
                    tag: "tag",
                    child: ClipOval(
                      child: Image.network(
                        widget.clientInfo.userModel!['imageUrl'].toString(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.clientInfo.userModel!['fullName'].toString(),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        Text(
                          status,
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.orange, // background
            ),
            onPressed: () {
              _focusNode.unfocus();
              _focusNode.canRequestFocus = false;
              context
                  .read<ControllerClientProvider>()
                  .setUserClientEmail(widget.clientInfo.userModel!['email'].toString());

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ViewProfileUserClient(),
                  ));
              _focusNode.canRequestFocus = true;
            },
            child: Text('View Profile'),
          )
        ],
        iconTheme: IconThemeData(color: Colors.orange),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("table-chat")
                  .doc(Provider.of<ChatControllerProvider>(context, listen: false)
                      .userClientId)
                  .collection("messages")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        final userService = snapshot.data!.docs[index];

                        final DocumentSnapshot bookingData = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: bookingData['type'] == 0
                              ? Wrap(
                                  alignment: bookingData['sender'] == user!.email
                                      ? WrapAlignment.end
                                      : WrapAlignment.start,
                                  children: [
                                    bookingData['sender'] != user!.email
                                        ? Padding(
                                            padding: const EdgeInsets.only(right: 4),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        widget.clientInfo
                                                            .userModel!['imageUrl']
                                                            .toString(),
                                                      ),
                                                      fit: BoxFit.cover)),
                                            ),
                                          )
                                        : Container(),
                                    Column(
                                      crossAxisAlignment:
                                          bookingData['sender'] == user!.email
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        _isLink(bookingData['text']) != true
                                            ? OutlinedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(20)),
                                                  primary:
                                                      bookingData['sender'] == user!.email
                                                          ? Colors.black
                                                          : Colors.orange, // background
                                                  onPrimary:
                                                      Colors.blueGrey, // foreground
                                                ),
                                                onLongPress: () {
                                                  Clipboard.setData(new ClipboardData(
                                                      text: bookingData['text']));
                                                  Fluttertoast.showToast(msg: "Copied");
                                                },
                                                onPressed: () {
                                                  showModalBottom(bookingData.id);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      0, 6, 2, 6),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      bookingData['text'],
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal,
                                                          color: bookingData['sender'] ==
                                                                  user!.email
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : _isLinkVideo(bookingData['text']) != true
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Stack(
                                                        alignment: Alignment.bottomRight,
                                                        children: [
                                                          OutlinedButton(
                                                            child: LinkPreview(
                                                              enableAnimation: true,
                                                              onPreviewDataFetched:
                                                                  (data) {
                                                                setState(() {
                                                                  datas = {
                                                                    ...datas,
                                                                    bookingData['text']:
                                                                        data,
                                                                  };
                                                                });
                                                              },
                                                              previewData: datas[
                                                                  bookingData['text']],
                                                              text: bookingData['text'],
                                                              width:
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width,
                                                            ),
                                                            onPressed: () {
                                                              showModalBottom(
                                                                  bookingData.id);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      ViewModelBuilder<
                                                          StackedVideoViewModel>.reactive(
                                                        viewModelBuilder: () =>
                                                            StackedVideoViewModel(),
                                                        onModelReady: (model) {
                                                          model.initialize(
                                                              bookingData['text']);
                                                        },
                                                        builder: (context, model, child) {
                                                          return VideoPlayerWidget(
                                                              controller: model
                                                                  .videoPlayerController!);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                        Row(
                                          mainAxisAlignment:
                                              bookingData['sender'] == user!.email
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment:
                                                  bookingData['sender'] == user!.email
                                                      ? Alignment(0.6, 0.6)
                                                      : FractionalOffset(0.3, 0.3),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 3),
                                                child: Text(
                                                  readTimestamp(bookingData['timestamp']),
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                                  bookingData['sender'] == user!.email
                                                      ? Alignment(0.6, 0.6)
                                                      : FractionalOffset(0.3, 0.3),
                                              child: ClipOval(
                                                child: IconButton(
                                                  icon:
                                                      bookingData['sender'] != user!.email
                                                          ? Image.asset('images/'
                                                              '${bookingData['emoji']}')
                                                          : Image.asset('images/'
                                                              '${bookingData['emoji']}'),
                                                  onPressed: () {
                                                    urlVideo = bookingData['text'];
                                                    showModalBottom(bookingData.id);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: bookingData['sender'] == user!.email
                                          ? WrapAlignment.end
                                          : WrapAlignment.start,
                                      children: [
                                        bookingData['sender'] != user!.email
                                            ? Padding(
                                                padding: const EdgeInsets.only(right: 4),
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                            widget.clientInfo
                                                                .userModel!['imageUrl']
                                                                .toString(),
                                                          ),
                                                          fit: BoxFit.cover)),
                                                ),
                                              )
                                            : Container(),
                                        GestureDetector(
                                          child: Hero(
                                            tag: bookingData['text'],
                                            child: Container(
                                              width: 200,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          bookingData['text']),
                                                      fit: BoxFit.cover)),
                                            ),
                                          ),
                                          onTap: () {
                                            _focusNode.unfocus();
                                            _focusNode.canRequestFocus = false;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewSendImageService(
                                                        imageUrl: bookingData['text'],
                                                        messageId: bookingData.id,
                                                      )),
                                            );
                                            _focusNode.canRequestFocus = true;
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),

                                    //This is send Image To Client
                                    Row(
                                      mainAxisAlignment:
                                          bookingData['sender'] == user!.email
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: bookingData['sender'] == user!.email
                                              ? Alignment(0.6, 0.6)
                                              : FractionalOffset(0.3, 0.3),
                                          //alignment: FractionalOffset(0.2, 02),
                                          child: Text(
                                            readTimestamp(bookingData['timestamp']),
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                        Align(
                                          alignment: bookingData['sender'] == user!.email
                                              ? Alignment(0.6, 0.6)
                                              : FractionalOffset(0.3, 0.3),
                                          child: ClipOval(
                                            child: IconButton(
                                              icon: bookingData['sender'] != user!.email
                                                  ? Image.asset('images/'
                                                      '${bookingData['emoji']}')
                                                  : Image.asset('images/'
                                                      '${bookingData['emoji']}'),
                                              onPressed: () {
                                                urlVideo = bookingData['text'];
                                                showModalBottom(bookingData.id);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        );
                      });
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  ));
                }
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 120,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: new IconButton(
                      icon: new Icon(Icons.image, color: Colors.orange),
                      onPressed: () {
                        //_upload('Gallery');

                        _displayDialog(context);
                      }),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Container(
                    height: 120,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        focusNode: _focusNode,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.blueGrey,
                          border: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide.none,

                            //borderSide: const BorderSide(),
                          ),
                        ),
                        //keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: null,
                        controller: messageTextController,
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 120,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      //Implement send functionality.
                      //messageText + sender
                      onSendMessage(messageText!, 0, "emoji-default.jpg");
                      sendNotification([getTokenId], messageTextController.text,
                          "${widget.clientInfo.userServiceModel!['fullName'].toString()}");
                      messageTextController.clear();

                      print(getTokenId);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  showModalBottom(String? bookingDataId) {
    showModalBottomSheet(
      context: context,

      // color is applied to main screen when modal bottom screen is displayed

      //background color for modal bottom screen
      backgroundColor: Colors.white,
      //elevates modal bottom screen
      elevation: 10,
      // gives rounded corner to modal bottom screen
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(12),
          height: 150,
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-heart.gif'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-heart.gif");
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-like.gif'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-like.gif");
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-smile.gif'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-smile.gif");
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-laugh.gif'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-laugh.gif");
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-bleh.gif'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-bleh.gif");
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Image.asset('images/emoji-sad.gif'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      emoji(bookingDataId!, "emoji-sad.gif");
                    },
                  ),
                  Provider.of<ChatControllerProvider>(context, listen: false).getLoading
                      ? Container(
                          width: 300,
                          child: Column(
                            children: [
                              //Text(context.watch<ChatControllerProvider>().getDownload),
                              Text("$download $percentage"),
                              LinearProgressIndicator(
                                  minHeight: 5,
                                  //value: progress),
                                  value: context
                                      .watch<ChatControllerProvider>()
                                      .getProgress),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.download,
                      color: Colors.blue,
                      size: 40,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();

                      print("Progress: $progress");

                      _saveVideo(urlVideo!);
                      context.read<ChatControllerProvider>().setLoading(true);
                      showModalBottom(bookingDataId);
                    },
                  ),
                  GestureDetector(
                    child: Icon(
                      CupertinoIcons.trash_circle,
                      size: 40,
                      color: Colors.red,
                    ),
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('table-chat')
                          .doc(
                              "${Provider.of<ChatControllerProvider>(context, listen: false).userClientId}")
                          .collection('messages')
                          .doc(bookingDataId)
                          .delete()
                          .then((_) {
                        print("success!");
                      });

                      Navigator.of(context).pop();
                      print("OKE");
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  emoji(String? bokingID, String? emoji) async {
    await FirebaseFirestore.instance
        .collection('table-chat')
        .doc(
            "${Provider.of<ChatControllerProvider>(context, listen: false).userClientId}")
        .collection('messages')
        .doc(bokingID)
        .update({
      "emoji": emoji,
    }).then((_) {
      print("success!");
    });
  }

  _displayDialog(BuildContext context) async {
    return showModal(
        configuration: FadeScaleTransitionConfiguration(
          transitionDuration: Duration(seconds: 2),
          reverseTransitionDuration: Duration(seconds: 2),
        ),
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            title: Text('Select a Photo From'),
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
              ),
              new OutlinedButton(
                child: new Text('Video'),
                onPressed: () {
                  _upload('fileVideo');
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
