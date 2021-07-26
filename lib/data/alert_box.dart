import 'package:flutter/material.dart';
import 'package:flutter_button/3d/3d_button.dart';

class CustomAlertBox extends StatelessWidget {
  final String warning;
  final VoidCallback callback;

  const CustomAlertBox({Key key, this.warning, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(child: Icon(Icons.warning_amber_outlined,size: 30,color: Colors.black,),backgroundColor: Colors.black12,),
          SizedBox(width: 20,),
          Text(warning)
        ],
      ),
      actions: [
        ElevatedButton(onPressed: callback, child: Text("Yes"),style: ElevatedButton.styleFrom(primary: Colors.green),),
        ElevatedButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text("No"),style: ElevatedButton.styleFrom(primary: Colors.red),),
      ],
    );
  }
}
