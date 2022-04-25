import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Login-Page.dart';
import 'package:geekdoctor/Widgets/TextFormField.dart';
import 'package:geekdoctor/model/message-model.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // our form key
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();

  bool _isHidden = true;
  String? email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Forgot Password", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
              TextFormFields.textFormFields(
                  "Enter your google email account", "Email", _emailText,
                  widget: null,
                  obscureText: false,
                  sufixIcon: null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next, validator: (value) {
                if (value!.isEmpty) {
                  return ("Email is required for login");
                }
              }),
              SizedBox(
                height: 15.0,
              ),
              // TextFormFields.textFormFields("Password", "New Password", _passwordText,
              //     widget: null,
              //     obscureText: _isHidden,
              //     sufixIcon: IconButton(
              //       color: Colors.orange,
              //       icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
              //       onPressed: () {
              //         // This is the trick
              //
              //         _isHidden = !_isHidden;
              //
              //         (context as Element).markNeedsBuild();
              //       },
              //     ),
              //     keyboardType: TextInputType.text,
              //     textInputAction: TextInputAction.done, validator: (value) {
              //   if (value!.isEmpty) {
              //     return ("Password is required for login");
              //   }
              // }),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.orange,
                  child: MaterialButton(
                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: MediaQuery.of(context).size.width,
                      onPressed: () async {
                        //changePassword(_passwordText.text);
                        forgotPassword(_emailText.text);
                      },
                      child: Text(
                        "Send",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  changePassword(String? password) async {
    User? user = await FirebaseAuth.instance.currentUser;
    var auth = FirebaseAuth.instance;
    if (_formKey.currentState!.validate()) {
      try {
        // await FirebaseFirestore.instance
        //     .collection("table-user-client")
        //     .where("email", isEqualTo: _emailText.text)
        //     .get()
        //     .then((value) {
        //   value.docs.forEach((result) {
        //     email = result.data()['email'];
        //   });
        // });

        print('$email oekekek');
        // print(' OKEY');
        print('${auth}  OKEY');

        // if (user!.providerData.first.email == _emailText.text) {
        //   user.updatePassword(password!).then((_) {
        //     Fluttertoast.showToast(msg: "Successfully Change Password.");
        //   }).catchError((error) {
        //     print("Password can't be changed" + error.toString());
        //     //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
        //   });
        //   print("OKEY");
        // } else {
        //   print("ERROR");
        //   Fluttertoast.showToast(msg: 'No user found for that email.');
        // }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
              msg: 'No user found for that email.', toastLength: Toast.LENGTH_LONG);
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }

  void forgotPassword(String email) async {
    if (_formKey.currentState!.validate()) {
      await _auth.sendPasswordResetEmail(email: email).then((uid) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UserLoginClientPage()),
        );

        CherryToast.success(
          title: 'Reset Password',
          displayTitle: true,
          autoDismiss: true,
          description: 'Password reset instructions have been sent to $email',
          animationType: ANIMATION_TYPE.fromTop,
          actionStyle: TextStyle(color: Colors.green),
          animationDuration: Duration(milliseconds: 2000),
          action: '',
          actionHandler: () {},
        ).show(context);
        // Fluttertoast.showToast(
        //     msg: 'Password reset instructions have been sent to $email',
        //     toastLength: Toast.LENGTH_LONG);
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: "Your email is not registered to Gmail account.",
            toastLength: Toast.LENGTH_LONG);
      });
    }
  }
}
