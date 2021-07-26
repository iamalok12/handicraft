import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/data/alert_box.dart';
import 'package:handicraft/sidebar/menu_item.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/login.dart';
import '../splashScreen.dart';

class Sidebar extends StatefulWidget {

  // final String name;
  // final String email;
  // final String url;
  //
  // Sidebar(this.name, this.email, this.url);
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin<Sidebar> {
  GoogleSignIn _googleSignIn=GoogleSignIn();
  AnimationController _animationController;
  StreamController<bool> isSidebarOpenedStreamController;
  Stream<bool> isSidebarOpenedStream;
  StreamSink<bool> isSidebarOpenedSink;
  // bool isSidebarOpened = false;
  // IconData sidebarIcon = FontAwesomeIcons.angleDoubleRight;
  // SharedPreferences sharedPreferences;
  final _animationDuration = const Duration(microseconds: 500);
  // String username;
  // String useremail;
  // String userurl;

  @override
  void initState() {
    super.initState();
    // void pref()async{
    //   sharedPreferences ??= await SharedPreferences.getInstance();
    // String name=await sharedPreferences.getString("name");
    // String email = await sharedPreferences.get("email");
    // String url =await sharedPreferences.get("url");
    // setState(() {
    //   username=name;
    //   username=email;
    //   username=url;
    // });
    // }
    // pref();

    _animationController = AnimationController(vsync: this,duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;

  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed(){
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;
    if(isAnimationCompleted){
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    }
    else{
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<bool>(
        initialData: false,
        stream: isSidebarOpenedStream,
        builder: (context, isSideBarOpenedAsync) {
          return AnimatedPositioned(
            duration: _animationDuration,
            top: 0,
            bottom: 0,
            left: isSideBarOpenedAsync.data  ? 0: -width,
            right: isSideBarOpenedAsync.data ? 0 : width-35,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(0),topRight: Radius.circular(0)),
                        color: Color(0xff282C31),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                          ),
                          ListTile(
                            title: Text(App.sharedPreferences.getString("name"),style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(App.sharedPreferences.getString("email"),style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,),
                            ),
                            leading: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.network(App.sharedPreferences.getString("url")),
                              ),
                            ),
                          ),
                          Divider(
                            height: 64,
                            thickness: 0.5,
                            color: Colors.white.withOpacity(0.5),
                            indent: 32,
                            endIndent: 32,
                          ),
                          MenuItem(
                            icon: Icons.home,
                            title: "Home",
                            ontap: (){
                              onIconPressed();
                              BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomePageClickedEvent);
                            },
                          ),
                          MenuItem(
                            icon: Icons.shopping_bag,
                            title: "My Orders",
                            ontap: (){
                              onIconPressed();
                              BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyOrdersClickedEvent);
                            },
                          ),
                          Divider(
                            height: 64,
                            thickness: 0.5,
                            color: Colors.white.withOpacity(0.5),
                            indent: 32,
                            endIndent: 32,
                          ),
                          MenuItem(
                            icon: Icons.exit_to_app,
                            title: "Log out",
                            ontap: (){
                              void logout()async{
                                await _googleSignIn.signOut().whenComplete((){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                                });
                              }
                              showDialog(context: context, builder: (_,){
                                return CustomAlertBox(warning: "Logout",callback: logout,);
                              });
                            },
                          ),
                        ],
                      )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      onIconPressed();
                    });
                  },
                  child: Align(
                    alignment: Alignment(0, -0.9),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30),topRight: Radius.circular(30)),
                        color: Color(0xff282C31),
                      ),
                      width: 30,
                      height: 55,
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        progress: _animationController.view,
                        icon: AnimatedIcons.menu_close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 20,
                // )
              ],
            ),
          );
        }
    );
  }
}
