import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:provider/provider.dart';

class ViewProfileUserClient extends StatefulWidget {
  const ViewProfileUserClient({Key? key}) : super(key: key);

  @override
  _ViewProfileUserClientState createState() => _ViewProfileUserClientState();
}

class _ViewProfileUserClientState extends State<ViewProfileUserClient> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        //stream: context.watch<ControllerClientProvider>().editUserClientDetails(),

        stream: FirebaseFirestore.instance
            .collection("table-user-client")
            .where('email',
                isEqualTo: context.watch<ControllerClientProvider>().getClientEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          final currentUser = snapshot.data?.docs;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.orange),
              centerTitle: true,
              title: Text("View Profile", style: TextStyle(color: Colors.orange)),
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
                                child: Hero(
                                  tag: "tag",
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage("${currentUser![0]['imageUrl']}"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 25.0,
                    ),
                    Text("Information Details"),
                    textField("${currentUser[0]['fullName']}",
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
                  height: 25.0,
                ),
              ],
            )),
          );
        });
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
}
