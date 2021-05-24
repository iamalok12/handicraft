import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:string_validator/string_validator.dart';


class DeliveryPage extends StatefulWidget {
  String imageUrl,title,price,desc,itemID,seller;
  DeliveryPage(this.imageUrl,this.title,this.price,this.desc,this.itemID,this.seller);

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {


  final titleController1 = TextEditingController();
  final titleControllerName = TextEditingController();
  final titleController2 = TextEditingController();
  final titleController3 = TextEditingController();
  final titleController4 = TextEditingController();
  // bool report;
  bool processing=false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff282C31),
      appBar: AppBar(
        backgroundColor: Color(0xff282C31),
        // title: Text("Delivery Address"),
        elevation: 0,
        leading: CloseButton(),
      ),
      body: processing==true?Center(child: CircularProgressIndicator()):SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Shipping Address",
                  style: GoogleFonts.koHo(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 26)
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            Form(
              key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          TextField1(icon: Icons.person,title: "Name",titleController: titleControllerName),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onChanged: (value) async{
                                  void update(String value)  async{
                                    try{
                                      var url=Uri.parse("https://api.postalpincode.in/pincode/$value");
                                      var result=await http.get(url);
                                      var data=jsonDecode(result.body);
                                      print(data[0]["PostOffice"][0]["State"]);
                                      print(data[0]["PostOffice"][0]["District"]);
                                      var state = data[0]["PostOffice"][0]["State"];
                                      var city = data[0]["PostOffice"][0]["District"];
                                      if(state.toString().isNotEmpty && city.toString().isNotEmpty){
                                        setState(() {
                                          titleController1.text = data[0]["PostOffice"][0]["State"];
                                          titleController2.text = data[0]["PostOffice"][0]["District"];
                                        });
                                      }
                                    }
                                    catch(e){
                                      print(e);
                                    }
                                  }
                                  update(value);
                                },
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(26.0),
                                      ),
                                    ),
                                    filled: true,
                                    prefixIcon: Icon(Icons.pin_drop,color: Colors.white),
                                    // icon: Icon(icon,color: Colors.white,),
                                    hintStyle: TextStyle(color: Colors.white),
                                    hintText: "PinCode",
                                    fillColor: Colors.grey
                                ),
                                validator: (title) =>
                                title.length == 6 && title.isNotEmpty && isNumeric(title) && titleController1.text.isNotEmpty && titleController2.text.isNotEmpty? null : "Please check your PinCode",
                                controller: titleController4,
                              ),
                            ),
                          ),
                          TextField1(icon: Icons.map,title: "State",titleController: titleController1),
                          TextField1(icon: Icons.location_city,title: "City",titleController: titleController2),
                          TextField1(icon: Icons.landscape,title: "Locality",titleController: titleController3),
                        ],
                      ),
                    ),
                ],)),
            SizedBox(
              height: size.height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15,bottom: 10),
              child: SizedBox(
                height: 50,
                width: size.width * 0.95,
                child: ElevatedButton(
                  style: ButtonStyle(
                    // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: size.width * 0.36)),
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        // side: BorderSide(color: Colors.)
                      ),
                    ),
                  ),
                  onPressed: (){
                    final isValid = _formKey.currentState.validate();
                    if (isValid) {
                      buyNow();
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context) => OrderSuccessFull()));
                    }
                  },
                  child: Text("Confirm Order",style: TextStyle(color: Colors.white),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void buyNow() async{
    setState(() {});

    int flag = 1;
    var data = await FirebaseFirestore.instance
        .collection("Items")
        .doc(widget.itemID)
        .get();
    if (data.data()['available'] == "stockout") {
      flag = 0;
    }
    if (flag == 1) {
        setState(() {
          processing=true;
        });
        saveAllDataToFirebase();
      }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order out of Stock"),behavior: SnackBarBehavior.floating,));
    }
  }

  saveAllDataToFirebase() async{
      await FirebaseFirestore.instance.collection("Orders").doc().set({
        "title": widget.title.trim(),
        "name": titleControllerName.text.trim(),
        "time": DateTime.now(),
        "itemId":widget.itemID.trim(),
        "price":widget.price.trim(),
        "seller":widget.seller.trim(),
        "customer":App.sharedPreferences.getString("email"),
        "pinCode":titleController4.text.trim(),
        "address":titleController3.text.trim() +", " +titleController2.text.trim() +", "+titleController1.text.trim(),
        "status": "Order Placed",
        "time":DateTime.now()
      }).then((value){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Successful"),behavior: SnackBarBehavior.floating,));
        setState(() {
          processing=false;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SidebarLayout()));
      });
  }
}







class TextField1 extends StatelessWidget {

  final IconData icon;
  final String title;
  final TextEditingController titleController;
  const TextField1({
    Key key, this.icon, this.title, this.titleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(26.0),
              ),
            ),
            filled: true,
            prefixIcon: Icon(icon,color: Colors.white),
            // icon: Icon(icon,color: Colors.white,),
            hintStyle: TextStyle(color: Colors.white),
            hintText: title,
            fillColor: Colors.grey
        ),
        validator: (title) =>
        title != null && title.isEmpty ? "This cannot be empty" : null,
        controller: titleController,
      ),
    );
  }
}


// class TextField12 extends StatefulWidget {
//
//   final IconData icon;
//   final String title;
//   final TextEditingController titleController;
//   final TextEditingController titleController1;
//   final TextEditingController titleController2;
//   const TextField12({
//     Key key, this.icon, this.title, this.titleController, this.titleController1, this.titleController2,
//   }) : super(key: key);
//
//   @override
//   _TextField12State createState() => _TextField12State();
// }
//
// class _TextField12State extends State<TextField12> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextFormField(
//         onChanged: (value) async{
//           void update(String value)  async{
//           var url=Uri.parse("https://api.postalpincode.in/pincode/$value");
//           var result=await http.get(url);
//           var data=jsonDecode(result.body);
//           print(data[0]["PostOffice"][0]["State"]);
//           setState(() {
//             widget.titleController1.text = data[0]["PostOffice"][0]["State"];
//           });
//           }
//           update(value);
//         },
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: const BorderRadius.all(
//                 const Radius.circular(26.0),
//               ),
//             ),
//             filled: true,
//             prefixIcon: Icon(widget.icon,color: Color(0xff44a7c4),),
//             // icon: Icon(icon,color: Colors.white,),
//             hintStyle: TextStyle(color: Colors.grey[800]),
//             hintText: widget.title,
//             fillColor: Colors.white
//         ),
//         validator: (title) =>
//          title.length == 6 && title.isNotEmpty && isNumeric(title)? null : "This cannot be empty",
//         controller: widget.titleController,
//       ),
//     );
//   }
// }
