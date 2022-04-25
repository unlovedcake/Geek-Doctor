import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Forgot-Password.dart';
import 'package:geekdoctor/Provider/User-Service-Login-Register/Controller-User-Service-Provider.dart';
import 'package:geekdoctor/Widgets/TextFormField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/src/provider.dart';

class UserServiceLoginPage extends StatefulWidget {
  const UserServiceLoginPage({Key? key}) : super(key: key);

  @override
  _UserServiceLoginPageState createState() => _UserServiceLoginPageState();
}

class _UserServiceLoginPageState extends State<UserServiceLoginPage> {
  String? errorMessage;
  bool _isHidden = true;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller

  final TextEditingController _emailText = TextEditingController();

  final TextEditingController _passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Service Provider", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("images/animate-login.json", animate: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: "Hi, Welcome to   ",
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Geek Doctor   ",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ]),
                    ),
                    Image.asset(
                      "images/geeklogo.png",
                      height: 40,
                      width: 40,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormFields.textFormFields("Email", "Email", _emailText,
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
                TextFormFields.textFormFields("Password", "Password", _passwordText,
                    widget: null,
                    obscureText: _isHidden,
                    sufixIcon: IconButton(
                      color: Colors.orange,
                      icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        // This is the trick

                        _isHidden = !_isHidden;

                        (context as Element).markNeedsBuild();
                      },
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Password is required for login");
                  }
                }),
                SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => ForgotPassword()));
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
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
                          offset: Offset(5, 5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.grey[300]!,
                          offset: Offset(-2, -2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white, // foreground
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context
                              .read<ControllerUserServiceProvider>()
                              .signIn(_emailText.text, _passwordText.text, context);
                        }
                      },
                      // ignore: prefer_const_constructors

                      child: Text(
                        "Sign In",
                        style: GoogleFonts.acme(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      )),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text("Don't have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/user-service-registration-page');
                    },
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
