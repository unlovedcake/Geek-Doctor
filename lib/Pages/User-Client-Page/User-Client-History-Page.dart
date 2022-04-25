import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/BottomNavigationBar.dart';
import 'package:provider/src/provider.dart';

class UserClientHistoryPage extends StatefulWidget {
  const UserClientHistoryPage({Key? key}) : super(key: key);

  @override
  _UserClientHistoryPageState createState() => _UserClientHistoryPageState();
}

class _UserClientHistoryPageState extends State<UserClientHistoryPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange),
          centerTitle: true,
          title: Text("History", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBar: BottomNavBar(index: 3),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-history")
              .where('clientEmail', isEqualTo: user!.email)
              .snapshots(),
          builder: (
            context,
            AsyncSnapshot<QuerySnapshot?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            } else if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.data!.docs.isNotEmpty) {
                return new ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (ctxt, int index) {
                      final DocumentSnapshot bookingData = snapshot.data!.docs[index];

                      return Card(
                          elevation: 4.0,
                          child: Column(
                            children: [
                              ListTile(
                                // leading: Container(
                                //   height: 100.0,
                                //   width: 50,
                                //   child: Image.network(
                                //     bookingData['serviceImage'],
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                                title: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: bookingData['serviceImage'],
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                      child: Text(
                                    bookingData['userServiceName'],
                                    style: TextStyle(fontSize: 20.0),
                                  )),
                                ),
                                //trailing: Icon(Icons.favorite_outline),
                              ),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                      text: "Status: ",
                                      style:
                                          TextStyle(fontSize: 16.0, color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: bookingData['status'],
                                          style: TextStyle(
                                              fontSize: 16.0, color: Colors.green),
                                        ),
                                      ]),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                      text: "Date Completed: ",
                                      style:
                                          TextStyle(fontSize: 16.0, color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: bookingData['dateFinished'],
                                          style: TextStyle(
                                              fontSize: 16.0, color: Colors.green),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ));
                    });
              } else {
                return Center(child: const Text('No History Yet'));
              }
            } else {
              return Center(child: Text('State: ${snapshot.connectionState}'));
            }
          },
        ));
  }
}
