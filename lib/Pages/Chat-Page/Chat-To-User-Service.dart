import 'dart:io';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:geekdoctor/Animation/page-animation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/Chat-Page/View-Send-Image.dart';
import 'package:geekdoctor/Pages/User-Client-Page/View-Profile-User-Service.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/model/book_model.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';
import 'package:path/path.dart' as path;
import '../../Router.dart';
import '../../constant.dart';
import '../../stackvideomodel.dart';
import '../../utils.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:animations/animations.dart';
import '../../video-player.widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'dart:convert';

class ChatToUserService extends StatefulWidget {
  final BookModel serviceInfo;
  const ChatToUserService({required this.serviceInfo});

  @override
  _ChatToUserServiceState createState() => _ChatToUserServiceState();
}

class _ChatToUserServiceState extends State<ChatToUserService> {
  User? user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  FocusNode _focusNode = FocusNode();

  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFile;
  String? fileName;
  String? imageUrl;
  UploadTask? tasks;
  String? ids;

  String? editMessageText;
  String? editMessageID;
  bool isEditMessage = false;

  Map<String, PreviewData> datas = {}; //display url with preview
  //VideoPlayerController? controller;

  final messageTextController = TextEditingController();
  final textController = TextEditingController();
  String? urlVideo;

  String? messageText;
  bool? isUrl = false;
  String? nickname;
  String tokenId = "tokenId";
  String userName = "";

  int rate = 0;

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  String? percentage;
  String? download;

  String? userImage;
  bool isVideo = false;
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
    if (imageFile == null) return;
    final fileName = path.basename(imageFile!.path);

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        Reference ref = storage.ref().child(fileName);

        UploadTask? uploadTask = ref.putFile(imageFile!);

        await uploadTask.whenComplete(() async {
          imageUrl = await ref.getDownloadURL();
        });
        setState(() {});
        if (fileVideo == null) {
          onSendMessage(imageUrl!, 1, "emoji-default.jpg");
        } else {
          onSendMessage(imageUrl!, 0, "emoji-default.jpg");
          sendNotification([getTokenId], messageTextController.text,
              "${widget.serviceInfo.userModel!['fullName'].toString()}");
        }
      } on FirebaseException catch (error) {
        // print(error);
        print("${imageUrl}" + "Save");
      }
    } on FirebaseException catch (e) {
      return null;
    }
  }

  void onSendMessage(String? content, int? type, String? emoji) async {
    await FirebaseFirestore.instance
        .collection('table-chat')
        .doc(Provider.of<ChatControllerProvider>(context, listen: false).userServiceId)
        .set({
      'sender': user!.email,
      'id': user!.uid,
    }).then((value) {
      FirebaseFirestore.instance
          .collection("table-chat")
          .doc(Provider.of<ChatControllerProvider>(context, listen: false).userServiceId)
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

  List<Map<dynamic, dynamic>> listUsers = [];
  String getTokenId = "";
  UserServiceProviderModel loggedInUser = UserServiceProviderModel();
  Map<String, int> results = {};

  List res = [];
  String ratings = "0";
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("table-user-service")
        .where("email",
            isEqualTo: widget.serviceInfo.userServiceModel!['email'].toString())
        .get()
        .then((value) {
      getTokenId = value.docs.first.get('tokenId');

      setState(() {});
    });
  }

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

      print("Save Image To Picture Folder");
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
        "large_icon": widget.serviceInfo.userServiceModel!['imageUrl'],

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
        //centerTitle: true,
        elevation: 0,
        title: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("table-user-service")
                .where("email",
                    isEqualTo: widget.serviceInfo.userServiceModel!['email'].toString())
                .snapshots(),
            builder: (context, snapshot) {
              //var userStatus = snapshot.data!.docs;
              if (!snapshot.hasData) return Center();
              String stat = "Offline";

              stat = snapshot.data!.docs.first.get('status');

              return Wrap(
                alignment: WrapAlignment.start,
                direction: Axis.horizontal,
                children: [
                  Hero(
                    tag: "tag1",
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: stat == "Active"
                                ? Colors.green
                                : stat == "Inactive"
                                    ? Colors.blueGrey
                                    : Colors.grey,
                            width: 3),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.serviceInfo.userServiceModel!['imageUrl'].toString(),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
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
                          widget.serviceInfo.userServiceModel!['fullName'].toString(),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        Text(
                          stat,
                          style: TextStyle(
                              fontSize: 10,
                              color: stat == "Active"
                                  ? Colors.black
                                  : stat == "Inactive"
                                      ? Colors.blueGrey
                                      : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        iconTheme: IconThemeData(color: Colors.orange),
        backgroundColor: Colors.white,
        //leading:
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.orange, // background
              // foreground
            ),
            onPressed: () {
              _focusNode.unfocus();
              _focusNode.canRequestFocus = false;

              context.read<ControllerClientProvider>().setUserServiceEmail(
                  widget.serviceInfo.userServiceModel!['email'].toString());

              Navigator.push(context, BouncyPageRoute(widget: ViewProfileUSerService()));

              _focusNode.canRequestFocus = true;
            },
            child: Text("View Profile"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("table-chat")
                  .doc(Provider.of<ChatControllerProvider>(context, listen: false)
                      .userServiceId)
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
                                        ? Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4, bottom: 2),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(widget
                                                            .serviceInfo
                                                            .userServiceModel!['imageUrl']
                                                            .toString()),
                                                        fit: BoxFit.cover)),
                                              ),
                                            ),
                                          )
                                        : Container(),

                                    //Send Text Message to Service Provider
                                    Column(
                                      crossAxisAlignment:
                                          bookingData['sender'] == user!.email
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        _isLink(bookingData['text']) != true
                                            ? OutlinedButton(
                                                style: ElevatedButton.styleFrom(
                                                  onSurface: Colors.greenAccent,
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

                                                  editMessageID = bookingData.id;
                                                  setState(() {
                                                    editMessageText = bookingData['text'];

                                                    isEditMessage = true;
                                                  });
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

                                                              editMessageID =
                                                                  bookingData.id;
                                                              setState(() {
                                                                editMessageText =
                                                                    bookingData['text'];

                                                                isEditMessage = true;
                                                              });
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
                                                    showModalBottom(bookingData.id);
                                                    editMessageID = bookingData.id;

                                                    urlVideo = bookingData['text'];
                                                    setState(() {
                                                      editMessageText =
                                                          bookingData['text'];

                                                      isEditMessage = true;
                                                    });
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
                                                          image: NetworkImage(widget
                                                              .serviceInfo
                                                              .userServiceModel![
                                                                  'imageUrl']
                                                              .toString()),
                                                          fit: BoxFit.cover)),
                                                ),
                                              )
                                            : Container(),
                                        GestureDetector(
                                          child: Hero(
                                            tag: bookingData['text'],
                                            child: Container(
                                              padding: const EdgeInsets.only(bottom: 0),
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
                                            context
                                                .read<ChatControllerProvider>()
                                                .setChatId(
                                                  Provider.of<ChatControllerProvider>(
                                                          context,
                                                          listen: false)
                                                      .userServiceId,
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ViewSendImage(
                                                        imageUrl: bookingData['text'],
                                                        messageId: bookingData.id,
                                                      )),
                                            );
                                            _focusNode.canRequestFocus = true;
                                            print("OKEY");
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),

                                    //This is a send image to Service Provider

                                    Row(
                                      mainAxisAlignment:
                                          bookingData['sender'] == user!.email
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          //alignment: FractionalOffset(0.2, 02),
                                          alignment: bookingData['sender'] == user!.email
                                              ? Alignment(0.6, 0.6)
                                              : FractionalOffset(0.3, 03),
                                          child: Text(
                                            readTimestamp(bookingData['timestamp']),
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                        Align(
                                          alignment: bookingData['sender'] == user!.email
                                              ? Alignment(0.6, 0.6)
                                              : FractionalOffset(0.3, 03),
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
                    color: Colors.orange,
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
                        //_upload('camera');

                        _displayDialog(context);
                      }),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      height: 120,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          scrollPadding: EdgeInsets.only(bottom: 40),
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
                      if (isEditMessage) {
                        await FirebaseFirestore.instance
                            .collection('table-chat')
                            .doc(
                                "${Provider.of<ChatControllerProvider>(context, listen: false).userServiceId}")
                            .collection('messages')
                            .doc(editMessageID)
                            .update({"text": messageTextController.text}).then((_) {
                          print("success!");
                        });
                      } else {
                        onSendMessage(messageText!, 0, "emoji-default.jpg");
                        sendNotification([getTokenId], messageTextController.text,
                            "${widget.serviceInfo.userModel!['fullName'].toString()}");
                        print(getTokenId);
                      }

                      isEditMessage = false;

                      messageTextController.clear();
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
        return StatefulBuilder(builder: (BuildContext context, StateSetter setstate) {
          return Container(
            padding: EdgeInsets.all(12),
            height: 150,
            child: Column(
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-heart.gif'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-heart.gif");
                        isEditMessage = false;
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-like.gif'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-like.gif");
                        isEditMessage = false;
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-smile.gif'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-smile.gif");
                        isEditMessage = false;
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-laugh.gif'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-laugh.gif");
                        isEditMessage = false;
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-bleh.gif'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-bleh.gif");
                        isEditMessage = false;
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: Image.asset('images/emoji-sad.gif'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        emoji(bookingDataId!, "emoji-sad.gif");
                        isEditMessage = false;
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

                        isEditMessage = false;
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
                        isEditMessage = false;
                        await FirebaseFirestore.instance
                            .collection('table-chat')
                            .doc(
                                "${Provider.of<ChatControllerProvider>(context, listen: false).userServiceId}")
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
                    GestureDetector(
                      child: Icon(
                        CupertinoIcons.check_mark_circled,
                        size: 40,
                        color: Colors.orange,
                      ),
                      onTap: () async {
                        isEditMessage = true;
                        _focusNode.unfocus();
                        _focusNode.canRequestFocus = true;

                        messageTextController.text = editMessageText!;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  emoji(String? bokingID, String? emoji) async {
    await FirebaseFirestore.instance
        .collection('table-chat')
        .doc(
            "${Provider.of<ChatControllerProvider>(context, listen: false).userServiceId}")
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
