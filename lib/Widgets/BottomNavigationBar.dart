import 'package:flutter/material.dart';
import 'package:geekdoctor/Pages/User-Client-Page/Search-User-SerVice-Provider.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-History-Page.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Home-Page.dart';
import 'package:geekdoctor/Pages/User-Client-Page/User-Client-Profile-Page.dart';
import 'package:geekdoctor/Provider/User-Client-Login-Register/Controller-Client-Provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

class BottomNavBar extends StatefulWidget {
  final int index;

  const BottomNavBar({required this.index});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomNavigationBar(
        selectedIconTheme: IconThemeData(color: Colors.orange),
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.index,
        onTap: (value) async {},
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => UserClientHomePage()));
                  context.read<ControllerClientProvider>().setSelectedBottomNav(0);
                },
              ),
              backgroundColor: Colors.orange,
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UserClientProfilePage()));
                },
              ),
              label: "Profile"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  Navigator.pushNamed(context, '/booking-list-page');
                },
              ),
              label: "Booking"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UserClientHistoryPage()));
                },
              ),
              label: "History"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SearchUserServiceProvider()));
                },
              ),
              label: "Search"),
        ],
      ),
    );
  }
}
