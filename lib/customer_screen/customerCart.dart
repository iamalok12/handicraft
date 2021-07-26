import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:handicraft/customer_screen/confirmOrderViaCart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handicraft/splashScreen.dart';

class CustomerCart extends StatefulWidget {
  final List<String> cartCount;
  CustomerCart({this.cartCount});

  @override
  _CustomerCartState createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  List<CartCard> cartItems = [];
  Future<void> getCartItems() async {
    cartItems.clear();
    totalPrice = 0;
    for (int i = 0; i < widget.cartCount.length; i++) {
      var data = await FirebaseFirestore.instance
          .collection("Items")
          .doc(widget.cartCount[i])
          .get();
      CartCard cart = CartCard(
          title: data.data()['title'],
          price: data.data()['price'],
          itemID: data.id,
          available: data.data()['available']);
      cartItems.add(cart);
      totalPrice = totalPrice + double.parse(data.data()['price']);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCartItems();
  }

  double totalPrice = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        centerTitle: true,
        backgroundColor: Color(0xff2c98f0),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getCartItems,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10,right: 10),
                  height: 50,
                    width: double.infinity*0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black)
                    ),
                    child: Center(
                      child: Text(
                  "Total Cart Value: " + totalPrice.toString(),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                    )),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    child: cartItems.length == 0
                        ? Text("Cart Empty")
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (_, index) {
                              return CartItems(
                                  context,
                                  cartItems[index].title,
                                  cartItems[index].price,
                                  cartItems[index].itemID,
                                  cartItems[index].available);
                            }),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      void checkOut() async {
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Remove out of stock item")));
                          print(flag);
                        } else {
                          print(flag);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConfirmViaCart(
                                        cartCount: widget.cartCount,
                                      )));
                        }
                      }

                      checkOut();
                    },
                    child: Text("Proceed to Buy"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CartItems(BuildContext context, String title, String price,
      String itemID, String available) {
    String avaiblity = available;
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
        border: Border.all(color:Color(0xff2c98f0) )
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(title,style: TextStyle(fontSize: 20),),
              Text(price.toString(),style: TextStyle(fontSize: 20)),
            ],
          ),
          SizedBox(height: 10,),
          avaiblity == "instock"
              ? SizedBox(
                  height: 0,
                )
              : Text("Not available"),
          ElevatedButton(
              onPressed: () {
                void remove() async {
                  widget.cartCount.remove(itemID);
                  // setState(() {
                  cartItems
                      .removeWhere((element) => element.itemID == itemID);
                  setState(() {
                    totalPrice = double.parse(totalPrice.toString()) -
                        double.parse(price);
                  });
                  // });
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(App.sharedPreferences.getString("email"))
                      .update({"cart": widget.cartCount}).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Removed from cart")));
                  });
                }

                remove();
              },
              child: Text("Remove"))
        ],
      ),
    );
  }
}

class CartCard {
  String title, price, itemID, available;
  CartCard({this.title, this.price, this.itemID, this.available});
}
