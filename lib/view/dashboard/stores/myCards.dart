// @dart=2.9
import 'dart:io';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/controller/myCards.dart';
import 'package:storeapp/controller/share.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:storeapp/view/colors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:storeapp/controller/printer.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter/material.dart';

import '../../../database/userinfoDatabase.dart';

class myCards extends StatefulWidget {
  myCardsState createState() => myCardsState();
}

class myCardsState extends State  {

  static const platform =  MethodChannel("com.cybitsec.souqcardstoreapp/text");
  var showLoading = false;
  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future getTheDataVar;

  var checkConnection = "";

  connectToPrinter () async {
    var printerClass = new printer();
    checkConnection = await printerClass.connectToPrinter();

    setState(() {
      checkConnection = checkConnection;
    });
  }
  @override
  void initState() {
    super.initState();

    getTheDataVar = getMyCards(false);

    connectToPrinter();

    getUserTextSize();
  }

  getUserTextSize () async {
    var getSize = await userInfo.getUserTextSize();

    if (getSize == "empty") {
      textSize = 14;
    } else {
      textSize = int.parse(getSize);
    }
  }


  DateTime selectedDateFrom = DateTime.now();

  Future<Null> _selectDateFrom(BuildContext context, whichDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateFrom)
      setState(() {
        selectedDateFrom = picked;
      });
  }

  DateTime selectedDateTo = DateTime.now();
  Future<Null> _selectDateTo(BuildContext context, whichDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateTo)
      setState(() {
        selectedDateTo = picked;
      });
  }


  /* Get Data */
  List getMyCardsFun = [];
  var ifNoCards = '';

  myCardsController cardsClass = new myCardsController();

  getMyCards (withDate) async {

    var getMyCardsData;
    if (withDate == true) {
      getMyCardsData = await cardsClass.getMyCards(myCards_dateFrom: selectedDateFrom, myCards_dateTo: selectedDateTo);
    } else {
      getMyCardsData = await cardsClass.getMyCards();
    }



    setState(() {
      getMyCardsFun = getMyCardsData;

      if (getMyCardsData.length == 0) {
        ifNoCards = "لا توجد مشتريات";
      } else {
        ifNoCards = "";
      }
    });

    return getMyCardsData;
  }



  printCart(BuildContext context, index) async {
    print("printer");
    print(checkConnection);

    if (checkConnection == "notconnected") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("لست متصل بطابعة"),
        duration: Duration(seconds: 2),
      ));
    } else if (checkConnection == "connected") {
      setState(() {
        showLoading = true;
      });
      showLoadingFun(context);

      /*var shippingMethod = "";
      var getShippingMethod = await FirebaseFirestore.instance
          .collection('shippingCompanies')
          .where("shippingCompanies_id", isEqualTo: getMyCardsFun[index]['card_productCompanyId'])
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          shippingMethod = doc['shippingCompanies_method'];
        });
      });*/

      var company = await FirebaseFirestore.instance
          .collection('companies')
          .doc(getMyCardsFun[index]['card_productCompanyId'])
          .get();

      var shippingMethod = "";
      shippingMethod = company.get("companies_shippingCompanyMethod");

      try {
        var value = await platform.invokeMethod('print', {
          "companyImage": getMyCardsFun[index]['card_productCompanyPrintingImage'],
          "textSize": textSize,
          "productName": getMyCardsFun[index]['card_productName'],
          "productNumber": getMyCardsFun[index]['card_cardNumber'],
          "productSerial": getMyCardsFun[index]['card_cardSerial'],
          "product_broughtDate": getMyCardsFun[index]['card_broughtDate'],
          "product_expiryDate": getMyCardsFun[index]['card_expiryDate'],
          "product_shippingMethod": shippingMethod,
        });
      } on PlatformException catch (e) {
       
      }


      setState(() {
        showLoading = false;
      });
      showLoadingFun(context);
    }

  }

  userinfoDatabase userInfo = new userinfoDatabase();

  var textSize = 14;
  quantityPlusMinusTextSize(sign) {
    setState(() {
      if(sign == '+'){
        if (textSize >= 50) {

        } else {
          textSize = textSize + 1;

          userInfo.updateUserTextSize(size: textSize.toString());
        }
      }
      else {
        if (textSize <= 1) {
          textSize = 1;
          userInfo.updateUserTextSize(size: textSize.toString());
        }
        else {
          textSize = textSize - 1;
          userInfo.updateUserTextSize(size: textSize.toString());
        }
      }
    });

  }

  showLoadingFun(BuildContext context) {
    if (showLoading) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    } else {
      Navigator.pop(context);

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: asideMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: MenuBar(),
      ),
      bottomNavigationBar: bottomBar(context),
      body: SingleChildScrollView(
          controller: scrolling.returnTheVariable(),
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 0), // (MediaQuery.of(context).size.height / 2)
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: Column(
              children: [

                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "مشترياتي",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                Container(
                    margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("${selectedDateFrom.toLocal()}".split(' ')[0]),
                            SizedBox(height: 20.0,),
                            Container(
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () => _selectDateFrom(context, "from"),
                                child: Text('من تاريخ', style: TextStyle(color: Colors.white,),),
                                color: mainColor,
                              ),

                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: 20,
                      ),

                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("${selectedDateTo.toLocal()}".split(' ')[0]),
                            SizedBox(height: 20.0,),
                            Container(
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () => _selectDateTo(context, "to"),
                                child: Text('إلى تاريخ', style: TextStyle(color: Colors.white,),),
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      getMyCards(true);
                    },
                    child: Text('بحث', style: TextStyle(color: Colors.white,),),
                    color: mainColor,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      getMyCards(false);
                    },
                    child: Text('عرض جميع مشترياتي', style: TextStyle(color: Colors.white,),),
                    color: mainColor,
                  ),
                ),

                Container(
                  child: Text('حجم خط الطابعة', style: TextStyle(color: mainColor,),),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10,),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          quantityPlusMinusTextSize('+',);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 25,
                          child: Text('+',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: HexColor("#F65D12")
                          ),
                        ),
                      ),
                      // Quantity
                      Container(
                        height: 25,
                        width: 25,
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: HexColor("#C0A7C1")),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(textSize.toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
                      ),
                      GestureDetector(
                        onTap: () {
                          quantityPlusMinusTextSize('-',);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 25,
                          child: Text('-',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: HexColor("#F65D12")
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: Text(ifNoCards,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.right
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(

                      onPressed: () async {
                        setState(() {
                          showLoading = true;
                        });
                        showLoadingFun(context);

                        await getMyCards(false);

                        setState(() {
                          showLoading = false;
                        });
                        showLoadingFun(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

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
                            children: getMyCardsFun.map((item) {
                              return new Container(
                                decoration: BoxDecoration(
                                  color: HexColor("#F2F2F2"),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                padding: EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
                                margin: EdgeInsets.only(bottom: 20),
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                child: Text("الشركة: " + item['card_productCompany'],
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("المنتج: " + item['card_productName'],
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text(":السيريل \n " + item['card_cardSerial'], textDirection: TextDirection.ltr, textAlign: TextAlign.right,
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text(":رقم الكارت \n " + item['card_cardNumber'], textDirection: TextDirection.ltr, textAlign: TextAlign.right,
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)),
                                              ),
                                              Container(
                                                child: Text("تاريخ الإنتهاء: " + item['card_expiryDate'],
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("القيمة: " + item['card_BroughtPrice'] + " SAR",
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          width: 10,
                                        ),

                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                child: Text(item['card_broughtDate'],
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text(" \nالرصيد السابق: " + double.parse(item['card_balanceBefore']).toStringAsFixed(2).toString(),
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("الرصيد الحالي:  \n" + double.parse(item['card_balanceAfter']).toStringAsFixed(2).toString(),
                                                    style: TextStyle(color: HexColor("#4A4A4A"), fontSize: 14, fontWeight: FontWeight.bold)
                                                ),
                                              ),

                                              Container(
                                                width: double.infinity,
                                                margin: EdgeInsets.only(top: 10),
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  onPressed: () {
                                                    printCart(context, getMyCardsFun.indexOf(item));
                                                  },
                                                  color: mainColor,
                                                  child: Text('طباعة', style: TextStyle(color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),

                                    Container(
                                      //color: mainColor,
                                      //alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                          color: mainColor,
                                          shape: BoxShape.circle
                                      ),
                                      child: IconButton(
                                        alignment: Alignment.center,
                                        icon: const Icon(Icons.share, size: 30, color: Colors.white),
                                        onPressed: () {
                                          sharingData(context, "اسم الشركة: " + item['card_productCompany'] + "\nإسم المنتج: " + item['card_productName'] + "\nرقم الكارت: \n" + item['card_cardNumber'].toString().split(" ").join("") + "\nالسريال: \n" + item['card_cardSerial'].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + item['card_expiryDate'],
                                              "اسم الشركة: " + item['card_productCompany'] + "\nإسم المنتج: " + item['card_productName'] + "\nرقم الكارت: \n" + item['card_cardNumber'].toString().split(" ").join("") + "\nالسريال: \n" + item['card_cardSerial'].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + item['card_expiryDate']);
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              );
                            }).toList()
                        ),
                      );
                    }
                  },
                ),

                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(

                      onPressed: () async {
                        setState(() {
                          showLoading = true;
                        });
                        showLoadingFun(context);

                        await getMyCards(false);

                        setState(() {
                          showLoading = false;
                        });
                        showLoadingFun(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

