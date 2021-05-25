import 'package:flutter/material.dart';


class BetaTesting extends StatelessWidget {
  const BetaTesting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Center(
            child: Text("Thank you the beta testing is over now.",style: TextStyle(fontSize: 30,color: Colors.black),),
          ),
        ),
      ),
    );
  }
}
