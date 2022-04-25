import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserServiceHistory extends StatefulWidget {
  const UserServiceHistory({Key? key}) : super(key: key);

  @override
  _UserServiceHistoryState createState() => _UserServiceHistoryState();
}

class _UserServiceHistoryState extends State<UserServiceHistory> {
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
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("table-history")
              .where('userServiceEmail', isEqualTo: user!.email)
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
                return const Text('No Internet Access');
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
                                title: Container(
                                  height: 200.0,
                                  child: Image.network(
                                    bookingData['clientImage'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                      child: Text(
                                    bookingData['clientName'],
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
