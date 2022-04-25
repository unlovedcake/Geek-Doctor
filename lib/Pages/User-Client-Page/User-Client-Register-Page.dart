import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Privacy-And-Policy.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:geekdoctor/Widgets/TextFormField.dart';
import 'package:geekdoctor/model/user_client_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/src/provider.dart';
import 'package:geekdoctor/string_extension.dart';

class UserRegisterClientPage extends StatefulWidget {
  const UserRegisterClientPage({Key? key}) : super(key: key);

  @override
  _UserRegisterClientPageState createState() => _UserRegisterClientPageState();
}

class _UserRegisterClientPageState extends State<UserRegisterClientPage> {
  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  bool _isHidden = true;
  bool checkBox = false;

  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _addressText = TextEditingController();
  final TextEditingController _contactText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _confirmPasswordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 200,
                    child: Lottie.asset("images/animate-register.json", animate: true)),
                TextFormFields.textFormFields("Name", "Name", _nameText,
                    widget: null,
                    obscureText: false,
                    sufixIcon: null,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Name is required for login");
                  }
                }),
                SizedBox(
                  height: 12.0,
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
                  height: 12.0,
                ),
                TextFormFields.textFormFields("Address", "Address", _addressText,
                    widget: null,
                    obscureText: false,
                    sufixIcon: null,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Address is required for login");
                  }
                }),
                SizedBox(
                  height: 12.0,
                ),
                TextFormFields.textFormFields("Contact", "Contact", _contactText,
                    widget: null,
                    obscureText: false,
                    sufixIcon: null,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next, validator: (value) {
                  if (value!.isEmpty) {
                    return ("Contact is required for login");
                  }
                }),
                SizedBox(
                  height: 12.0,
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
                  height: 12.0,
                ),
                TextFormFields.textFormFields(
                  "Confirm Password",
                  "Confirm Password",
                  _confirmPasswordText,
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
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Confirm Password is required");
                    } else if (_confirmPasswordText.text.replaceAll(' ', '') !=
                        _passwordText.text.replaceAll(' ', '')) {
                      return "Password don't match";
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.orange,
                      value: checkBox,
                      onChanged: (value) {
                        setState(() {
                          checkBox = value!;

                          print(checkBox);
                        });
                      },
                    ),
                    RichText(
                      text: TextSpan(
                          text: 'I agree to ',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Terms of Use ',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        (context),
                                        MaterialPageRoute(
                                            builder: (context) => PrivacyAndPolicy()));
                                  }),
                            TextSpan(
                                text: 'and ',
                                style: TextStyle(fontSize: 16),
                                recognizer: TapGestureRecognizer()..onTap = () {}),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        (context),
                                        MaterialPageRoute(
                                            builder: (context) => PrivacyAndPolicy()));
                                  })
                          ]),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
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
                        // onPrimary: Colors.white,
                        primary: Colors.white, // foreground
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          UserModel? user = UserModel();
                          user.fullName = _nameText.text.capitalize();
                          user.email = _emailText.text;
                          user.address = _addressText.text.capitalize();
                          user.contactNumber = _contactText.text;

                          if (checkBox == true) {
                            context.read<ControllerClientProvider>().signUp(
                                _emailText.text,
                                _passwordText.text
                                    .replaceAll(' ', ''), // remove white space
                                user,
                                context);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please check the policy agreement.");
                          }
                        }
                      },
                      // ignore: prefer_const_constructors
                      child: Text(
                        "Sign Up",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.acme(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
