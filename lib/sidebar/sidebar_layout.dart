import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/sidebar/sidebar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SidebarLayout extends StatefulWidget {


  @override
  _SidebarLayoutState createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  // SharedPreferences sharedPreferences;
  // String name;
  // String email;
  // String url;
  // @override
  // void initState() {
  //   super.initState();
  //   // void pref()async{
  //   //   sharedPreferences ??= await SharedPreferences.getInstance();
  //   //    String _name = await sharedPreferences.get("name");
  //   //    String _email = await sharedPreferences.get("email");
  //   //    String _url =await sharedPreferences.get("url");
  //   //    print(_name);
  //   //
  //   //   setState(() {
  //   //     name=_name;
  //   //     email=_email;
  //   //     url=_url;
  //   //   });
  //   //   print(name+"2nd");
  //   // }
  //   // pref();
  //
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<NavigationBloc>(
        create: (context) => NavigationBloc(CustomerHome()),
        child: Stack(
          children: [
            BlocBuilder<NavigationBloc, NavigationStates>(
              builder: (context, navigationState){
                return navigationState as Widget;
              },
            ),
            Sidebar(),
          ],
        ),
      ),
    );
  }
}
