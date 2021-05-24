import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/auth/login.dart';
import 'package:handicraft/seller_screen/sellerhome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:string_validator/string_validator.dart';
import 'package:handicraft/splashScreen.dart';

class Register extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String email;
  Register({Key key, @required this.name,this.imageUrl,this.email}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register>with TickerProviderStateMixin {
  String _role="customer";
  // SharedPreferences sharedPreferences;
  GoogleSignIn _googleSignIn=GoogleSignIn(scopes: ['email']);
  final _number = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: [
            AnimatedBackground( vsync: this, behaviour: BubblesBehaviour(),
                child: SingleChildScrollView(
                  child: Container(
                    // height: height,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ClipPath(
                            clipper: DiagonalPathClipperOne(),
                            child: Container(
                                color: Color(0xff2c98f0),
                                height: height*0.2,
                                width: width,
                                child: Center(child: Text(widget.name,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),))
                            ),
                          ),
                          CircleAvatar(
                            radius: width*0.15,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: Image.network(widget.imageUrl,fit: BoxFit.cover,),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                              padding: EdgeInsets.all(8),
                              // height: 60,
                              width: width*0.75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black26,width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child:Center(
                                child: TextFormField(
                                  controller: _number,
                                  decoration: InputDecoration(
                                    hintText: "Mobile Number",
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.phone_android),
                                  ),
                                  validator: (text){
                                    if((text.trim().length==10)&&(isNumeric(text.trim()))){
                                      return null;
                                    }
                                    else
                                      return "Input proper value";
                                  },
                                ),
                              )
                          ),
                          SizedBox(height: 25,),
                          Text("Choose Role",),
                          SizedBox(height: 10,),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    height: 50,
                                    width: width*0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: _role=='seller'?Color(0xff2c98f0):Colors.black38,width: _role=='seller'?4:1),
                                        borderRadius: BorderRadius.only(topLeft:Radius.circular(20),bottomLeft: Radius.circular(20))
                                    ),
                                    child: Center(
                                      child: Text("Seller",style: TextStyle(
                                        // color: _role=="seller"?Colors.white:Colors.black
                                      ),),
                                    ),
                                  ),
                                  onTap: (){
                                    setState(() {
                                      _role="seller";
                                    });
                                  },
                                ),
                                SizedBox(width: 30,),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _role="customer";
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: width*0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: _role=='customer'?Color(0xff2c98f0):Colors.black38,width: _role=='customer'?4:1),
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                    ),
                                    child: Center(
                                      child: Text("Customer",style: TextStyle(
                                        // color: _role=="customer"?Colors.white:Colors.black
                                      ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _googleSignIn.signOut().then((value){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));});
                                },
                                child: Container(
                                    height: 50,
                                    width: width*0.1,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(color: Colors.red,width: 2),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20))
                                    ),
                                    child:Center(child: Icon(Icons.arrow_back,color: Colors.white,))
                                ),
                              ),
                              SizedBox(width: 20,),
                              GestureDetector(
                                onTap: (){
                                  void _register()async{
                                    await App.sharedPreferences.setString("type", _role);
                                    await FirebaseFirestore.instance.collection("users").doc(widget.email).set({
                                      "email":widget.email,
                                      "phone":_number.text.trim(),
                                      "type":_role,
                                      "cart":_role=="customer"?[]:null
                                    }).then((value){
                                      if(_role=='seller'){
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerHome()));
                                      }
                                      else{
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SidebarLayout()));
                                      }
                                    });
                                  }
                                  if(_formKey.currentState.validate()){
                                    _register();
                                  }
                                },
                                child: Container(
                                    height: 50,
                                    width: width*0.5,
                                    decoration: BoxDecoration(
                                        color: Color(0xff2196f3),
                                        border: Border.all(color: Color(0xff2196f3),width: 2),
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                    ),
                                    child:Center(child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 20),))
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ),
          ],
        )
    );
  }
}
