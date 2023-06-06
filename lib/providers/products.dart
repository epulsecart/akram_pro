import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/providers/user_info.dart';

import '../controller/printer.dart';
import '../controller/productsAndCart.dart';
import '../controller/share.dart';
import '../database/userinfoDatabase.dart';
import '../main.dart';

class ProductsProvider extends ChangeNotifier{


  List getProducts = [];
  /// String company id, list of its products
  Map<String, List> products = {};
  /// string product id , list of the cards available
  Map<String, dynamic> cards = {};
  var noData = Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 15, right: 15),
    child: Text("لاتوجد منتجات متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
  );
  bool check = false;
  bool productsLoading = true;
  var textSize = 14;
  userinfoDatabase userInfo = new userinfoDatabase();
  var countItemsArr= [];
  var showLoading = false;
  var showLoadingSimple = false;
  static const platform =  MethodChannel("com.cybitsec.souqcardstoreapp/text");
  // final GlobalKey<ScaffoldState> _scaffoldkeyValidate = new GlobalKey<ScaffoldState>();





  getProductsFun (String companyId, BuildContext context) async {
    productsLoading = true;
    notifyListeners();
    if (products.containsKey(companyId)){
      productsLoading = false;
      if (products[companyId].isNotEmpty){
        print ("check is now true with ${products[companyId].length} products");
        check = true;
      }else {
        check = false;
      }

      notifyListeners();
    }
    productsCartsController getProductsClass = new productsCartsController(productsCartsController_companyId: companyId);
    // var getProductsForDisplay = await getProductsClass.getProducts();
    print ("getting product ${DateTime.now()}");
    var getProductsForDisplay = await getProductsClass.getCardsForSpecificProductsAfterStoresPutsDifference2(context);
    print ("got product ${DateTime.now()}");
    if (getProductsForDisplay["status"] == "available") {
        check = true;
        getProducts = getProductsForDisplay["data"];
        if (products.containsKey(companyId)){
          products[companyId] = [];
          products[companyId] = getProducts ;
        }else {
          products.addAll({companyId: getProducts});
        }

          try{
            cards = getProductsForDisplay["cards"];
          }catch(e){
          print ("in provider can not add the map $e");
          }

        productsLoading = false;
        notifyListeners();
      return getProducts;
    } else {
      print ("hii no data here ${companyId}");
        check = false;
        productsLoading = false;
      products.addAll({companyId: []});
      noData = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Text("لاتوجد منتجات متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        );
        notifyListeners();
      return check;
    }
  }

  quantityPlusMinusTextSize(sign, state) {
    state(() {
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

  quantityPlusMinus(index, sign, hasOtherState, state) {
    // _getSize();
    if (hasOtherState == true) {
      state(() {
        if(sign == '+'){
          if (countItemsArr[index] >= 5) {

          } else {
            countItemsArr[index] = countItemsArr[index] + 1;
            getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
          }

        }
        else {
          if (countItemsArr[index] <= 1) {
            countItemsArr[index] = 1;
            getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
          }
          else {
            countItemsArr[index] = countItemsArr[index] - 1;

            if (countItemsArr[index] == 1) {
              getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
            } else {
              getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
            }

          }
        }
      });
    } else {

        if(sign == '+'){
          if (countItemsArr[index] >= 5) {

          } else {
            countItemsArr[index] = countItemsArr[index] + 1;
            getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
          }
        }
        else {
          if (countItemsArr[index] <= 1) {
            countItemsArr[index] = 1;
            getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
          }
          else {
            countItemsArr[index] = countItemsArr[index] - 1;

            if (countItemsArr[index] == 1) {
              getProducts[index]["product_price"] = (getProducts[index]["main_price"]).toString();
            } else {
              getProducts[index]["product_price"] = (double.parse(countItemsArr[index].toString()) * double.parse(getProducts[index]["main_price"])).toString();
            }

          }
        }
        notifyListeners();
    }

  }
  showLoadingFun(BuildContext context) {
    if (showLoading) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Image.asset("assets/images/cardLoading.gif", width: 280, height: 280, fit: BoxFit.cover,),
            );
          });
    } else {
      Navigator.pop(context);

      return;
    }
  }

  showLoadingFunSimple(BuildContext context) {
    if (showLoadingSimple) {
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




  getUserTextSize () async {
    var getSize = await userInfo.getUserTextSize();

    if (getSize == "empty") {
      textSize = 14;
    } else {
      textSize = int.parse(getSize);
    }
  }

  ///
  validateAndCheck(BuildContext context, index, String companyId,  Function() setTheState) async {

    final companyEditName = TextEditingController();

    var displayCards = null;

    List displayCardsNumbers = [];
    List displayCardsSerials = [];
    List displayCardsDate = [];

    var myState;

    var mainQuantity = countItemsArr[index];
    var mainPrice = getProducts[index]['product_price'];
    var buyResult = "";

    var printerClass = new printer();
    var checkConnection = await printerClass.connectToPrinter();

    var shippingMethod = "";
    var getCompanyImage = "";
    var getCompanyName = "";

    //  var checkConnection = "connected";
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء", style: TextStyle(color: HexColor("#F65D12"),),),
      onPressed:  () {


          countItemsArr[index] = mainQuantity;
          getProducts[index]['product_price'] = mainPrice;
          buyResult = "";

          notifyListeners();



        Navigator.pop(context);
      },
    );
    Widget continueButton = Consumer<UserInfoProvider>(builder: (context, user, child) => TextButton(
      child: Text("تأكيد الشراء", style: TextStyle(color: HexColor("#F65D12"),),),
      onPressed:  () async {
        print("now buying ${DateTime.now().toString()}");

        showLoading = true;

        notifyListeners();
        showLoadingFun(context);
        productsCartsController card = new productsCartsController(productsCartsController_productId: getProducts[index]['docid'], productsCartsController_howmany: countItemsArr[index].toString());
        print ("current product is ${getProducts[index]}");
        var buyTheCards = await card.buyTheCard2(
          getMyStoreOfStoresPrice: user.getMyStoreOfStoresPrice,
          getMyWhichPrice: user.getMyWhichPrice,
          myStoreOfStoreId: user.myStoreOfStoreId,
          storeId: user.myId,
          userActive: user.userActive,
          userExist: user.userExist,
        );
        // var buyTheCards = await card.buyTheCard();
        print("now got the result ${DateTime.now().toString()}");
        myState(() {
          displayCards = buyTheCards;
          displayCardsNumbers = buyTheCards['saveCradsNumbers'];
          displayCardsSerials = buyTheCards['saveCradsSerial'];
          displayCardsDate = buyTheCards['saveCardsExpiryDate'];
          print("displayCards");
          print(displayCards);
        });

        print ("getting the company details ${DateTime.now().toString()}");
        if (buyTheCards['status'] == "success") {
          var company = await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .get();
          print ("got the company details ${DateTime.now().toString()}");

          shippingMethod = company.get("companies_shippingCompanyMethod");

          getCompanyImage = company.get("companies_printinglogo");

          getCompanyName = company.get("companies_name");

          myState(() {
            buyResult = "تم الشراء يمكنك الطباعة";
          });

          //  var printerClass = new printer();
          // var checkConnection = await printerClass.connectToPrinter();
          if (checkConnection == "notconnected") {
            // myState(() {
            //   buyResult = "تم الشراء لست موصول بالطابعة";
            // });
          }
          else if (checkConnection == "connected") {

            for (var i = 0; i < countItemsArr[index]; i = i + 1) {
              try {
                var value = await platform.invokeMethod('print', {
                  "companyImage": getCompanyImage,
                  "productName": getProducts[index]['product_name'],
                  "textSize": textSize,
                  "productNumber": buyTheCards['saveCradsNumbers'][i],
                  "product_broughtDate": buyTheCards["broughtDate"],
                  "productSerial": buyTheCards['saveCradsSerial'][i],
                  "product_expiryDate": getProducts[index]['product_expiryDate'],
                  "product_shippingMethod": shippingMethod,
                });
              } on PlatformException catch (e) {

              }
            }
            myState(() {
              buyResult = "تم الشراء وتمت الطباعة";
            });


          }
        } else if (buyTheCards['status'] == "userNotActive") {
          myState(() {
            buyResult = "تم الغاء تفعيل حسابك";
          });
        } else if (buyTheCards['status'] == "userNotExist") {
          myState(() {
            buyResult = "تم حذفك";
          });
        } else if (buyTheCards['status'] == "needMoreBalance") {
          myState(() {
            buyResult = "الرصيد غير كافي";
          });
        } else if (buyTheCards['status'] == "notAvailableQuantity") {
          myState(() {
            buyResult = "الكمية غير متوفرة";
          });
        } else if (buyTheCards['status'] == "lessThenZero") {
          myState(() {
            buyResult = "الكمية أصغر من صفر";
          });
        } else if (buyTheCards['status'] == "myStoreOfStoreNotExist") {
          myState(() {
            buyResult = "المندوب الخاص بك ليس موجود";
          });
        }else {
          myState(() {
            buyResult = buyTheCards['status'];
          });
        }

        showLoading = false;
        notifyListeners();
        showLoadingFun(context);
        print("now loading will finish ${DateTime.now().toString()}");
        if (buyTheCards['status'] == "success") {

          myBalance["store_totalBalance"] = buyTheCards["newTotalBalance"];
          setTheState();
          notifyListeners();

          //Navigator.pop(context);


        }
        // Navigator.pop(context);
      },
    ),);


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: HexColor("#1B1B1D"),
      title: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1.0, color: Colors.white),
        ),
        child: Text(getProducts[index]['product_name'], style: TextStyle(fontSize: 16,color: Colors.white,),),
      ),
      content: StatefulBuilder(
          // key: _scaffoldkeyValidate,
          builder: (BuildContext context, StateSetter state) {
            myState = state;
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    quantityPlusMinus(index, '+', true, state);
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
                                  child: Text(countItemsArr[index].toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    quantityPlusMinus(index, '-', true, state);
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

                          Expanded(
                            flex: 5,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 5,),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(getProducts[index]["product_price"] + " SAR", textDirection: TextDirection.ltr, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12,color: Colors.white,)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: 1.0, color: Colors.white),
                                //borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 5, bottom: 10),
                      child: Text("تنبيه : سيتم خصم المبلغ من رصيدك تأكد من العدد الصحيح", style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12, color: HexColor("#F65D12"),)),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 5, bottom: 10),
                      child: Text(buyResult, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 16, color: Colors.white,)),
                    ),

                    displayCardsNumbers.length != 0?
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(bottom: 10,),
                      child: Text('حجم خط الطابعة', style: TextStyle(color: HexColor("#F65D12"),),),
                    ) : Text(""),

                    displayCardsNumbers.length != 0?
                    Container(
                      margin: EdgeInsets.only(bottom: 10,),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              quantityPlusMinusTextSize('+', state);
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
                              quantityPlusMinusTextSize('-', state);
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
                    ) : Text(""),

                    displayCardsNumbers.length != 0?
                    Container(
                      margin: EdgeInsets.only(bottom: 10,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        //   mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 70,
                            child: RaisedButton(
                              padding: EdgeInsets.all(0),
                              child: Text('طباعة الكل',
                                style: TextStyle(color: Colors.white, fontSize: 12,),),
                              color: HexColor("#F65D12"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius
                                    .circular(10),
                              ),
                              onPressed: () async {
                                print("displayCards");
                                print(displayCards);

                                print("getCompanyImage");
                                print(getCompanyImage);

                                print("shippingMethod");
                                print(shippingMethod);

                                if (checkConnection == "notconnected") {
                                  myState(() {
                                    buyResult = "لست متصل بالطابعة";
                                  });
                                } else if (checkConnection == "connected") {

                                    showLoadingSimple = true;
                                    notifyListeners();
                                    showLoadingFunSimple(context);

                                  for (var i = 0; i < countItemsArr[index]; i = i + 1) {
                                    try {
                                      var value = await platform.invokeMethod('print', {
                                        "companyImage": getCompanyImage,
                                        "textSize": textSize,
                                        "productName": getProducts[index]['product_name'],
                                        "productNumber": displayCards['saveCradsNumbers'][i],
                                        "product_broughtDate": displayCards["broughtDate"],
                                        "productSerial": displayCards['saveCradsSerial'][i],
                                        "product_expiryDate": displayCards['saveCardsExpiryDate'][i],
                                        "product_shippingMethod": shippingMethod,
                                      });
                                    } on PlatformException catch (e) {

                                    }
                                  }
                                  myState(() {
                                    buyResult = "تم الشراء وتمت الطباعة";
                                  });


                                    showLoadingSimple = false;
                                  notifyListeners();
                                  showLoadingFunSimple(context);


                                }
                              },
                            ),
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          SizedBox(
                            width: 70,
                            child: RaisedButton(
                              padding: EdgeInsets.all(0),
                              child: Text('مشاركة الكل',
                                style: TextStyle(color: Colors.white, fontSize: 10,),),
                              color: HexColor("#F65D12"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius
                                    .circular(10),
                              ),
                              onPressed: () async {

                                var textData = "";

                                for (var i = 0; i < countItemsArr[index]; i = i + 1) {
                                  textData = textData + "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][i].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][i].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][i] + " \n \n \n --------------- \n \n \n ";
                                }

                                print(textData);

                                sharingData(context, textData,
                                    textData);
                              },
                            ),
                          )


                        ],
                      ),
                    ):Container(child: Text(""),),

                    // Display The Cards
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 5, ),
                      child: Column(
                        children: displayCardsNumbers.length != 0?displayCardsNumbers.map((item) {

                          return Container(
                            child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 5, ),
                                    child: Text("رقم البطاقة:", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 10, ),
                                    child: Text(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),

                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 5, ),
                                    child: Text("سيريل البطاقة:", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 10, ),
                                    child: Text(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),

                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 5, ),
                                    child: Text("تاريخ الإنتهاء:", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: 10, ),
                                    child: Text(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)], style: TextStyle(color: Colors.white, fontSize: 14,),),
                                  ),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    //   mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: RaisedButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text('طباعة',
                                            style: TextStyle(color: Colors.white, fontSize: 10,),),
                                          color: HexColor("#F65D12"),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(10),
                                          ),
                                          onPressed: () async {
                                              showLoadingSimple = true;
                                              notifyListeners();
                                              showLoadingFunSimple(context);

                                            /*print("getCompanyImage");
                                                print(getCompanyImage);

                                                print("getProducts[index]['product_name']");
                                                print(getProducts[index]['product_name']);

                                                print("displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("displayCards['broughtDate']");
                                                print(displayCards["broughtDate"]);

                                                print("displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("shippingMethod");
                                                print(shippingMethod);*/

                                            if (checkConnection == "notconnected") {
                                              myState(() {
                                                buyResult = "لست متصل بالطابعة";
                                              });
                                            } else if (checkConnection == "connected") {
                                              try {
                                                var value = await platform.invokeMethod('print', {
                                                  "companyImage": getCompanyImage,
                                                  "textSize": textSize,
                                                  "productName": getProducts[index]['product_name'],
                                                  "productNumber": displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                  "product_broughtDate": displayCards["broughtDate"],
                                                  "productSerial": displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                  "product_expiryDate": displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                  "product_shippingMethod": shippingMethod,
                                                });
                                              } on PlatformException catch (e) {

                                              }
                                            }

                                            showLoadingSimple = false;
                                            notifyListeners();
                                            showLoadingFunSimple(context);
                                          },
                                        ),
                                      ),

                                      SizedBox(
                                        width: 10,
                                      ),

                                      SizedBox(
                                        width: 70,
                                        child: RaisedButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text('مشاركة',
                                            style: TextStyle(color: Colors.white, fontSize: 10,),),
                                          color: HexColor("#F65D12"),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(10),
                                          ),
                                          onPressed: () async {
                                            sharingData(context, "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                "اسم الشركة: " + getCompanyName + "\nإسم المنتج: " + getProducts[index]['product_name'] + "\nرقم الكارت: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nالسريال: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\nتاريخ الإنتهاء : " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);
                                          },
                                        ),
                                      )


                                    ],
                                  ),

                                ]
                            ),
                          );
                        }).toList(): [],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

   validate2 (BuildContext context, String comID, int index ){
     showDialog(context: context, builder: (BuildContext context){
      return Consumer<UserInfoProvider>(
        builder: (context, user, child) =>  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('stores').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> userData){
            var userData2 = userData.data.docs.firstWhere((element) => element.id == user.myId).data();
            var currentProduct = products[comID][index];
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cards')
                    .where("card_sellingStatus", isEqualTo: "false")
                    .where("card_status", isEqualTo: "true")
                    .where("card_productId", isEqualTo: products[comID][index]['docid']).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> cards){
                  List<QueryDocumentSnapshot> cards2 = cards.data.docs;
                  print ("available cards are ${cards2.first.data()}");
                  return Container();
                });
            }),
      );
    });
  }








}