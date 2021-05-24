import 'dart:async';
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getCartItems,
          child: Center(
            child: Column(
              children: [
                Text("Total Cart Value: " + totalPrice.toString()),
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
    return Card(
      child: Container(
        color: Colors.lightBlueAccent,
        child: Column(
          children: [
            Text(title),
            Text(price.toString()),
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
      ),
    );
  }
}

class CartCard {
  String title, price, itemID, available;
  CartCard({this.title, this.price, this.itemID, this.available});
}
