// @dart=2.11

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/productsAndCart.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';           // new

class cards extends StatefulWidget {

  final String productId;

  cards({
    this.productId,
  });

  @override
  cardsState createState() => cardsState(productId: this.productId);
}

class cardsState extends State  {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final String productId;

  cardsState({
    this.productId,
  });

  ScrollToTop scrolling = ScrollToTop();

  FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();

    getProductsFun();
  }

  final quantity = TextEditingController();
  var priceOfQuantity;

  var getCardsData = Container();
  var noData = Container();
  bool check = false;
  var getProductsForDisplay;

  getProductsFun () async {
    productsCartsController getProducts = new productsCartsController(productsCartsController_productId: productId);
    getProductsForDisplay = await getProducts.getCardsForSpecificProductsAfterStoresPutsDifference();

    if (getProductsForDisplay["status"] == "available") {
        setState(() {
          check = true;
          priceOfQuantity = getProductsForDisplay["data"]["card_price"];
          getProductsForDisplay = getProductsForDisplay;
        });
    } else {
      setState(() {
        check = false;
        noData = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Text("لاتوجد كروت متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        );
      });
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
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 15, left: 0),
            padding: const EdgeInsets.only(top: 100, bottom: 100, left: 10, right: 10),
            child: check ? Container(
              alignment: Alignment.center,
              width: 200,
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(5, 30, 10, 5),
                      width: 100,
                      height:80,
                      child: CachedNetworkImage(
                        imageUrl: getProductsForDisplay["data"]["card_image"],
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                  ),

                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(getProductsForDisplay["data"]["card_name"]),
                  ),

                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(priceOfQuantity),
                  ),


                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      onChanged: (value) {
                        var price;
                        if (value.isEmpty) {
                          price = getProductsForDisplay["data"]["card_price"];
                        } else {
                          price = (int.parse(value) * double.parse(getProductsForDisplay["data"]["card_price"])).toString();
                        }

                        setState(() {
                          priceOfQuantity = price;
                        });


                      },
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      controller: quantity,
                      //initialValue: '',
                      decoration: InputDecoration(
                        hintText: 'الكمية',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      ),
                    ),
                  ),


                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      child: RaisedButton(
                        child: Text('شراء', style: TextStyle(color: Colors.white,), ),
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {

                          if (quantity.text != "") {
                            productsCartsController card = new productsCartsController(productsCartsController_cardId: getProductsForDisplay["data"]['docid'], productsCartsController_howmany: quantity.text);
                            var buyTheCards = await card.buyTheCard();

                            if (buyTheCards['status'] == "success") {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("تم الشراء الرجاء تفقد قسم المشتريات"),
                                duration: Duration(seconds: 5),
                              ));
                            } else if (buyTheCards['status'] == "needMoreBalance") {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("الرصيد غير كافي"),
                                duration: Duration(seconds: 5),
                              ));
                            } else if (buyTheCards['status'] == "notAvailableQuantity") {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("الكمية غير متوفرة"),
                                duration: Duration(seconds: 5),
                              ));
                            } else if (buyTheCards['status'] == "lessThenZero") {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("الكمية أصغر من صفر"),
                                duration: Duration(seconds: 5),
                              ));
                            } else if (int.parse(quantity.text) < 0) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("الكمية أصغر من صفر"),
                                duration: Duration(seconds: 5),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("الرجاء إدخال الكمية"),
                                duration: Duration(seconds: 5),
                              ));
                            }
                          }

                        },
                      )
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15)),
            ) : noData
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

