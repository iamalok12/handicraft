import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handicraft/customer_screen/orderpages.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/sidebar/sidebar_layout.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:handicraft/customer_screen/customerCart.dart';
import 'delivery_page.dart';

class ConfirmViaCart extends StatefulWidget {
  final List<String> cartCount;
  ConfirmViaCart({this.cartCount});
  @override
  _ConfirmViaCartState createState() => _ConfirmViaCartState();
}

class _ConfirmViaCartState extends State<ConfirmViaCart> {
  List<CartCards> cartItems = [];
  Future<void> getCartItems() async {
    cartItems.clear();
    for (int i = 0; i < widget.cartCount.length; i++) {
      var data = await FirebaseFirestore.instance
          .collection("Items")
          .doc(widget.cartCount[i])
          .get();
      CartCards cart = CartCards(
          title: data.data()['title'],
          price: data.data()['price'],
          itemID: data.id,
          available: data.data()['available'],
          seller: data.data()['seller']);
      cartItems.add(cart);
      // totalPrice=totalPrice+double.parse(data.data()['price']);
    }
    setState(() {});
  }

  bool processing = false;
  final _formKey = GlobalKey<FormState>();
  final _state = TextEditingController();
  final _city = TextEditingController();
  final _locality = TextEditingController();
  final _pinCode = TextEditingController();
  final titleControllerName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff44a7c4),
      appBar: AppBar(
        backgroundColor: Color(0xff44a7c4),
        // title: Text("Delivery Address"),
        elevation: 0,
        leading: CloseButton(),
      ),
      body: processing == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Shipping Address",
                      style: Theme.of(context).textTheme.headline5.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
                                      onChanged: (value) async {
                                        void update(String value) async {
                                          try {
                                            var url = Uri.parse(
                                                "https://api.postalpincode.in/pincode/$value");
                                            var result = await http.get(url);
                                            var data = jsonDecode(result.body);
                                            print(data[0]["PostOffice"][0]
                                                ["State"]);
                                            print(data[0]["PostOffice"][0]
                                                ["District"]);
                                            var state = data[0]["PostOffice"][0]
                                                ["State"];
                                            var city = data[0]["PostOffice"][0]
                                                ["District"];
                                            if (state.toString().isNotEmpty &&
                                                city.toString().isNotEmpty) {
                                              setState(() {
                                                _state.text = data[0]
                                                    ["PostOffice"][0]["State"];
                                                _city.text = data[0]
                                                        ["PostOffice"][0]
                                                    ["District"];
                                              });
                                            }
                                          } catch (e) {
                                            print(e);
                                          }
                                        }

                                        update(value);
                                      },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              const Radius.circular(26.0),
                                            ),
                                          ),
                                          filled: true,
                                          prefixIcon: Icon(
                                            Icons.pin_drop,
                                            color: Color(0xff44a7c4),
                                          ),
                                          // icon: Icon(icon,color: Colors.white,),
                                          hintStyle: TextStyle(
                                              color: Colors.grey[800]),
                                          hintText: "PinCode",
                                          fillColor: Colors.white),
                                      validator: (title) => title.length == 6 &&
                                              title.isNotEmpty &&
                                              isNumeric(title) &&
                                              _state.text.isNotEmpty &&
                                              _city.text.isNotEmpty
                                          ? null
                                          : "Please check your PinCode",
                                      controller: _pinCode,
                                    ),
                                  ),
                                ),
                                TextField1(
                                  icon: Icons.map,
                                  title: "State",
                                  titleController: _state,
                                ),
                                TextField1(
                                  icon: Icons.location_city,
                                  title: "City",
                                  titleController: _city,
                                ),
                                TextField1(
                                  icon: Icons.landscape,
                                  title: "Locality",
                                  titleController: _locality,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: SizedBox(
                      height: 50,
                      width: size.width * 0.95,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: size.width * 0.36)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.indigo),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              // side: BorderSide(color: Colors.)
                            ),
                          ),
                        ),
                        onPressed: () {
                          final isValid = _formKey.currentState.validate();
                          if (isValid) {
                            confirmOrder();
                          }
                        },
                        child: Text(
                          "Confirm Order",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void confirmOrder() async {
    await getCartItems();
    setState(() {});
    int flag = 1;
    for (int i = 0; i < cartItems.length; i++) {
      var data = await FirebaseFirestore.instance
          .collection("Items")
          .doc(widget.cartCount[i])
          .get();
      if (data.data()['available'] == "stockout") {
        flag = 0;
      }
    }
    if (flag == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Some items were removed while ordering")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CustomerCart()));
      print(flag);
    } else {
      processing = true;
      print(flag);
      for (int i = 0; i < cartItems.length; i++) {
        await FirebaseFirestore.instance.collection("Orders").doc().set({
          "title": cartItems[i].title,
          "name": titleControllerName.text.trim(),
          "itemId": cartItems[i].itemID,
          "price": cartItems[i].price,
          "seller": cartItems[i].seller,
          "customer": App.sharedPreferences.getString("email"),
          "pinCode": _pinCode.text.trim(),
          "address": _locality.text.trim() +
              ", " +
              _city.text.trim() +
              ", " +
              _state.text.trim(),
          "status": "OrderPlaced",
          "time": DateTime.now(),
        });
      }
      List<String> tempList = [];
      await FirebaseFirestore.instance
          .collection("users")
          .doc(App.sharedPreferences.getString("email"))
          .update({"cart": tempList});
      processing = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order Placed")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SidebarLayout()));
    }
  }
}

class CartCards {
  String title, price, itemID, available, seller;
  CartCards({this.title, this.price, this.itemID, this.available, this.seller});
}
