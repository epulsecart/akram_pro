import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ExitAlertMessage(BuildContext context) {

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Color(0xFFF2F2F2),
    content: Container(
      alignment: Alignment.center,
      width: 300,
      height:120,
      child:Text('هل تريد الخروج؟',
        style: TextStyle(fontSize: 20),
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: const Text('لا',style: TextStyle(fontSize: 20,color: Colors.black),),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text('نعم',style: TextStyle(fontSize: 20,color: Colors.black),),
        onPressed: () async {
          SystemNavigator.pop();
        },
      ),
    ],
  );
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}