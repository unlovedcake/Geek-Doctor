import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Privacy-And-Policy.dart';
import 'package:geekdoctor/Provider/User-Service-Login-Register/Controller-User-Service-Provider.dart';
import 'package:geekdoctor/Widgets/TextFormField.dart';
import 'package:geekdoctor/model/user_service_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/src/provider.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:geekdoctor/string_extension.dart';

class UserServiceRegistrationPage extends StatefulWidget {
  const UserServiceRegistrationPage({Key? key}) : super(key: key);

  @override
  _UserServiceRegistrationPageState createState() => _UserServiceRegistrationPageState();
}

class _UserServiceRegistrationPageState extends State<UserServiceRegistrationPage> {
  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  bool _isHidden = true;
  bool checkBox = false;
  // editing Controller

  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _addressText = TextEditingController();
  final TextEditingController _contactText = TextEditingController();
  final TextEditingController _skillText = TextEditingController();
  final TextEditingController _vaccinatedText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _confirmPasswordText = TextEditingController();

  final List<Map<String, dynamic>> _items = [
    {
      'value': "  One",
      'label': "  One",
      'icon': Icon(Icons.stop),
    },
    {
      'value': "  Two",
      'label': "  Two",
      'icon': Icon(Icons.fiber_manual_record, color: Colors.red),
      'textStyle': TextStyle(color: Colors.red),
    },
    {
      'value': "  Three",
      'label': "  Three",
      //'enable': false,
      'icon': Icon(Icons.grade, color: Colors.blue),
      'textStyle': TextStyle(color: Colors.blue),
    },
    {
      'value': "  Four",
      'label': "  Four",
      //'enable': false,
      'icon': Icon(Icons.adjust, color: Colors.orange),
      'textStyle': TextStyle(color: Colors.orange),
    },
    {
      'value': "  Five",
      'label': "  Five",
      //'enable': false,
      'icon': Icon(Icons.ac_unit_outlined, color: Colors.green),
      'textStyle': TextStyle(color: Colors.green),
    },
  ];

  final List<Map<String, dynamic>> _vaccinated = [
    {
      'value': "Yes",
      'label': "  Yes",
      'icon': Icon(Icons.done),
      'textStyle': TextStyle(color: Colors.green),
    },
    {
      'value': "No",
      'label': "  No",
      'icon': Icon(Icons.ac_unit_outlined),
      'textStyle': TextStyle(color: Colors.red),
    },
  ];

  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();
  TextEditingController _textFieldController3 = TextEditingController();
  TextEditingController _textFieldController4 = TextEditingController();
  TextEditingController _textFieldController5 = TextEditingController();

  String? valueText;
  String expertise1 = "";
  String expertise2 = "";
  String expertise3 = "";
  String expertise4 = "";
  String expertise5 = "";

  int? indexVal = 0;

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Your Skills"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                style: TextButton.styleFrom(
                  primary: Colors.red, // background
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                style: TextButton.styleFrom(
                  primary: Colors.blue, // background
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(),
                    _textField(),
                    Divider(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _textField() {
    if (indexVal == 1) {
      return Column(
        children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise1 = value;
              });
            },
            controller: _textFieldController1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 1",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return ("Enter Your Expertise");
              }
            },
          ),
        ],
      );
    } else if (indexVal == 2) {
      return Column(
        children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise1 = value;
              });
            },
            controller: _textFieldController1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 1",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return ("Enter Your Expertise");
              }
            },
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise2 = value;
              });
            },
            controller: _textFieldController2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 2",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return ("Enter Your Expertise");
              }
            },
          ),
        ],
      );
    } else if (indexVal == 3) {
      return Column(
        children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise1 = value;
              });
            },
            controller: _textFieldController1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 1",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise2 = value;
              });
            },
            controller: _textFieldController2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 2",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise3 = value;
              });
            },
            controller: _textFieldController3,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 3",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    } else if (indexVal == 4) {
      return Column(
        children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise1 = value;
              });
            },
            controller: _textFieldController1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 1",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise2 = value;
              });
            },
            controller: _textFieldController2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 2",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise3 = value;
              });
            },
            controller: _textFieldController3,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 3",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise4 = value;
              });
            },
            controller: _textFieldController4,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 4",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    } else if (indexVal == 5) {
      return Column(
        children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise1 = value;
              });
            },
            controller: _textFieldController1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 1",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise2 = value;
              });
            },
            controller: _textFieldController2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 2",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise3 = value;
              });
            },
            controller: _textFieldController3,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 3",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise4 = value;
              });
            },
            controller: _textFieldController4,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 4",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            onChanged: (value) {
              setState(() {
                expertise5 = value;
              });
            },
            controller: _textFieldController5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Expertise 5",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    } else {
      return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),

        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {
        //     // passing this to our root
        //     Navigator.of(context).pop();
        //   },
        // ),
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 4.0,
                      ),
                      SelectFormField(
                          controller: _skillText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Enter you expertise");
                            }
                          },
                          decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            hintText: 'Expertise you have?',
                            labelText: 'How many expertise you have?',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent, width: 2.0),
                            ),
                          ),
                          type: SelectFormFieldType.dropdown, // or can be dialog
                          //initialValue: "One",
                          // icon: Icon(Icons.format_shapes),

                          items: _items,
                          onChanged: (val) {
                            print(val);

                            if (val == "  One") {
                              indexVal = 1;
                              print(indexVal);
                            } else if (val == "  Two") {
                              indexVal = 2;
                              print(indexVal);
                            } else if (val == "  Three") {
                              indexVal = 3;
                              print(indexVal);
                            } else if (val == "  Four") {
                              indexVal = 4;
                              print(indexVal);
                            } else if (val == "  Five") {
                              indexVal = 5;
                              print(indexVal);
                            }

                            _displayTextInputDialog(context);
                          }
                          //onSaved: (val) => print(val),
                          ),
                      SizedBox(
                        height: 10.0,
                      ),
                      indexVal != 0
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 10),
                                child: FittedBox(
                                  child: Text(
                                    " { ${expertise1}" +
                                        "${"   " + expertise2}" +
                                        "${"   " + expertise3}" +
                                        "${"   " + expertise4}" +
                                        "${"   " + expertise5} }",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 4.0,
                      ),
                      SelectFormField(
                          controller: _vaccinatedText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Required");
                            }
                          },
                          decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            hintText: 'Are You Vaccinated?',
                            labelText: 'Vaccinated',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orangeAccent, width: 2.0),
                            ),
                          ),
                          type: SelectFormFieldType.dropdown, // or can be dialog
                          //initialValue: "One",
                          // icon: Icon(Icons.format_shapes),
                          //labelText: 'Are You Vaccinated?',
                          items: _vaccinated,
                          onChanged: (val) {
                            print(val);
                          }
                          //onSaved: (val) => print(val),
                          ),
                      SizedBox(
                        height: 4.0,
                      ),
                    ],
                  ),
                ),
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
                          UserServiceProviderModel? userService =
                              UserServiceProviderModel();
                          userService.fullName = _nameText.text.capitalize();
                          userService.email = _emailText.text;
                          userService.address = _addressText.text.capitalize();
                          userService.contactNumber = _contactText.text;
                          userService.vaccinated = _vaccinatedText.text;
                          userService.skills = {
                            'expertise1': expertise1,
                            'expertise2': expertise2,
                            'expertise3': expertise3,
                            'expertise4': expertise4,
                            'expertise5': expertise5,
                          };

                          //default value for rating
                          userService.rating = {
                            'rate1': 0,
                            'rate2': 1,
                            'rate3': 3,
                            'rate4': 2,
                            'rate5': 1,
                          };

                          if (checkBox == true) {
                            context.read<ControllerUserServiceProvider>().signUp(
                                _emailText.text,
                                _passwordText.text.replaceAll(' ', ''),
                                userService,
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
                        style: GoogleFonts.acme(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        textAlign: TextAlign.center,
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
