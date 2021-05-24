import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Color(0xff44a7c4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff44a7c4),
      ),
      body: RefreshIndicator(
        onRefresh: getMyOrders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment(1,-1),
                child: Text("My Orders",
                  style: Theme.of(context).textTheme.headline3.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment(1,-9),
              child: Container(
                width: size.width * 0.65,
                height: 5,
                color: Colors.lightGreenAccent,
              ),
            ),
            Expanded(
                child:process==true?
                Center(child: CircularProgressIndicator()):ListView.builder(itemCount: list.length,
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text("Order No: " + orderNo,
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(date.toDate().day.toString() + ":" + date.toDate().month.toString() + ":" + date.toDate().year.toString(),
                    style: TextStyle(fontSize: 15),
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15,top: 15),
                  child: Text("Item Name: ",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(itemId,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10,top: 20),
                  child: Text("Total Amount: ",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20,right: 10,bottom: 10),
                  child: Text("₹" + price,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: GestureDetector(
                //     onTap: (){},
                //     child: Container(
                //       // margin: EdgeInsets.only(right: 15),
                //       height: 45,
                //       width: 130,
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(26),
                //           border: Border.all(
                //             color: Colors.black,
                //           )
                //       ),
                //         child: Center(child: Text("Details",
                //           style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                //         )),
                //       ),
                //   )
                //   ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(status,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ExpandChild(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: size.width * 0.75,
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