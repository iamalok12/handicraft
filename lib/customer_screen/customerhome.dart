import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/customer_screen/customerCart.dart';
import 'package:handicraft/data/data.dart';
import 'package:handicraft/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:handicraft/customer_screen/myorderspage.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handicraft/splashScreen.dart';

import 'orderpages.dart';

class CustomerHome extends StatefulWidget with NavigationStates {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<Data> dataList = [];
  GoogleSignIn _googleSignIn = GoogleSignIn();


  List<String> cartList = [];


  @override
  void initState() {
    super.initState();
    // fetchData();
    // getCart();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2c98f0),
        title: Text("Products"),
        centerTitle: true,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CustomerCart(
                            cartCount: cartList,
                          )));
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  height: 30,
                  width: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .where("email",
                              isEqualTo:
                              App.sharedPreferences.getString("email"))
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                            void getCart() async {
                              if (streamSnapshot.hasData) {
                                cartList = List.from(
                                    streamSnapshot.data.docs[0]['cart']);
                              }
                            }

                            getCart();
                            return !streamSnapshot.hasData
                                ? CircularProgressIndicator()
                                : Text(
                              cartList.length.toString(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            );
                          },
                        ),
                        // cartLength==null?LinearProgressIndicator():Text(cartLength,style: TextStyle(color: Colors.white,fontSize: 20),),
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor:Colors.white,
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Items").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              return !streamSnapshot.hasData
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: streamSnapshot.data.docs.length,
                      itemBuilder: (_, index) {
                        return FeaturedProductss(
                            streamSnapshot.data.docs[index]['imageURL'],
                            streamSnapshot.data.docs[index]['title'],
                            streamSnapshot.data.docs[index]['price'], () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => (OrdersPages(
                                      streamSnapshot.data.docs[index]['imageURL'],
                                      streamSnapshot.data.docs[index]['title'],
                                      streamSnapshot.data.docs[index]['price'],
                                      streamSnapshot.data.docs[index]['desc'],
                                      streamSnapshot.data.docs[index].id,
                                      streamSnapshot.data.docs[index]['seller'],
                                      cartList))));
                        });
                      },
                    );
            },
          ),
          )
        ],
      ),
    );
  }

  Widget FeaturedProductss(
      String imageUrl, String title, String price, Function function) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: function,
      child: Container(
        margin: EdgeInsets.all(20),
        width: size.width * 0.7,
        // height: size.height*0.4,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Color(0xff282C31),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0.0, 5),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    title,
                      style: GoogleFonts.koHo(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18)
                  ),
                  Spacer(),
                  Text(
                    "₹ " + price,
                      style: GoogleFonts.koHo(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 18)
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class FeaturedProducts extends StatelessWidget {
//   const FeaturedProducts({
//     Key key, this.image, this.title, this.price, this.onPress,
//   }) : super(key: key);
//
//   final String image,title, price;
//   final Function onPress;
//
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: onPress,
//       child: Container(
//         margin: EdgeInsets.all(20),
//         width: size.width*0.7,
//         // height: size.height*0.4,
//         child: Column(
//           children: [
//             Image.network(image),
//           Container(
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey,
//                   offset: Offset(0.0, 5),
//                   blurRadius: 6.0,
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Text("$title",
//                   style: TextStyle(
//                     color: Colors.black.withOpacity(0.5),fontSize: 18, fontWeight: FontWeight.bold
//                   ),
//                 ),
//                 Spacer(),
//                 Text("$price",
//                   style: TextStyle(
//                       color: Color(0xff44a7c4),fontSize: 18, fontWeight: FontWeight.bold
//                   ),
//                 ),
//               ],
//             ),
//           )
//           ],
//         ),
//       ),
//     );
//   }
// }
