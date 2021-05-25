import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/auth/login.dart';
import 'package:handicraft/betaPage.dart';
import 'package:handicraft/seller_screen/sellerhome.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GoogleSignIn _googleSignIn=GoogleSignIn(scopes: ['email']);
  String type;
  // SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    displaySplash();
  }
  void displaySplash()async{
    var status=await FirebaseFirestore.instance.collection("testing").doc("beta").get();
    if(status.data()["active"]=="no"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BetaTesting()));
    }
    else{
      Timer(Duration(seconds: 5),()async{
        if(await _googleSignIn.isSignedIn()){
          String type=App.sharedPreferences.getString("type");
          if(type=='seller'){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>(SellerHome())));
          }
          else if(type=='customer'){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>(SidebarLayout())));
          }
          else{
            await _googleSignIn.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>(Login())));
            print("something wrong");
          }
        }
        else{

          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>(Login())));
          print("user null");
          print(type);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
      body:Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                image:DecorationImage(
                    image: AssetImage("images/splash.jpg"),
                    fit: BoxFit.cover
                )
            ),
          ),
          Container(
            child: Center(child: Text("Handicraft",style: TextStyle(fontSize: height*0.08,fontFamily: "Pacifico"),)),
            decoration: BoxDecoration(
                   color: Colors.white54,
              borderRadius: BorderRadius.circular(10)
            ),
            margin: EdgeInsets.only(top:height*0.15 ),
            height: 100,
            width: width*0.8,

          )
        ],
      ),
    );
  }
}

class App{
  static SharedPreferences sharedPreferences;
}
