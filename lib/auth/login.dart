import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/auth/register.dart';
import 'package:handicraft/seller_screen/sellerhome.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_background/animated_background.dart';
import 'package:handicraft/splashScreen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  String type;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBackground(
          vsync: this,
          behaviour: BubblesBehaviour(),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("images/logo.png"),
                  )),
                  height: 60,
                  width: 60,
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  height: 60,
                  width: width * 0.6,
                  child: ElevatedButton(
                      onPressed: () {
                        void signIn() async {
                          await _googleSignIn.signIn().then((value) async {
                            print(_googleSignIn.currentUser.displayName);
                            var data = await FirebaseFirestore.instance
                                .collection("users")
                                .where("email",
                                    isEqualTo: _googleSignIn.currentUser.email)
                                .get();
                            if (data.docs.isNotEmpty) {
                              data.docs.forEach((element) async {
                                type = element.data()["type"];
                                await App.sharedPreferences
                                    .setString("type", type);
                                await App.sharedPreferences.setString(
                                    "email", _googleSignIn.currentUser.email);
                                await App.sharedPreferences.setString(
                                    "url", _googleSignIn.currentUser.photoUrl);
                                await App.sharedPreferences.setString("name",
                                    _googleSignIn.currentUser.displayName);
                                if (type == "seller") {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SellerHome()));
                                } else if (type == "customer") {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SidebarLayout()));
                                }
                              });
                            } else if (data.docs.isEmpty) {
                              await App.sharedPreferences.setString(
                                  "email", _googleSignIn.currentUser.email);
                              await App.sharedPreferences.setString(
                                  "url", _googleSignIn.currentUser.photoUrl);
                              await App.sharedPreferences.setString("name",
                                  _googleSignIn.currentUser.displayName);
                              await App.sharedPreferences
                                  .setString("type", "null");
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register(
                                            name: _googleSignIn
                                                .currentUser.displayName,
                                            imageUrl: _googleSignIn
                                                .currentUser.photoUrl,
                                            email:
                                                _googleSignIn.currentUser.email,
                                          )));
                              print("empty");
                            }
                          }); //google sign
                        }
                        signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff2c98f0),
                        elevation: 20,
                      ),
                      child: Text(
                        "Sign in using Google",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
