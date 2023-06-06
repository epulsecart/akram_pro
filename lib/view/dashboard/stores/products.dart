// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';
import 'package:storeapp/providers/products.dart';

class products extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String companyImage;

  products({
    this.companyId,
    this.companyName,
    this.companyImage,
  });

  @override
  productsState createState() => productsState(
        companyId: companyId,
        companyName: companyName,
        companyImage: companyImage,
      );
}

class productsState extends State {
  static const platform = MethodChannel("com.cybitsec.souqcardstoreapp/text");
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  final String companyId;
  final String companyName;
  final String companyImage;

  productsState({
    this.companyId,
    this.companyName,
    this.companyImage,
  });

  ScrollToTop scrolling = ScrollToTop();

  FirebaseMessaging messaging;

  // Future getTheDataVar;
  @override
  void initState() {
    super.initState();

    // getTheDataVar = Provider;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ProductsProvider>(context, listen: false)
          .getProductsFun(companyId, context);
      Provider.of<ProductsProvider>(context, listen: false).getUserTextSize();
    });
  }
  //
  // getUserTextSize () async {
  //   var getSize = await userInfo.getUserTextSize();
  //
  //   if (getSize == "empty") {
  //     textSize = 14;
  //   } else {
  //     textSize = int.parse(getSize);
  //   }
  // }

  // var showLoadingSimple = false;
  // showLoadingFunSimple(BuildContext context) {
  //   if (Provider.of<ProductsProvider>(context, listen: false).showLoadingSimple) {
  //     return showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         });
  //   } else {
  //     Navigator.pop(context);
  //
  //     return;
  //   }
  // }

  // var showLoading = false;
  // showLoadingFun(BuildContext context) {
  //   if (Provider.of<ProductsProvider>(context, listen: false).showLoading) {
  //     return showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return Center(
  //             child: Image.asset("assets/images/cardLoading.gif", width: 280, height: 280, fit: BoxFit.cover,),
  //           );
  //         });
  //   } else {
  //     Navigator.pop(context);
  //
  //     return;
  //   }
  // }

  //
  // List getProducts = [];
  // var noData = Container();
  // bool check = false;
  // getProductsFun () async {
  //   productsCartsController getProductsClass = new productsCartsController(productsCartsController_companyId: companyId);
  //   // var getProductsForDisplay = await getProductsClass.getProducts();
  //   var getProductsForDisplay = await getProductsClass.getCardsForSpecificProductsAfterStoresPutsDifference();
  //
  //   if (getProductsForDisplay["status"] == "available") {
  //     setState(() {
  //       check = true;
  //       getProducts = getProductsForDisplay["data"];
  //     });
  //
  //     return getProducts;
  //   } else {
  //     setState(() {
  //       check = false;
  //       noData = Container(
  //         alignment: Alignment.center,
  //         padding: EdgeInsets.only(left: 15, right: 15),
  //         child: Text("لاتوجد منتجات متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
  //       );
  //     });
  //
  //     return check;
  //   }
  // }
  //
  //
  // userinfoDatabase userInfo = new userinfoDatabase();
  // var textSize = 14;
  // quantityPlusMinusTextSize(sign, state) {
  //   state(() {
  //       if(sign == '+'){
  //         if (textSize >= 50) {
  //
  //         } else {
  //           textSize = textSize + 1;
  //           userInfo.updateUserTextSize(size: textSize.toString());
  //         }
  //       }
  //       else {
  //         if (textSize <= 1) {
  //           textSize = 1;
  //           userInfo.updateUserTextSize(size: textSize.toString());
  //         }
  //         else {
  //           textSize = textSize - 1;
  //           userInfo.updateUserTextSize(size: textSize.toString());
  //         }
  //       }
  //   });
  //
  // }

  // var countItemsArr= [];
  // quantityPlusMinus(index, sign, hasOtherState, state) {
  //   _getSize();
  //   if (hasOtherState == true) {
  //     state(() {
  //       if(sign == '+'){
  //         if (countItemsArr[index] >= 5) {
  //
  //         } else {
  //           countItemsArr[index] = countItemsArr[index] + 1;
  //           getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
  //         }
  //
  //       }
  //       else {
  //         if (countItemsArr[index] <= 1) {
  //           countItemsArr[index] = 1;
  //           getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
  //         }
  //         else {
  //           countItemsArr[index] = countItemsArr[index] - 1;
  //
  //           if (countItemsArr[index] == 1) {
  //             getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
  //           } else {
  //             getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
  //           }
  //
  //         }
  //       }
  //     });
  //   } else {
  //     setState(() {
  //       if(sign == '+'){
  //         if (countItemsArr[index] >= 5) {
  //
  //         } else {
  //           countItemsArr[index] = countItemsArr[index] + 1;
  //           getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
  //         }
  //       }
  //       else {
  //         if (countItemsArr[index] <= 1) {
  //           countItemsArr[index] = 1;
  //           getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
  //         }
  //         else {
  //           countItemsArr[index] = countItemsArr[index] - 1;
  //
  //           if (countItemsArr[index] == 1) {
  //             getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
  //           } else {
  //             getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
  //           }
  //
  //         }
  //       }
  //     });
  //   }
  //
  // }

  // final GlobalKey<ScaffoldState> _scaffoldkeyValidate = new GlobalKey<ScaffoldState>();

  // validateAndCheck(BuildContext context, index) async {
  //
  //   final companyEditName = TextEditingController();
  //
  //   var displayCards = null;
  //
  //   List displayCardsNumbers = [];
  //   List displayCardsSerials = [];
  //   List displayCardsDate = [];
  //
  //   var myState;
  //
  //   var mainQuantity = countItemsArr[index];
  //   var mainPrice = getProducts[index]['product_price'];
  //   var buyResult = "";
  //
  //   var printerClass = new printer();
  //   var checkConnection = await printerClass.connectToPrinter();
  //
  //   var shippingMethod = "";
  //   var getCompanyImage = "";
  //   var getCompanyName = "";
  //
  // //  var checkConnection = "connected";
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     child: Text("إلغاء", style: TextStyle(color: HexColor("#F65D12"),),),
  //     onPressed:  () {
  //
  //       setState(() {
  //         countItemsArr[index] = mainQuantity;
  //         getProducts[index]['product_price'] = mainPrice;
  //       });
  //
  //       myState(() {
  //         buyResult = "";
  //       });
  //
  //       Navigator.pop(context);
  //     },
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text("تأكيد الشراء", style: TextStyle(color: HexColor("#F65D12"),),),
  //     onPressed:  () async {
  //       print("now buying ${DateTime.now().toString()}");
  //       setState(() {
  //         showLoading = true;
  //       });
  //       showLoadingFun(context);
  //
  //       productsCartsController card = new productsCartsController(productsCartsController_productId: getProducts[index]['docid'], productsCartsController_howmany: countItemsArr[index].toString());
  //       var buyTheCards = await card.buyCard2();
  //       print("now got the result ${DateTime.now().toString()}");
  //         myState(() {
  //           displayCards = buyTheCards;
  //           displayCardsNumbers = buyTheCards['saveCradsNumbers'];
  //           displayCardsSerials = buyTheCards['saveCradsSerial'];
  //           displayCardsDate = buyTheCards['saveCardsExpiryDate'];
  //           print("displayCards");
  //           print(displayCards);
  //         });
  //
  //         print ("getting the company details ${DateTime.now().toString()}");
  //       if (buyTheCards['status'] == "success") {
  //         var company = await FirebaseFirestore.instance
  //             .collection('companies')
  //             .doc(companyId)
  //             .get();
  //         print ("got the company details ${DateTime.now().toString()}");
  //
  //         shippingMethod = company.get("companies_shippingCompanyMethod");
  //
  //         getCompanyImage = company.get("companies_printinglogo");
  //
  //         getCompanyName = company.get("companies_name");
  //
  //         myState(() {
  //           buyResult = "تم الشراء يمكنك الطباعة";
  //         });
  //
  //       //  var printerClass = new printer();
  //        // var checkConnection = await printerClass.connectToPrinter();
  //         if (checkConnection == "notconnected") {
  //           // myState(() {
  //           //   buyResult = "تم الشراء لست موصول بالطابعة";
  //           // });
  //         }
  //         else if (checkConnection == "connected") {
  //
  //           for (var i = 0; i < countItemsArr[index]; i = i + 1) {
  //             try {
  //               var value = await platform.invokeMethod('print', {
  //                 "companyImage": getCompanyImage,
  //                 "productName": getProducts[index]['product_name'],
  //                 "textSize": textSize,
  //                 "productNumber": buyTheCards['saveCradsNumbers'][i],
  //                 "product_broughtDate": buyTheCards["broughtDate"],
  //                 "productSerial": buyTheCards['saveCradsSerial'][i],
  //                 "product_expiryDate": getProducts[index]['product_expiryDate'],
  //                 "product_shippingMethod": shippingMethod,
  //               });
  //             } on PlatformException catch (e) {
  //
  //             }
  //           }
  //           myState(() {
  //             buyResult = "تم الشراء وتمت الطباعة";
  //           });
  //
  //
  //         }
  //       } else if (buyTheCards['status'] == "userNotActive") {
  //         myState(() {
  //           buyResult = "تم الغاء تفعيل حسابك";
  //         });
  //       } else if (buyTheCards['status'] == "userNotExist") {
  //         myState(() {
  //           buyResult = "تم حذفك";
  //         });
  //       } else if (buyTheCards['status'] == "needMoreBalance") {
  //         myState(() {
  //           buyResult = "الرصيد غير كافي";
  //         });
  //       } else if (buyTheCards['status'] == "notAvailableQuantity") {
  //         myState(() {
  //           buyResult = "الكمية غير متوفرة";
  //         });
  //       } else if (buyTheCards['status'] == "lessThenZero") {
  //         myState(() {
  //           buyResult = "الكمية أصغر من صفر";
  //         });
  //       } else if (buyTheCards['status'] == "myStoreOfStoreNotExist") {
  //         myState(() {
  //           buyResult = "المندوب الخاص بك ليس موجود";
  //         });
  //       }else {
  //         myState(() {
  //           buyResult = buyTheCards['status'];
  //         });
  //       }
  //       setState(() {
  //         showLoading = false;
  //       });
  //       showLoadingFun(context);
  //       print("now loading will finish ${DateTime.now().toString()}");
  //       if (buyTheCards['status'] == "success") {
  //         setState(() {
  //           myBalance["store_totalBalance"] = buyTheCards["newTotalBalance"];
  //         });
  //         //Navigator.pop(context);
  //
  //         _scaffoldKey.currentState.showSnackBar(SnackBar(
  //           content: Text("تم تحديث الرصيد"),
  //           duration: Duration(seconds: 2),
  //         ));
  //       }
  //      // Navigator.pop(context);
  //     },
  //   );
  //
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     backgroundColor: HexColor("#1B1B1D"),
  //     title: Container(
  //       padding: EdgeInsets.all(6),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(width: 1.0, color: Colors.white),
  //       ),
  //       child: Text(getProducts[index]['product_name'], style: TextStyle(fontSize: 16,color: Colors.white,),),
  //     ),
  //     content: StatefulBuilder(
  //         key: _scaffoldkeyValidate,
  //         builder: (BuildContext context, StateSetter state) {
  //           myState = state;
  //
  //
  //           return SingleChildScrollView(
  //               child: Container(
  //                 child: Column(
  //                   children: [
  //
  //                     Container(
  //                       margin: EdgeInsets.only(bottom: 15),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             flex: 5,
  //                             child: Row(
  //                               children: [
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     quantityPlusMinus(index, '+', true, state);
  //                                   },
  //                                   child: Container(
  //                                     alignment: Alignment.center,
  //                                     height: 25,
  //                                     width: 25,
  //                                     child: Text('+',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
  //                                     decoration: BoxDecoration(
  //                                         borderRadius: BorderRadius.circular(30.0),
  //                                         color: HexColor("#F65D12")
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 // Quantity
  //                                 Container(
  //                                   height: 25,
  //                                   width: 25,
  //                                   margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                                   decoration: BoxDecoration(
  //                                     border: Border.all(color: HexColor("#C0A7C1")),
  //                                     borderRadius: BorderRadius.circular(5),
  //                                   ),
  //                                   alignment: Alignment.center,
  //                                   child: Text(countItemsArr[index].toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
  //                                 ),
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     quantityPlusMinus(index, '-', true, state);
  //                                   },
  //                                   child: Container(
  //                                     alignment: Alignment.center,
  //                                     height: 25,
  //                                     width: 25,
  //                                     child: Text('-',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
  //                                     decoration: BoxDecoration(
  //                                         borderRadius: BorderRadius.circular(30.0),
  //                                         color: HexColor("#F65D12")
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //
  //                           Expanded(
  //                             flex: 5,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               margin: EdgeInsets.only(right: 5,),
  //                               padding: EdgeInsets.only(top: 5, bottom: 5),
  //                               child: Text(getProducts[index]["product_price"] + " SAR", textDirection: TextDirection.ltr, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12,color: Colors.white,)),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(5),
  //                                 border: Border.all(width: 1.0, color: Colors.white),
  //                                 //borderRadius: BorderRadius.circular(30.0),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Container(
  //                       alignment: Alignment.centerRight,
  //                       margin: EdgeInsets.only(right: 5, bottom: 10),
  //                       child: Text("تنبيه : سيتم خصم المبلغ من رصيدك تأكد من العدد الصحيح", style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12, color: HexColor("#F65D12"),)),
  //                     ),
  //                     Container(
  //                       alignment: Alignment.centerRight,
  //                       margin: EdgeInsets.only(right: 5, bottom: 10),
  //                       child: Text(buyResult, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 16, color: Colors.white,)),
  //                     ),
  //
  //                     displayCardsNumbers.length != 0?
  //                     Container(
  //                       alignment: Alignment.centerRight,
  //                       margin: EdgeInsets.only(bottom: 10,),
  //                       child: Text('حجم خط الطابعة', style: TextStyle(color: HexColor("#F65D12"),),),
  //                     ) : Text(""),
  //
  //                     displayCardsNumbers.length != 0?
  //                         Container(
  //                           margin: EdgeInsets.only(bottom: 10,),
  //                           child: Row(
  //                             children: [
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   quantityPlusMinusTextSize('+', state);
  //                                 },
  //                                 child: Container(
  //                                   alignment: Alignment.center,
  //                                   height: 25,
  //                                   width: 25,
  //                                   child: Text('+',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(30.0),
  //                                       color: HexColor("#F65D12")
  //                                   ),
  //                                 ),
  //                               ),
  //                               // Quantity
  //                               Container(
  //                                 height: 25,
  //                                 width: 25,
  //                                 margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                                 decoration: BoxDecoration(
  //                                   border: Border.all(color: HexColor("#C0A7C1")),
  //                                   borderRadius: BorderRadius.circular(5),
  //                                 ),
  //                                 alignment: Alignment.center,
  //                                 child: Text(textSize.toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
  //                               ),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   quantityPlusMinusTextSize('-', state);
  //                                 },
  //                                 child: Container(
  //                                   alignment: Alignment.center,
  //                                   height: 25,
  //                                   width: 25,
  //                                   child: Text('-',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(30.0),
  //                                       color: HexColor("#F65D12")
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ) : Text(""),
  //
  //                     displayCardsNumbers.length != 0?
  //                     Container(
  //                       margin: EdgeInsets.only(bottom: 10,),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         //   mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           SizedBox(
  //                             width: 70,
  //                             child: RaisedButton(
  //                               padding: EdgeInsets.all(0),
  //                               child: Text('طباعة الكل',
  //                                 style: TextStyle(color: Colors.white, fontSize: 12,),),
  //                               color: HexColor("#F65D12"),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius
  //                                     .circular(10),
  //                               ),
  //                               onPressed: () async {
  //                                 print("displayCards");
  //                                 print(displayCards);
  //
  //                                 print("getCompanyImage");
  //                                 print(getCompanyImage);
  //
  //                                 print("shippingMethod");
  //                                 print(shippingMethod);
  //
  //                                 if (checkConnection == "notconnected") {
  //                                   myState(() {
  //                                     buyResult = "لست متصل بالطابعة";
  //                                   });
  //                                 } else if (checkConnection == "connected") {
  //
  //                                   setState(() {
  //                                     showLoadingSimple = true;
  //                                   });
  //                                   showLoadingFunSimple(context);
  //
  //                                   for (var i = 0; i < countItemsArr[index]; i = i + 1) {
  //                                     try {
  //                                       var value = await platform.invokeMethod('print', {
  //                                         "companyImage": getCompanyImage,
  //                                         "textSize": textSize,
  //                                         "productName": getProducts[index]['product_name'],
  //                                         "productNumber": displayCards['saveCradsNumbers'][i],
  //                                         "product_broughtDate": displayCards["broughtDate"],
  //                                         "productSerial": displayCards['saveCradsSerial'][i],
  //                                         "product_expiryDate": displayCards['saveCardsExpiryDate'][i],
  //                                         "product_shippingMethod": shippingMethod,
  //                                       });
  //                                     } on PlatformException catch (e) {
  //
  //                                     }
  //                                   }
  //                                   myState(() {
  //                                     buyResult = "تم الشراء وتمت الطباعة";
  //                                   });
  //
  //                                   setState(() {
  //                                     showLoadingSimple = false;
  //                                   });
  //                                   showLoadingFunSimple(context);
  //
  //
  //                                 }
  //                               },
  //                             ),
  //                           ),
  //
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //
  //                           SizedBox(
  //                             width: 70,
  //                             child: RaisedButton(
  //                               padding: EdgeInsets.all(0),
  //                               child: Text('مشاركة الكل',
  //                                 style: TextStyle(color: Colors.white, fontSize: 10,),),
  //                               color: HexColor("#F65D12"),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius
  //                                     .circular(10),
  //                               ),
  //                               onPressed: () async {
  //
  //                                 var textData = "";
  //
  //                                 for (var i = 0; i < countItemsArr[index]; i = i + 1) {
  //                                   textData = textData + "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][i].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][i].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][i] + " \n \n \n --------------- \n \n \n ";
  //                                 }
  //
  //                                 print(textData);
  //
  //                                 sharingData(context, textData,
  //                                     textData);
  //                               },
  //                             ),
  //                           )
  //
  //
  //                         ],
  //                       ),
  //                     ):Container(child: Text(""),),
  //
  //                     // Display The Cards
  //                     Container(
  //                       alignment: Alignment.centerRight,
  //                       margin: EdgeInsets.only(right: 5, ),
  //                       child: Column(
  //                         children: displayCardsNumbers.length != 0?displayCardsNumbers.map((item) {
  //
  //                           return Container(
  //                             child: Column(
  //                               children: [
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 5, ),
  //                                   child: Text("رقم البطاقة:", style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 10, ),
  //                                   child: Text(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 5, ),
  //                                   child: Text("سيريل البطاقة:", style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 10, ),
  //                                   child: Text(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 5, ),
  //                                   child: Text("تاريخ الإنتهاء:", style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //                                 Container(
  //                                   alignment: Alignment.centerRight,
  //                                   margin: EdgeInsets.only(bottom: 10, ),
  //                                   child: Text(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)], style: TextStyle(color: Colors.white, fontSize: 14,),),
  //                                 ),
  //
  //
  //                                 Row(
  //                                   mainAxisAlignment: MainAxisAlignment.end,
  //                                  //   mainAxisSize: MainAxisSize.min,
  //                                     children: [
  //                                       SizedBox(
  //                                         width: 70,
  //                                         child: RaisedButton(
  //                                           padding: EdgeInsets.all(0),
  //                                           child: Text('طباعة',
  //                                             style: TextStyle(color: Colors.white, fontSize: 10,),),
  //                                           color: HexColor("#F65D12"),
  //                                           shape: RoundedRectangleBorder(
  //                                             borderRadius: BorderRadius
  //                                                 .circular(10),
  //                                           ),
  //                                           onPressed: () async {
  //                                             setState(() {
  //                                               showLoadingSimple = true;
  //                                             });
  //                                             showLoadingFunSimple(context);
  //
  //                                             /*print("getCompanyImage");
  //                                               print(getCompanyImage);
  //
  //                                               print("getProducts[index]['product_name']");
  //                                               print(getProducts[index]['product_name']);
  //
  //                                               print("displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]");
  //                                               print(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]);
  //
  //                                               print("displayCards['broughtDate']");
  //                                               print(displayCards["broughtDate"]);
  //
  //                                               print("displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]");
  //                                               print(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]);
  //
  //                                               print("displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]");
  //                                               print(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);
  //
  //                                               print("shippingMethod");
  //                                               print(shippingMethod);*/
  //
  //                                             if (checkConnection == "notconnected") {
  //                                               myState(() {
  //                                                 buyResult = "لست متصل بالطابعة";
  //                                               });
  //                                             } else if (checkConnection == "connected") {
  //                                               try {
  //                                                 var value = await platform.invokeMethod('print', {
  //                                                   "companyImage": getCompanyImage,
  //                                                   "textSize": textSize,
  //                                                   "productName": getProducts[index]['product_name'],
  //                                                   "productNumber": displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)],
  //                                                   "product_broughtDate": displayCards["broughtDate"],
  //                                                   "productSerial": displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)],
  //                                                   "product_expiryDate": displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
  //                                                   "product_shippingMethod": shippingMethod,
  //                                                 });
  //                                               } on PlatformException catch (e) {
  //
  //                                               }
  //                                             }
  //
  //                                             setState(() {
  //                                               showLoadingSimple = false;
  //                                             });
  //                                             showLoadingFunSimple(context);
  //                                           },
  //                                         ),
  //                                       ),
  //
  //                                       SizedBox(
  //                                         width: 10,
  //                                       ),
  //
  //                                       SizedBox(
  //                                         width: 70,
  //                                         child: RaisedButton(
  //                                           padding: EdgeInsets.all(0),
  //                                           child: Text('مشاركة',
  //                                             style: TextStyle(color: Colors.white, fontSize: 10,),),
  //                                           color: HexColor("#F65D12"),
  //                                           shape: RoundedRectangleBorder(
  //                                             borderRadius: BorderRadius
  //                                                 .circular(10),
  //                                           ),
  //                                           onPressed: () async {
  //                                             sharingData(context, "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
  //                                                 "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);
  //                                           },
  //                                         ),
  //                                       )
  //
  //
  //                                     ],
  //                                   ),
  //
  //                               ]
  //                             ),
  //                           );
  //                         }).toList(): [],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //         }),
  //
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //       /*return Stack(
  //         children: [
  //
  //           alert,
  //           Positioned(
  //             bottom: 0,
  //             left: 0,
  //             right: 0,
  //             top: 0,
  //             child: Container(
  //               width: 100.0,
  //               height: 80.0,
  //               decoration: new BoxDecoration(color: Colors.red),
  //               child: new Text('hello'),
  //             ),
  //           ),
  //         ],
  //       );*/
  //     },
  //   );
  // }

  final _key = GlobalKey();

  void _getSize() {
    final _size = _key.currentContext.size;
    final _width = _size.width;
    final _height = _size.height;
  }

  void setTheState() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("تم تحديث الرصيد"),
      duration: Duration(seconds: 2),
    ));
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: asideMenu(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: MenuBar(),
        ),
        bottomNavigationBar: bottomBar(context),
        key: scaffoldKey,
        body: SingleChildScrollView(
            controller: scrolling.returnTheVariable(),
            child: Container(
              margin: EdgeInsets.only(top: 15, left: 0),
              padding:
                  const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    //width: 400,
                    child: Text("منتجات خاصة بشركة: " + companyName,
                        key: _key,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.right),
                    /*decoration: new BoxDecoration(
                    color: Colors.yellow
                  ),*/
                  ),
                  Consumer<ProductsProvider>(
                    builder: (context, products, child) => products
                            .productsLoading
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 50),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : products.check &&
                                products.products.containsKey(companyId) &&
                                products.products[companyId].isNotEmpty
                            ? Container(child: LayoutBuilder(builder:
                                (BuildContext ctx, BoxConstraints constraints) {
                                var width;
                                var flex1;
                                var flex2;

                                var showHide;
                                var showHide2;
                                if (constraints.maxWidth > 650) {
                                  width = constraints.maxWidth * 0.22;
                                  flex1 = double.infinity;
                                  flex2 = double.infinity;
                                  showHide = true;
                                  showHide2 = false;
                                } else if (constraints.maxWidth > 400) {
                                  width = constraints.maxWidth * 0.48;
                                  flex1 = double.infinity;
                                  flex2 = double.infinity;
                                  showHide = true;
                                  showHide2 = false;
                                } else if (constraints.maxWidth > 0) {
                                  width = constraints.maxWidth * 0.48;
                                  flex1 = double.infinity;
                                  flex2 = double.infinity;
                                  showHide = false;
                                  showHide2 = true;
                                }

                                return Wrap(
                                  children:
                                      products.products[companyId].map((item) {
                                    products.countItemsArr.add(1);
                                    return Container(
                                      width: width,
                                      margin: EdgeInsets.all(2),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: CachedNetworkImage(
                                              width: double.infinity,
                                              fit: BoxFit.fill,
                                              imageUrl: products
                                                          .products[companyId][
                                                      products
                                                          .products[companyId]
                                                          .indexOf(item)]
                                                  ["product_image"],
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.all(3),
                                            child: Text(
                                                products.products[companyId][
                                                        products
                                                            .products[companyId]
                                                            .indexOf(item)]
                                                    ['product_name'],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                                textAlign: TextAlign.right),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 1.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(bottom: 3),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            _getSize();
                                                            products.quantityPlusMinus(
                                                                products
                                                                    .products[
                                                                        companyId]
                                                                    .indexOf(
                                                                        item),
                                                                '+',
                                                                false,
                                                                null);
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 25,
                                                            width: 25,
                                                            child: Text('+',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                color: HexColor(
                                                                    "#F65D12")),
                                                          ),
                                                        ),
                                                        // Quantity
                                                        Container(
                                                          height: 25,
                                                          width: 25,
                                                          margin:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  5, 0, 5, 0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: HexColor(
                                                                    "#C0A7C1")),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              products
                                                                  .countItemsArr[products
                                                                      .products[
                                                                          companyId]
                                                                      .indexOf(
                                                                          item)]
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: HexColor(
                                                                    "#F65D12"),
                                                              )),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            products.quantityPlusMinus(
                                                                products
                                                                    .products[
                                                                        companyId]
                                                                    .indexOf(
                                                                        item),
                                                                '-',
                                                                false,
                                                                null);
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 25,
                                                            width: 25,
                                                            child: Text('-',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                color: HexColor(
                                                                    "#F65D12")),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: showHide,
                                                  child: Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      margin: EdgeInsets.only(
                                                        right: 5,
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                          products.products[
                                                                          companyId]
                                                                      [products
                                                                          .products[
                                                                              companyId]
                                                                          .indexOf(
                                                                              item)]
                                                                  [
                                                                  "product_price"] +
                                                              " SAR",
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                          )),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            width: 1.0,
                                                            color:
                                                                Colors.white),
                                                        //borderRadius: BorderRadius.circular(30.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: showHide2,
                                            child: Container(
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(
                                                  top: 10, bottom: 0),
                                              padding: EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Text(
                                                  products.products[companyId][
                                                              products.products[
                                                                      companyId]
                                                                  .indexOf(
                                                                      item)]
                                                          ["product_price"] +
                                                      " SAR",
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  )),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    width: 1.0,
                                                    color: Colors.white),
                                                //borderRadius: BorderRadius.circular(30.0),
                                              ),
                                            ),
                                          ),
                                          products.products[companyId][products
                                                  .products[companyId]
                                                  .indexOf(item)]['canBuy']
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  width: double.infinity,
                                                  child: RaisedButton(
                                                    padding: EdgeInsets.all(0),
                                                    child: Text(
                                                      'شراء وطباعة',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    color: HexColor("#F65D12"),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    onPressed: () {
                                                      // products.validate2(
                                                      //     context, companyId, products.products[
                                                      //                  companyId]
                                                      //              .indexOf(item));
                                                      products.validateAndCheck(
                                                          context,
                                                          products.products[
                                                                  companyId]
                                                              .indexOf(item),
                                                          companyId,
                                                          setTheState);
                                                    },
                                                  ))
                                              : Visibility(
                                                  child: Text(""),
                                                  visible: false,
                                                ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          color: HexColor("#1B1B1D"),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    );
                                  }).toList(),
                                );
                              }))
                            : products.noData,
                  ),
                ],
              ),
            )),
        floatingActionButton: scrolling.buttonLayout());
  }

  // Widget temp (){
  //   return FutureBuilder(
  //     future: getTheDataVar,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (snapshot.hasData == false) {
  //         return Container(
  //           margin: const EdgeInsets.only(bottom: 5, top: 50),
  //           child: Center(
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       } else {
  //         return check ?  Container(
  //             child: LayoutBuilder(
  //
  //                 builder: (BuildContext ctx, BoxConstraints constraints) {
  //
  //                   var width;
  //                   var flex1;
  //                   var flex2;
  //
  //                   var showHide;
  //                   var showHide2;
  //                   if (constraints.maxWidth > 650) {
  //                     width = constraints.maxWidth * 0.22;
  //                     flex1 = double.infinity;
  //                     flex2 = double.infinity;
  //                     showHide = true;
  //
  //                     showHide2 = false;
  //                   } else if (constraints.maxWidth > 400) {
  //                     width = constraints.maxWidth * 0.48;
  //                     flex1 = double.infinity;
  //                     flex2 = double.infinity;
  //                     showHide = true;
  //                     showHide2 = false;
  //                   } else if (constraints.maxWidth > 0) {
  //                     width = constraints.maxWidth * 0.48;
  //                     flex1 = double.infinity;
  //                     flex2 = double.infinity;
  //                     showHide = false;
  //                     showHide2 = true;
  //                   }
  //
  //                   return Wrap(
  //                     children:
  //                     getProducts.map((item) {
  //                       countItemsArr.add(1);
  //                       return Container(
  //                         width: width,
  //                         margin: EdgeInsets.all(2),
  //                         alignment: Alignment.centerRight,
  //                         padding: EdgeInsets.all(5),
  //                         child: Column(
  //                           children: [
  //                             Container(
  //                               margin: EdgeInsets.only(bottom: 10),
  //                               child: CachedNetworkImage(
  //                                 width: double.infinity,
  //                                 fit: BoxFit.fill,
  //                                 imageUrl: getProducts[getProducts
  //                                     .indexOf(
  //                                     item)]["product_image"],
  //                                 errorWidget: (context, url,
  //                                     error) => Icon(Icons.error),
  //                               ),
  //                             ),
  //                             Container(
  //                               alignment: Alignment.center,
  //                               margin: EdgeInsets.only(bottom: 10),
  //                               padding: EdgeInsets.all(3),
  //                               child: Text(
  //                                   getProducts[getProducts.indexOf(
  //                                       item)]['product_name'],
  //                                   style: TextStyle(fontSize: 14,
  //                                       color: Colors.white),
  //                                   textAlign: TextAlign.right
  //                               ),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius
  //                                     .circular(8),
  //                                 border: Border.all(width: 1.0,
  //                                     color: Colors.white),
  //                               ),
  //                             ),
  //                             Container(
  //                               margin: EdgeInsets.only(bottom: 3),
  //                               child: Row(
  //                                 children: [
  //                                   Expanded(
  //                                     flex: 6,
  //                                     child: Container(
  //                                       alignment: Alignment.center,
  //                                       child: Row(
  //                                         children: [
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               _getSize();
  //                                               quantityPlusMinus(getProducts.indexOf(item), '+', false, null);
  //                                             },
  //                                             child: Container(
  //                                               alignment: Alignment.center,
  //                                               height: 25,
  //                                               width: 25,
  //                                               child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,)),
  //                                               decoration: BoxDecoration(
  //                                                   borderRadius: BorderRadius.circular(30.0),
  //                                                   color: HexColor("#F65D12")
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           // Quantity
  //                                           Container(
  //                                             height: 25,
  //                                             width: 25,
  //                                             margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                                             decoration: BoxDecoration(
  //                                               border: Border.all(color: HexColor("#C0A7C1")),
  //                                               borderRadius: BorderRadius.circular(5),
  //                                             ),
  //                                             alignment: Alignment.center,
  //                                             child: Text(countItemsArr[getProducts.indexOf(item)].toString(),
  //                                                 style: TextStyle(fontSize: 14, color: HexColor("#F65D12"),)),
  //                                           ),
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               quantityPlusMinus(getProducts.indexOf(item), '-', false, null);
  //                                             },
  //                                             child: Container(
  //                                               alignment: Alignment.center,
  //                                               height: 25,
  //                                               width: 25,
  //                                               child: Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,)),
  //                                               decoration: BoxDecoration(
  //                                                   borderRadius: BorderRadius.circular(30.0),
  //                                                   color: HexColor("#F65D12")
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //
  //                                   Visibility(
  //                                     visible: showHide,
  //                                     child: Expanded(
  //                                       flex: 4,
  //                                       child: Container(
  //                                         alignment: Alignment.center,
  //                                         margin: EdgeInsets.only(right: 5,),
  //                                         padding: EdgeInsets.only(top: 5, bottom: 5),
  //                                         child: Text(getProducts[getProducts.indexOf(item)]["product_price"] + " SAR",
  //                                             textDirection: TextDirection.ltr,
  //                                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white,)),
  //                                         decoration: BoxDecoration(
  //                                           borderRadius: BorderRadius.circular(5),
  //                                           border: Border.all(
  //                                               width: 1.0,
  //                                               color: Colors.white),
  //                                           //borderRadius: BorderRadius.circular(30.0),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //
  //
  //                                 ],
  //                               ),
  //                             ),
  //                             Visibility(
  //                               visible: showHide2,
  //                               child: Container(
  //                                 width: double.infinity,
  //                                 alignment: Alignment.center,
  //                                 margin: EdgeInsets.only(top: 10, bottom: 0),
  //                                 padding: EdgeInsets.only(top: 5, bottom: 5),
  //                                 child: Text(getProducts[getProducts.indexOf(item)]["product_price"] + " SAR", textDirection: TextDirection.ltr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white,)),
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(5),
  //                                   border: Border.all(width: 1.0, color: Colors.white),
  //                                   //borderRadius: BorderRadius.circular(30.0),
  //                                 ),
  //                               ),
  //                             ),
  //                             getProducts[getProducts.indexOf(item)]['canBuy'] ?
  //                             Container(
  //                                 margin: EdgeInsets.only(top: 10),
  //                                 width: double.infinity,
  //                                 child: RaisedButton(
  //                                   padding: EdgeInsets.all(0),
  //                                   child: Text('شراء وطباعة',
  //                                     style: TextStyle(color: Colors.white, fontSize: 12,),),
  //                                   color: HexColor("#F65D12"),
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius
  //                                         .circular(10),
  //                                   ),
  //                                   onPressed: () {
  //                                     validateAndCheck(context, getProducts.indexOf(item));
  //                                   },
  //                                 )
  //                             ) : Visibility(child: Text(""), visible: false,),
  //                           ],
  //                         ),
  //                         decoration: BoxDecoration(
  //                             color: HexColor("#1B1B1D"),
  //                             borderRadius: BorderRadius.circular(5)
  //                         ),
  //                       );
  //                     }).toList(),
  //                   );
  //
  //                 })) : noData;
  //       }
  //     },
  //   );
  // }
}
