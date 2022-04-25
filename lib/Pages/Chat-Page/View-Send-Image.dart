import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Provider/Chat-Controller-Provider/Chat-Controller-Provider.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:provider/provider.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ViewSendImage extends StatefulWidget {
  final String imageUrl;
  final String messageId;

  ViewSendImage({required this.imageUrl, required this.messageId});

  @override
  _ViewSendImageState createState() => _ViewSendImageState();
}

class _ViewSendImageState extends State<ViewSendImage> {
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(4.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  String? percentage;
  String? download;

  _saveImage() async {
    loading = true;
    percentage = "0";
    download = "";

    var status = await Permission.storage.request();
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.png";

    if (status.isGranted) {
      await Dio().download(widget.imageUrl, savePath, onReceiveProgress: (count, total) {
        progress = (count / total);
        print((count / total * 100).toStringAsFixed(0) + "%");

        percentage = (count / total * 100).toStringAsFixed(0) + "%";

        if (percentage == "100%") {
          setState(() {
            //loading = false;
            download = "Download Completed";
          });

          //percentage = (count / total * 100).toStringAsFixed(0) + "%";
        } else {
          setState(() {
            loading = true;
            download = "Downloading...";
          });
        }
      });
      final result = await ImageGallerySaver.saveFile(savePath, name: "Geek");

      // var response = await Dio()
      //     .get(widget.imageUrl, options: Options(responseType: ResponseType.bytes));
      // final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
      //     quality: 60, name: "Hello");
      print("Save Image To Picture Folder");
      Fluttertoast.showToast(msg: "You can see your download file to Images Folder");
    }
  }

  @override
  Widget build(BuildContext context) {
    String downloadingprogress = (progress * 100).toInt().toString();
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange),
          centerTitle: true,
          title: Text("Image", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                  // height: 120,
                  ),
            ),

            Container(
              height: 400,
              width: 400,
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true, // Set it to false to prevent panning.
                  boundaryMargin: EdgeInsets.all(10),
                  minScale: 0.5,
                  maxScale: 8,
                  child: Hero(
                    tag: widget.imageUrl,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.transparent, BlendMode.colorBurn)),
                        ),
                      ),
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      // errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),

            // Image.network(
            //   widget.imageUrl,
            //   fit: BoxFit.fill,
            //   height: 400.0,
            // ),
            Expanded(
              child: Container(
                  // height: 120,
                  ),
            ),
            AspectRatio(
              aspectRatio: 3 / 1,
              child: Container(
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
                            emoji(widget.messageId, "emoji-heart.gif");
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Image.asset('images/emoji-like.gif'),
                          onPressed: () {
                            emoji(widget.messageId, "emoji-like.gif");
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Image.asset('images/emoji-smile.gif'),
                          onPressed: () {
                            emoji(widget.messageId, "emoji-smile.gif");
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Image.asset('images/emoji-laugh.gif'),
                          onPressed: () {
                            emoji(widget.messageId, "emoji-laugh.gif");
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Image.asset('images/emoji-bleh.gif'),
                          onPressed: () {
                            emoji(widget.messageId, "emoji-bleh.gif");
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Image.asset('images/emoji-sad.gif'),
                          onPressed: () {
                            emoji(widget.messageId, "emoji-sad.gif");
                          },
                        ),
                        loading
                            ? Container(
                                width: 300,
                                child: Column(
                                  children: [
                                    Text("$download $percentage"),
                                    LinearProgressIndicator(
                                      minHeight: 5,
                                      value: progress,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),

                    // Text(widget.messageId),
                    // Text("${Provider.of<ChatControllerProvider>(context).getChatId}"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 40,
                          icon: Icon(
                            Icons.download,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            _saveImage();
                          },
                        ),
                        IconButton(
                            iconSize: 30,
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('table-chat')
                                  .doc(
                                      "${Provider.of<ChatControllerProvider>(context, listen: false).userServiceId}")
                                  .collection('messages')
                                  .doc(widget.messageId)
                                  .delete();

                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ],
                ),
                color: Colors.white,
              ),
            )
          ],
        ));
  }

  _showDialog(String progress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(progress),
          // content: LinearProgressIndicator(
          //   minHeight: 10,
          //   value: double.parse(progress),
          // ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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
}
