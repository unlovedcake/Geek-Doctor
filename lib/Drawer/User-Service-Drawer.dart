import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Login-Page.dart';
import 'package:geekdoctor/Pages/User-Service-Page/User-Service-History.dart';
import 'package:google_fonts/google_fonts.dart';

class UserServiceDrawer extends StatefulWidget {
  const UserServiceDrawer({Key? key}) : super(key: key);

  @override
  _UserServiceDrawerState createState() => _UserServiceDrawerState();
}

class _UserServiceDrawerState extends State<UserServiceDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

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

        if (!snapshot.hasData) {
          return Text("");
        }
        return SafeArea(
          child: Container(
            width: 300.0,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/user-service-profile-page');
                    },
                    child: Container(
                      width: double.infinity,
                      color: Colors.orange,
                      child: Column(
                        children: [
                          Hero(
                            tag: "tag1",
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CachedNetworkImage(
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                imageUrl: currentUser![0]['imageUrl'],
                                imageBuilder: (context, imageProvider) => Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(80)),
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
                          Text(
                            "${currentUser[0]['fullName']}",
                            style: GoogleFonts.mcLaren(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Text(
                            "${currentUser[0]['email']}",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text("Profile"),
                    leading: IconButton(
                      icon: Icon(Icons.account_circle),
                      color: Colors.orange,
                      onPressed: () {},
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/user-service-profile-page');
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: Text("Booking List"),
                    leading: IconButton(
                      icon: Icon(Icons.three_p),
                      color: Colors.blue,
                      onPressed: () {},
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/booking-client-page');
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: Text("History"),
                    leading: IconButton(
                      icon: Icon(Icons.history),
                      color: Colors.green,
                      onPressed: () {},
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/user-service-history');
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(builder: (context) => UserServiceHistory()));
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                      title: Text("Logout"),
                      leading: IconButton(
                        icon: Icon(Icons.logout),
                        color: Colors.redAccent,
                        onPressed: () {},
                      ),
                      onTap: () {
                        logout(context);
                        FirebaseFirestore.instance
                            .collection('table-user-service')
                            .doc(user!.uid)
                            .set({
                          "status": "Offline",
                        }, SetOptions(merge: true)).then((_) async {});
                      }),
                  Divider(
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    //Navigator.popAndPushNamed(context, '/user-service-login-page');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => UserLoginClientPage()));
  }
}
