// @dart=2.9
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';


class printerPage extends StatefulWidget {
  @override
  printerState createState() => printerState();
}

class printerState extends State {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const platform =  MethodChannel("com.cybitsec.souqcardstoreapp/text");
  var _device;
  int index;
  var printerAddress;
  var catchErrorDisplay = "taha";

  getPrinterName () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var printerName = await userInfo.getPrinterName();

    var getPrinterAddress = await userInfo.getPrinterAddress();

    setState(() {
      _device = printerName;
      printerAddress = getPrinterAddress;
    });
  }

  @override
  void initState() {
    super.initState();
    getPrinterName();

    getTheDataVar = getBlueToothDevices();

   // getTest();
  }

  String test = "";
  getTest () async {
    var getText = await FirebaseFirestore.instance
        .collection('shippingCompanies')
        .doc("UQwLAHTqa0Gz7UNqQ8Yk")
        .get();

    setState(() {
      test = getText.get("shippingCompanies_method");
    });
  }

  showText() async {
    String value;
    try {
      value = await platform.invokeMethod('getText');
    } on PlatformException catch (e) {
      setState(() {
        catchErrorDisplay = e.message.toString();
      });
    }
  }

  connectToPrinter () async {
    String value;
    try {
      value = await platform.invokeMethod('connectToPrinter',{"printerAddress": printerAddress});

      if (value.toString() == "connect") {
        userinfoDatabase userInfo = new userinfoDatabase();
        await userInfo.updatePrinterAddress(printerAddress: printerAddress);
        await userInfo.updatePrinterName(printerName: _device);

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("تم الإتصال"),
          duration: Duration(seconds: 2),
        ));
      }

    } on PlatformException catch (e) {
      setState(() {
        catchErrorDisplay = e.message.toString();
      });
    }
  }

  Print() async {
    String value;
    try {
      value = await platform.invokeMethod('print', {"companyImage": "getProducts[index]['product_image']",
        "productName": "getProducts[index]['product_name']",
        "productNumber": "buyTheCards['saveCradsNumbers'][0]",
        "productSerial": "buyTheCards['saveCradsSerial'][0]",
        "product_expiryDate": "getProducts[index]['product_expiryDate']",
        "product_shippingMethod": "shippingMethod",});
      /*
      *  {
        "companyImageUrl": "",
        "companyName": "كويك نت 10 جيغا لمدة 3 شهور",
        "price": "201.25",
        "cardNumber": "2281 9200 496304",
        "expiryDate": "2022-03-08 00:24:19",
        "serialNumber": "11612346040",
        "shippingMethod": "طريق الشحن: تطبيق mystc"
      }
      * */
    } on PlatformException catch (e) {
      setState(() {
        catchErrorDisplay = e.message.toString();
      });
    }
  }

  Future getTheDataVar;
  List blueToothDevices = [];
  List blueToothDevicesAddress = [];
  getBlueToothDevices () async {
    blueToothDevices = [];
    var data;

    try {
      data = await platform.invokeMethod('getBlueToothDevices');

      if (data.toString() == "empty") {
        //blueToothDevices = [];
      } else {

          var taha = [];

          for (int i = 0; i < data.length; i = i + 1) {
            blueToothDevices.add(data[i].toString().split("--")[0]);
            blueToothDevicesAddress.add(data[i].toString().split("--")[1]);
          }
          setState(() {
            blueToothDevices = blueToothDevices;
            blueToothDevicesAddress = blueToothDevicesAddress;
          });

      }



    } on PlatformException catch (e) {
      setState(() {
        catchErrorDisplay = e.message.toString();
      });
    }

    if (data.toString() == "empty") {
      return null;
    }

    return blueToothDevices;
  }



  var catchingError = "taha";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: asideMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MenuBar(),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: getTheDataVar,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 50),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container(
                            child: Column(
                              children: blueToothDevices.map((d) {
                                return ListTile(
                                  title: Text(d),
                                  subtitle: Text(d),
                                  onTap: () async {
                                    setState(() {
                                      _device = d;
                                      index = blueToothDevices.indexOf(d);
                                      printerAddress = blueToothDevicesAddress[blueToothDevices.indexOf(d)];
                                    });
                                  },
                                  trailing: _device!=null && _device == d?Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ):null,
                                );
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),


                    Row(
                      children: [
                        OutlinedButton(
                          child: Text('Connect'),
                          onPressed: () {
                            connectToPrinter();
                          },
                        ),

                        SizedBox(
                          width: 30,
                        ),

                        OutlinedButton(
                          child: Text('Print'),
                          onPressed: () {
                            Print();
                          },
                        ),
                      ],
                    ),

                    Container(
                      child: Text(catchErrorDisplay.toString()),
                    )

                  ],
                ),
              )
            ],
          ),
      ),
    );
  }
}

class bluetoothDevicesClass {
  String name;
  String address;
}