import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handicraft/sidebar_navigation/navigation_bloc.dart';
import 'package:handicraft/splashScreen.dart';

class OrdersPage extends StatefulWidget  with NavigationStates{
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<MyOrder> list=[];
  var sellerMobileNumber;
  var imageUrl;
  bool process=true;
  Future<void> getMyOrders()async{
    list.clear();
    var data=await FirebaseFirestore.instance.collection("Orders").where("customer",isEqualTo: App.sharedPreferences.get("email")).get();
    for(int i=0;i<data.docs.length;i++){

      Future<void> fetchNumber()async{
        var sellermob=await FirebaseFirestore.instance.collection("users").doc(data.docs[i].data()["seller"]).get();
        setState(() {
          sellerMobileNumber=sellermob.data()["phone"];
        });
      }
      Future<void> fetchImageUrl()async{
        var image=await FirebaseFirestore.instance.collection("Items").doc(data.docs[i].data()["itemId"]).get();
        setState(() {
          imageUrl=image.data()["imageURL"];
        });
      }
      Future.wait([fetchNumber(),fetchImageUrl()]).then((value){
        process=false;
        MyOrder myorder=MyOrder(data.docs[i].id, data.docs[i].data()["title"], data.docs[i].data()["time"], data.docs[i].data()["price"], data.docs[i].data()["status"], imageUrl, data.docs[i].data()["seller"], sellerMobileNumber);
        list.add(myorder);
        setState(() {
        });
      });
    }

  }
  @override
  void initState() {
    super.initState();
    getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black87,
      body: RefreshIndicator(
        onRefresh: getMyOrders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20,top: 40),
              child: Align(
                alignment: Alignment(0.22,-1),
                child: Container(
                  padding: EdgeInsets.only(left: 50,right: 50,top: 10,bottom: 10),
                  decoration: BoxDecoration(
                    color: Color(0xff282C31),
                    borderRadius: BorderRadius.all(Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.0, 5),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text("My Orders",
                    style: GoogleFonts.koHo(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 40)
                  ),
                ),
              ),
            ),

            Expanded(
                child:process==true?
                Center(child: Center(child: CircularProgressIndicator())):ListView.builder(itemCount: list.length,
                  itemBuilder: (_,index){
                    return OrdersContainer(context, list[index].orderNo, list[index].itemName, list[index].totalAmount, list[index].status, list[index].date,list[index].imageUrl,list[index].sellerID,list[index].sellerPhone);
                  },
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget OrdersContainer( BuildContext context, String orderNo, String itemId,String price, String status,Timestamp date, String imageUrl,String id, String no) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 15,left: 8,right: 8,bottom: 8),
      child: Container(
        // height: size.height * 0.37,
        width: size.width * 0.95,
        decoration: BoxDecoration(
          color: Color(0xff282C31),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 5),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8,top: 8),
                  child: Text("Order No: " + orderNo,
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8,top: 8),
                  child: Text(date.toDate().day.toString() + ":" + date.toDate().month.toString() + ":" + date.toDate().year.toString(),
                    style: TextStyle(fontSize: 15,color: Colors.white),
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 16),
                  child: Text("Item Name: ",
                    style: TextStyle(fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(itemId,
                    style: TextStyle(fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Total Amount: ",
                  style: TextStyle(fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text("₹ " + price,
                    style: TextStyle(fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8,bottom: 5),
                  child: Text(status,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: status == "Order Cancelled"? Color(0xffBF0000): Colors.green,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ExpandChild(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.7,
                      height: size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.0, 5),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: size.height * 0.35,
                        width: size.width * 0.5,
                        imageUrl: imageUrl,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8,left: 8,bottom: 5),
                      child: Text("Seller Details: ",
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(id,
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(no,
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15,bottom: 5,top: 5),
                      child: SizedBox(
                        height: 50,
                        width: size.width * 0.95,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: size.width * 0.36)),
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26.0),
                                // side: BorderSide(color: Colors.)
                              ),
                            ),
                          ),
                          onPressed: (){
                            void cancelled() {
                              FirebaseFirestore.instance
                                  .collection('Orders')
                                  .doc(orderNo)
                                  .update({
                                "status": "Order Cancelled"
                              });
                              setState(() {
                                print(status);
                                // getMyOrders();
                              });
                            }

                            cancelled();
                          },
                          child: Text("Cancel Order",style: TextStyle(color: Colors.white,fontSize: 20),),
                        ),
                      ),
                    )
                  ],
                )
            ),
          ],
        ),

      ),
    );
  }
}
class MyOrder{
  String orderNo,itemName,totalAmount,status,imageUrl,sellerID,sellerPhone;
  Timestamp date;
  MyOrder(this.orderNo,this.itemName,this.date,this.totalAmount,this.status,this.imageUrl,this.sellerID,this.sellerPhone);
}