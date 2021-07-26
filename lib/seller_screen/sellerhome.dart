import 'package:handicraft/data/alert_box.dart';
import 'package:handicraft/seller_screen/addselleritems.dart';
import 'package:handicraft/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animated_background/animated_background.dart';
import 'package:handicraft/seller_screen/sellerhomewidgets.dart';

class SellerHome extends StatefulWidget {
  @override
  _SellerHomeState createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> with TickerProviderStateMixin {
  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final _pageController = PageController();
    return Scaffold(
      backgroundColor: Colors.black87,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color(0xff282C31),
        color: Color(0xff282C31),
        index: 0,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.edit,
            size: 20,
            color: Colors.white,
          ),
          IconButton(
              icon: Icon(
                Icons.power_settings_new,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () {
                void logout() async {
                  await _googleSignIn.signOut().whenComplete(() {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  });
                }

                showDialog(context: context, builder: (_,){
                  return CustomAlertBox(warning: "Logout ?",callback: logout,);
                });
              })
        ],
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
          });
        },
        letIndexChange: (index) => true,
      ),
      body: Center(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [OrdersArrived(), ItemModify()],
          onPageChanged: (int index) {
            setState(() {
              _pageController.jumpToPage(index);
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddItemsBySeller()));
        },
      ),
    );
  }
}
