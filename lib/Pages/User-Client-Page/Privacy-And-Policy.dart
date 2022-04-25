import 'package:flutter/material.dart';

class PrivacyAndPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        title: Text("Privacy and Policy", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage("images/geeklogo.png"),
                width: 150.0,
                height: 150.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Terms Of Use",
                style: TextStyle(fontSize: 30.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'Welcome to Geek Doctor, operated by Engineer Gerson Boston., located '
                  'at Talisay City Cebu. By using the '
                  'app located at Cebu City, Philippines, the related mobile website, '
                  'and the mobile application , you '
                  'agree to be bound by these Terms of Service (this "Terms of '
                  'Service" or "Agreement"), whether or not you register as a '
                  'member of Geek Doctor App ("Member"). If you wish to become '
                  'a Member and/or make use of the service (the "Service"), '
                  'please read this Agreement. If you object to anything in this '
                  'Agreement or the Geek Doctor Privacy Policy, do not use the Service. \n '
                  '\n'
                  'This Agreement is subject to change by Geek Doctor App at any '
                  'time, effective upon posting on the relevant application. Your '
                  'continued use of the Application and the Service following'
                  'Geek Doctor posting of revised terms of any section of the '
                  'Agreement will constitute your express and binding '
                  'acceptance of and consent to the revised Agreement.\n'
                  '\n'
                  'PLEASE READ THIS AGREEMENT CAREFULLY AS IT '
                  'CONTAINS IMPORTANT INFORMATION REGARDING YOUR '
                  'LEGAL RIGHTS, REMEDIES AND OBLIGATIONS, INCLUDING '
                  'VARIOUS LIMITATIONS AND EXCLUSIONS, AND A DISPUTE '
                  'RESOLUTION CLAUSE THAT GOVERNS HOW DISPUTES WILL '
                  'BE RESOLVED \n'
                  '\n'
                  'Electronic Agreement. This Agreement is an electronic '
                  'contract that sets out the legally binding terms of your use of '
                  'the Application and the Service. This Agreement may be '
                  'modified by Geek Doctor from time to time. ',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
