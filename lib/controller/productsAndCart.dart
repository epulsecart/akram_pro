import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:storeapp/providers/user_info.dart';

import 'balance.dart';

class productsCartsController {
  String productsCartsController_productId;
  String productsCartsController_cardId;
  String productsCartsController_cardPrice;
  String productsCartsController_companyId;
  String productsCartsController_howmany;

  productsCartsController(
      {this.productsCartsController_productId,
      this.productsCartsController_cardId,
      this.productsCartsController_cardPrice,
      this.productsCartsController_companyId,
      this.productsCartsController_howmany});

  factory productsCartsController.fromJson(Map<String, dynamic> json) {
    return productsCartsController(
        productsCartsController_productId:
            json['productsCartsController_productId'],
        productsCartsController_cardId: json['productsCartsController_cardId'],
        productsCartsController_cardPrice:
            json['productsCartsController_cardPrice'],
        productsCartsController_companyId:
            json['productsCartsController_companyId'],
        productsCartsController_howmany:
            json['productsCartsController_howmany']);
  }

  // Get Balance History
  getProducts() async {
    userinfoDatabase userInfo = new userinfoDatabase();

    var storeId = await userInfo.getStoreId();

    var getProductsData = [];
    await FirebaseFirestore.instance
        .collection('products')
        .where("product_status", isEqualTo: "true")
        .where("product_companyId",
            isEqualTo: productsCartsController_companyId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        getProductsData.add({
          'product_name': doc['product_name'],
          'product_image': doc['product_image'],
          'docid': doc.id,
        });
      });
    });

    return getProductsData;
  }

  // Get My StoreOfStores
  getMyStoreOfStores() async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var myStoreOfStore = {};
    await FirebaseFirestore.instance
        .collection('storesOfStores')
        .where("storesOfStores_storeId", isEqualTo: storeId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        myStoreOfStore['storesOfStores_representativesId'] =
            doc['storesOfStores_representativesId'];
        myStoreOfStore['docid'] = doc.id;
      });
    });

    var getMyStoreOfStoreId = await FirebaseFirestore.instance
        .collection('stores')
        .doc(myStoreOfStore['storesOfStores_representativesId'])
        .get();

    if (getMyStoreOfStoreId.exists) {
      myStoreOfStore['store_phoneNumber'] =
          getMyStoreOfStoreId.get('store_phoneNumber');
      myStoreOfStore['store_id'] = getMyStoreOfStoreId.id;
      myStoreOfStore["status"] = "myStoreOfStoreExist";
    } else {
      return {"status": "myStoreOfStoreNotExist"};
    }

    return myStoreOfStore;
  }

  getMyWhichPrice(var myId) async {
    // Get My PhoneNumber
    userinfoDatabase userInfo = new userinfoDatabase();
    // = await userInfo.getStoreId();

    // Get My Which Price
    var getMyWhichPrice = {};
    var getMyWhichPriceRequest =
        await FirebaseFirestore.instance.collection('stores').doc(myId).get();
    if (getMyWhichPriceRequest.exists) {
      if (getMyWhichPriceRequest
              .data()
              ?.containsKey("store_StoreOfStoresPriceName") ==
          true) {
        getMyWhichPrice['store_StoreOfStoresPriceName'] =
            getMyWhichPriceRequest.get('store_StoreOfStoresPriceName');
        getMyWhichPrice["status"] = "store_StoreOfStoresPriceNameExists";
      } else {
        getMyWhichPrice['store_StoreOfStoresPriceName'] = '';
        getMyWhichPrice["status"] = "store_StoreOfStoresPriceNameNotExists";
      }
    }

    return getMyWhichPrice;
  }

  getMyStoreOfStoresPrice({String store_id}) async {
    // Get My Store Of Store Group Price
    var getMyStoreOfStoresPrice = {};
    var getMyStoreOfStorePrices = await FirebaseFirestore.instance
        .collection('stores')
        .doc(store_id)
        .get();

    if (getMyStoreOfStorePrices.exists) {
      getMyStoreOfStoresPrice['store_groupValue'] =
          getMyStoreOfStorePrices.get('store_groupValue');
      getMyStoreOfStoresPrice['status'] = "store_groupValueExist";
    } else {
      getMyStoreOfStoresPrice['store_groupValue'] = "";
      getMyStoreOfStoresPrice['status'] = "store_groupValueNotExist";
    }

    return getMyStoreOfStoresPrice;
  }

  getAllAvailbleProductsNameImagePrice_withGroupValue(
      {String GroupValue}) async {
    // Get Products For Cards name and image and Price
    /*var getProducts = [];
    var getProduct = await FirebaseFirestore.instance
        .collection('products')
        .doc(productsCartsController_productId)
        .get();

    if (getProduct.get("product_status") == "true") {
      getProducts.add({
        "product_name": getProduct.get('product_name'),
        "product_image": getProduct.get('product_image'),
        "product_price": getProduct.get(GroupValue),
        "docid": getProduct.id
      });
    }
    return getProducts;*/
    var getProductsData = [];
    await FirebaseFirestore.instance
        .collection('products')
        .where("product_status", isEqualTo: "true")
        .where("product_companyId",
            isEqualTo: productsCartsController_companyId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var data = {
          'product_name': doc['product_name'],
          'product_image': doc['product_image'],
          'docid': doc.id,
        };

        if (GroupValue != "") {
          data['product_price'] = doc[GroupValue];
        } else {
          data['product_price'] = "";
        }

        getProductsData.add(data);
      });
    });

    return getProductsData;
  }

  getAllAvailbleCards({String GroupValue}) async {
    var getProductsData = [];
    await FirebaseFirestore.instance
        .collection('cards')
        .where("card_sellingStatus", isEqualTo: "false")
        .where("card_status", isEqualTo: "true")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var data = {};
      });
    });

    return getProductsData;
  }

  getOneProductForCardNameImagePrice_withGroupValue(
      {String productId, String GroupValue}) async {
    // Get Product For Cards name and image and Price
    var getProduct = {};
    var getProductRequest = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (getProductRequest.exists) {
      if (getProductRequest.get("product_status") == "true") {
        getProduct["product_name"] = getProductRequest.get('product_name');
        getProduct["product_image"] = getProductRequest.get('product_image');
        getProduct["product_price"] = getProductRequest.get(GroupValue);
        getProduct["product_pricePrivatePrice"] =
            getProductRequest.get('product_groupFour_privatePrice');
        getProduct["status"] = "productNotExist";
        getProduct["docid"] = getProductRequest.id;
      }
    } else {
      return {'status': "productNotExist"};
    }

    return getProduct;
  }

  getStoreOfStoreDifference(
      {String myStoreOfStoreId,
      String productsCartsController_productId}) async {
    // Get Store Difference Prices

    //var storeOfStoreDifference = {};
    var data = [];
    await FirebaseFirestore.instance
        .collection('storesOfStoresPricesDifference')
        .where("storesOfStoresPricesDifference_storeid",
            isEqualTo: myStoreOfStoreId)
        //.where("storesOfStoresPricesDifference_productId", isEqualTo: productsCartsController_productId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var storeOfStoreDifference = {};

        storeOfStoreDifference["storesOfStoresPricesDifference_groupOne"] =
            doc['storesOfStoresPricesDifference_groupOne'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupTwo"] =
            doc['storesOfStoresPricesDifference_groupTwo'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupThree"] =
            doc['storesOfStoresPricesDifference_groupThree'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupFour"] =
            doc['storesOfStoresPricesDifference_groupFour'];
        storeOfStoreDifference["storesOfStoresPricesDifference_productId"] =
            doc['storesOfStoresPricesDifference_productId'];
        storeOfStoreDifference["docid"] = doc.id;

        data.add(storeOfStoreDifference);
      });
    });

    //return storeOfStoreDifference;
    return data;
  }

  singleGetStoreOfStoreDifference(
      {String myStoreOfStoreId,
      String productsCartsController_productId}) async {
    // Get Store Difference Prices

    var storeOfStoreDifference = {};
    await FirebaseFirestore.instance
        .collection('storesOfStoresPricesDifference')
        .where("storesOfStoresPricesDifference_storeid",
            isEqualTo: myStoreOfStoreId)
        .where("storesOfStoresPricesDifference_productId",
            isEqualTo: productsCartsController_productId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        storeOfStoreDifference["storesOfStoresPricesDifference_groupOne"] =
            doc['storesOfStoresPricesDifference_groupOne'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupTwo"] =
            doc['storesOfStoresPricesDifference_groupTwo'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupThree"] =
            doc['storesOfStoresPricesDifference_groupThree'];
        storeOfStoreDifference["storesOfStoresPricesDifference_groupFour"] =
            doc['storesOfStoresPricesDifference_groupFour'];
        storeOfStoreDifference["storesOfStoresPricesDifference_productId"] =
            doc['storesOfStoresPricesDifference_productId'];
        storeOfStoreDifference["docid"] = doc.id;
      });
    });

    return storeOfStoreDifference;
  }

  getCardsForSpecificProductsAfterStoresPutsDifference2(
      BuildContext context) async {
    Map<String, dynamic> cards = {};
    var getProducts = await this
        .getAllAvailbleProductsNameImagePrice_withGroupValue(
            GroupValue: Provider.of<UserInfoProvider>(context, listen: false)
                .getMyStoreOfStoresPrice['store_groupValue']);
    var activeAndNonBroughtCards = [];
    for (var i = 0; i < getProducts.length; i = i + 1) {
      var getMyCards = await FirebaseFirestore.instance
          .collection('cards')
          .where("card_sellingStatus", isEqualTo: "false")
          .where("card_status", isEqualTo: "true")
          .where("card_productId", isEqualTo: getProducts[i]['docid'])
          .limit(1)
          .get();
      try {
        cards.addAll({getProducts[i]['docid']: getMyCards.docs});
      } catch (e) {
        print("can not add cards to he map $e");
      }
      var data = {"exist": "no", "canBuy": false};
      if (Provider.of<UserInfoProvider>(context, listen: false).myRole ==
          "محل فرعي") {
        data["canBuy"] = true;
        // storeOfStoreDifference = await this.getStoreOfStoreDifference(myStoreOfStoreId: myStoreOfStoreId['storesOfStores_representativesId'], productsCartsController_productId: getProducts[i]['docid']);
      }
      for (var t = 0; t < getMyCards.docs.length; t = t + 1) {
        if (getMyCards.docs[t].get("card_productId") ==
            getProducts[i]['docid']) {
          data["exist"] = "yes";

          data['product_name'] = getProducts[i]['product_name'];
          data['product_image'] = getProducts[i]['product_image'];
          data['product_expiryDate'] = getMyCards.docs[t]['card_expiryDate'];
          data['docid'] = getProducts[i]['docid'];

          for (var z = 0;
              z <
                  Provider.of<UserInfoProvider>(context, listen: false)
                      .storeOfStoreDifference
                      .length;
              z = z + 1) {
            if (Provider.of<UserInfoProvider>(context, listen: false)
                        .storeOfStoreDifference[z]
                    ['storesOfStoresPricesDifference_productId'] ==
                getProducts[i]['docid']) {
              data['product_price'] = (double.parse(
                          Provider.of<UserInfoProvider>(context, listen: false)
                                  .storeOfStoreDifference[z][
                              Provider.of<UserInfoProvider>(context,
                                          listen: false)
                                      .getMyWhichPrice[
                                  'store_StoreOfStoresPriceName']]) +
                      double.parse(getProducts[i]['product_price']))
                  .toString();
              data['main_price'] = (double.parse(Provider.of<UserInfoProvider>(
                              context,
                              listen: false)
                          .storeOfStoreDifference[z][Provider.of<
                              UserInfoProvider>(context, listen: false)
                          .getMyWhichPrice['store_StoreOfStoresPriceName']]) +
                      double.parse(getProducts[i]['product_price']))
                  .toString();

              break;
            } else {
              data['product_price'] = getProducts[i]['product_price'];
              data['main_price'] = getProducts[i]['product_price'];
            }
          }

          if (Provider.of<UserInfoProvider>(context, listen: false)
                  .storeOfStoreDifference
                  .length ==
              0) {
            data['product_price'] = getProducts[i]['product_price'];
            data['main_price'] = getProducts[i]['product_price'];
          }

          activeAndNonBroughtCards.add(data);

          break;
        }
      }
    }

    /* });
    });*/

    if (activeAndNonBroughtCards.length > 0) {
      return {
        "status": "available",
        "data": activeAndNonBroughtCards,
        'cards': cards
      };
    } else {
      return {
        "status": "notAvailable",
        // "data": activeAndNonBroughtCards[0]
      };
    }
  }

  getCardsForSpecificProductsAfterStoresPutsDifference() async {
    // Get My StoreOfStore Id
    print("getting user data ${DateTime.now()}");

    userinfoDatabase userInfo = new userinfoDatabase();
    var myRole = await userInfo.getStoreRole();
    var myPhoneNumber = await userInfo.getUserphonenumber();
    var myId = await userInfo.getStoreId();

    var myStoreOfStoreId;
    if (myRole == "مندوب") {
      myStoreOfStoreId = {"store_phoneNumber": myPhoneNumber, "store_id": myId};
    } else if (myRole == "محل فرعي") {
      print("getting store of the store ${DateTime.now()}");
      myStoreOfStoreId = await this.getMyStoreOfStores();
      print("got the store of the store ${DateTime.now()}");
    }

    // Get My Which Price
    print("getting which price ${DateTime.now()}");
    var getMyWhichPrice = await this.getMyWhichPrice(myId);
    print("got which price ${DateTime.now()}");

    // Get My Store Of Stores Group Price
    print("getting group price ${DateTime.now()}");
    var getMyStoreOfStoresPrice = await this
        .getMyStoreOfStoresPrice(store_id: myStoreOfStoreId['store_id']);
    print("got group price ${DateTime.now()}");

    // Get Products For Cards name and image
    print("getting image and name ${DateTime.now()}");
    var getProducts = await this
        .getAllAvailbleProductsNameImagePrice_withGroupValue(
            GroupValue: getMyStoreOfStoresPrice['store_groupValue']);
    print("got image and name ${DateTime.now()}");
    // Get Store Difference Prices
    var storeOfStoreDifference;
    if (myRole == "مندوب") {
      storeOfStoreDifference = [];
    }

    // Get Active Cards and Non Brought Cards For This
    var activeAndNonBroughtCards = [];

    // Product Name and Image same for Card

    // var getMyCards = await FirebaseFirestore.instance
    //     .collection('cards')
    //     .where("card_sellingStatus", isEqualTo: "false")
    //     .where("card_status", isEqualTo: "true")
    //    // .where("card_productId", isEqualTo: getProducts[i]['docid'])
    //     .get();

    if (myRole == "محل فرعي") {
      print("getting store differnce ${DateTime.now()}");
      storeOfStoreDifference = await this.getStoreOfStoreDifference(
          myStoreOfStoreId:
              myStoreOfStoreId['storesOfStores_representativesId'],
          productsCartsController_productId: "");
      print("got store differnce ${DateTime.now()}");
    }

    for (var i = 0; i < getProducts.length; i = i + 1) {
      print("check $i");
      print("getting cards ${DateTime.now()}");
      var getMyCards = await FirebaseFirestore.instance
          .collection('cards')
          .where("card_sellingStatus", isEqualTo: "false")
          .where("card_status", isEqualTo: "true")
          .where("card_productId", isEqualTo: getProducts[i]['docid'])
          .limit(1)
          .get();
      print("got cards ${DateTime.now()}");

      var data = {"exist": "no", "canBuy": false};

      if (myRole == "محل فرعي") {
        data["canBuy"] = true;
        // storeOfStoreDifference = await this.getStoreOfStoreDifference(myStoreOfStoreId: myStoreOfStoreId['storesOfStores_representativesId'], productsCartsController_productId: getProducts[i]['docid']);
      }

      for (var t = 0; t < getMyCards.docs.length; t = t + 1) {
        if (getMyCards.docs[t].get("card_productId") ==
            getProducts[i]['docid']) {
          data["exist"] = "yes";

          data['product_name'] = getProducts[i]['product_name'];
          data['product_image'] = getProducts[i]['product_image'];
          data['product_expiryDate'] = getMyCards.docs[t]['card_expiryDate'];
          data['docid'] = getProducts[i]['docid'];

          for (var z = 0; z < storeOfStoreDifference.length; z = z + 1) {
            if (storeOfStoreDifference[z]
                    ['storesOfStoresPricesDifference_productId'] ==
                getProducts[i]['docid']) {
              data['product_price'] = (double.parse(storeOfStoreDifference[z]
                          [getMyWhichPrice['store_StoreOfStoresPriceName']]) +
                      double.parse(getProducts[i]['product_price']))
                  .toString();
              data['main_price'] = (double.parse(storeOfStoreDifference[z]
                          [getMyWhichPrice['store_StoreOfStoresPriceName']]) +
                      double.parse(getProducts[i]['product_price']))
                  .toString();

              break;
            } else {
              data['product_price'] = getProducts[i]['product_price'];
              data['main_price'] = getProducts[i]['product_price'];
            }
          }

          if (storeOfStoreDifference.length == 0) {
            data['product_price'] = getProducts[i]['product_price'];
            data['main_price'] = getProducts[i]['product_price'];
          }

          activeAndNonBroughtCards.add(data);

          break;
        }
      }
    }

    /* });
    });*/

    if (activeAndNonBroughtCards.length > 0) {
      return {"status": "available", "data": activeAndNonBroughtCards};
    } else {
      return {
        "status": "notAvailable",
        // "data": activeAndNonBroughtCards[0]
      };
    }
  }

  buyCard2() async {
    userinfoDatabase userInfo = new userinfoDatabase();
    try {
      var storeId = await userInfo.getStoreId();
      Map<String, dynamic> _body = {
        "userid": storeId,
        "productid": productsCartsController_productId,
        "gty": productsCartsController_howmany
      };
      Map<String, String> _header = {
        "Content-Type": "application/json",
        "Accept": "*/*",
      };
      var _bodyCoded = json.encode(_body);
      Uri uri = Uri.parse(
          "https://us-central1-souqcard-3b1be.cloudfunctions.net/buyCard");
      print("send request ${DateTime.now().toString()}");
      final result = await http.post(uri, headers: _header, body: _bodyCoded);
      print("got result in ${DateTime.now().toString()}");
      var decodedBody = json.decode(result.body);
      print("purchase result is ${result.body}");

      if (result.statusCode == 200) {
        List cardSerialNumbers = [];
        List cardsNumbers = [];
        List cardsDates = [];
        List cards = decodedBody['cardList'];
        for (var card in cards) {
          cardSerialNumbers
              .add(card['_fieldsProto']['card_cardSerial']['stringValue']);
          cardsNumbers
              .add(card['_fieldsProto']['card_cardNumber']['stringValue']);
          cardsDates
              .add(card['_fieldsProto']['card_expiryDate']['stringValue']);
        }
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);
        return {
          "status": "success",
          "saveCradsNumbers": cardsNumbers,
          "saveCradsSerial": cardSerialNumbers,
          "saveCardsExpiryDate": cardsDates,
          "broughtDate": formattedDate,
          "newTotalBalance": decodedBody['NewBalance'],
        };
      } else {
        return {
          "status": decodedBody,
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      }
    } catch (e) {
      print("issue buying $e");
      return {
        'status': "مشكلة في التطبيق \n $e",
        "saveCradsNumbers": [],
        "saveCradsSerial": [],
        "saveCardsExpiryDate": [],
      };
    }
  }

  buyTheCard() async {
    // Check If The Card Is Available not brought before
    print("will start the purchase proccess ${DateTime.now()}");
    var checkCardStatus = {"status": "notAvailable"};

    /// productsCartsController_productId
    /// userinfoDatabase userInfo = new userinfoDatabase();
    ///     var storeId = await userInfo.getStoreId();
    ///     productsCartsController_howmany
    int quantityCounter = 0;

    // var cardsArray = [];
    /// get available cards
    var cardsArray = await FirebaseFirestore.instance
        .collection('cards')
        .where("card_sellingStatus", isEqualTo: "false")
        .where("card_status", isEqualTo: "true")
        .where("card_productId", isEqualTo: productsCartsController_productId)
        .limit(int.parse(productsCartsController_howmany))
        .get();

    print("got the cards ${DateTime.now()}");

    /// calculate length and return to user if not available
    if (cardsArray.docs.length > 0) {
      checkCardStatus['quantity'] = cardsArray.docs.length.toString();
      checkCardStatus['status'] = "available";
    } else {
      return {
        "status": "notAvailableQuantity",
        "saveCradsNumbers": [],
        "saveCradsSerial": [],
        "saveCardsExpiryDate": [],
      };
    }

    /*.then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        quantityCounter = quantityCounter + 1;
        checkCardStatus["quantity"] = quantityCounter.toString();
        checkCardStatus["status"] = "available";
        cardsArray.add(doc.id);
      });
    }).catchError((e) {
      print(e.toString());
    });*/

    /// check product availability
    var checkProduct = await FirebaseFirestore.instance
        .collection('products')
        .doc(productsCartsController_productId)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    print("product is available cheacked ${DateTime.now()}");

    if (checkProduct.exists) {
      if (checkProduct.get("product_status") == "true") {
      } else {
        checkCardStatus["status"] = "productNotActive";
      }
    }

    /// check user availability, and status and returning to user if not exist or disabled.
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();
    var checkUserStatus = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();
    if (checkUserStatus.exists) {
      if (checkUserStatus.get("store_status") == "true") {
      } else {
        return {
          "status": "userNotActive",
        };
      }
    } else {
      return {
        "status": "userNotExist",
      };
    }

    print("user available ${DateTime.now()}");

    if (checkCardStatus["status"] == "available") {
      // If Available continue
      // Check My Balance
      balanceController balance = new balanceController();

      /// current balance details
      var myBalance = await balance.getMyBalance();

      print("got my balance ${DateTime.now()}");

      /// check which agent does user belong to otherwise return with failure
      // Get My StoreOfStore Id PhoneNumber
      var myStoreOfStoreId = await this.getMyStoreOfStores();

      if (myStoreOfStoreId["status"] == "myStoreOfStoreNotExist") {
        return {"status": "myStoreOfStoreNotExist"};
      }

      print("check if agent available ${DateTime.now()}");

      /// determine the price group type/value
      // Get My Which Price
      var getMyWhichPrice =
          await this.getMyWhichPrice(myStoreOfStoreId['store_id']);
      print("get the group name ${DateTime.now()}");
      /*if (getMyWhichPrice["status"] == "store_StoreOfStoresPriceNameNotExists") {
        return {
          "status": "store_StoreOfStoresPriceNameNotExists"
        };
      }*/

      /// get the price of the product of the agent
      // Get My Store Of Stores Group Price For Me
      var getMyStoreOfStoresPrice = await this
          .getMyStoreOfStoresPrice(store_id: myStoreOfStoreId['store_id']);
      if (getMyStoreOfStoresPrice['status'] == "store_groupValueNotExist") {
        return {
          "status": "store_groupValueNotExist",
        };
      }
      print("get the group price ${DateTime.now()}");

      // Get Products For Cards name and image and price
      //var getProduct = await this.getOneProductForCardNameImagePrice_withGroupValue(productId: productsCartsController_productId, GroupValue: getMyStoreOfStoresPrice['store_groupValue']);

      /// i think: agent can add a profit value to the product, user will buy with the price for agent + the values added by agent
      ///
      var getProduct = {};
      getProduct["product_name"] = checkProduct.get('product_name');
      getProduct["product_image"] = checkProduct.get('product_image');

      /// i think there is a logical error here, as previously the same exact condition was written and if true there is a return, how come it will still come here, i am not sure what was the programmer wanting
      if (getMyStoreOfStoresPrice['status'] == "store_groupValueNotExist") {
        getProduct["product_price"] =
            checkProduct.get(getMyStoreOfStoresPrice['store_groupValue']);
      } else {
        /// taking the agent price
        getProduct["product_price"] =
            checkProduct.get(getMyStoreOfStoresPrice['store_groupValue']);
      }

      getProduct["product_pricePrivatePrice"] =
          checkProduct.get('product_groupFour_privatePrice');
      getProduct["status"] = "productNotExist";
      getProduct["docid"] = checkProduct.id;

      // Get Store Difference Prices
      /// getting collection of differences between prices of a product according to the group added by the agent
      var storeOfStoreDifference = await this.singleGetStoreOfStoreDifference(
          myStoreOfStoreId:
              myStoreOfStoreId['storesOfStores_representativesId'],
          productsCartsController_productId: productsCartsController_productId);
      var cardPrice = '';
      var profitPrice = '';
      var productPrivatePrice = getProduct['product_pricePrivatePrice'];
      if (storeOfStoreDifference['docid'] == null) {
        // not (same as store price)
        /// go with the agent price
        cardPrice = getProduct['product_price'];
        profitPrice = '0';
      } else {
        /// add the value added by the agent to the price & calculate agent's profit
        cardPrice = (double.parse(storeOfStoreDifference[
                    getMyWhichPrice['store_StoreOfStoresPriceName']]) +
                double.parse(getProduct['product_price']))
            .toString();
        profitPrice = storeOfStoreDifference[
            getMyWhichPrice['store_StoreOfStoresPriceName']];
      }
      print("get the price, and profit ${DateTime.now()}");

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);
      var data = {};

      userinfoDatabase userInfo = new userinfoDatabase();
      var storeId = await userInfo.getStoreId();
      CollectionReference myStore =
          FirebaseFirestore.instance.collection('stores');
      CollectionReference card = FirebaseFirestore.instance.collection('cards');

      var allPrice = (double.parse(cardPrice) *
          int.parse(productsCartsController_howmany.toString()));

      if (int.parse(productsCartsController_howmany) >
          int.parse(checkCardStatus["quantity"].toString())) {
        return {
          "status": "notAvailableQuantity",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (int.parse(productsCartsController_howmany) <= 0) {
        return {
          "status": "lessThenZero",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      }
      print("check cards availablilty  ${DateTime.now()}");

      var newBalance = myBalance['store_totalBalance'];

      var saveRandomIndexInside = [];
      forRandom() {
        var random = new Random();
        int randomIndex;

        if (cardsArray.docs.length == 1) {
          randomIndex = 0;
        } else {
          randomIndex = 0 + random.nextInt((cardsArray.docs.length) - 0);
        }

        var check = true;

        for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
          if (saveRandomIndexInside[i] == randomIndex) {
            check = false;
          }
        }

        if (check == false) {
          forRandom();
          return {"status": "notworked", "randomNumber": 0};
        } else {
          saveRandomIndexInside.add(randomIndex);
          return {
            "status": "worked",
            "randomNumber": randomIndex,
          };
        }
      }

      // Update Card Status and Who Buy it

      print("runing transaction  ${DateTime.now()}");

      var checkTransaction =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        // New Balance
        if (myBalance['store_totalBalance'].toString() == allPrice.toString()) {
          newBalance = "0";
        } else if (double.parse(myBalance['store_totalBalance']) > allPrice) {
          if (double.parse(myBalance['store_cashBalance']) >= allPrice) {
            var price = double.parse(myBalance['store_cashBalance']) - allPrice;
            newBalance = double.parse(newBalance) - allPrice;
          } else if (double.parse(myBalance['store_cashBalance']) < allPrice) {
            var price = allPrice - double.parse(myBalance['store_cashBalance']);
            var depthBalance =
                double.parse(myBalance['store_debtBalance']) - price;

            newBalance = double.parse(newBalance) - allPrice;
          }
        } else {
          return {"status": "needMoreBalance"};
        }

        /*return {
          "status": ""
        };*/

        var saveCradsNumbers = [];
        var saveCradsSerial = [];
        var saveCardsExpiryDate = [];
        var checkIfCan = 0;
        for (var i = 0;
            i < int.parse(productsCartsController_howmany);
            i = i + 1) {
          var checkTheRandom = forRandom();

          if (checkTheRandom["status"] == "worked") {
            var index = checkTheRandom["randomNumber"];
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[int.parse(index.toString())].id);
            var checkCardId = await transaction.get(getCardId);

            if (checkCardId.get("card_sellingStatus") == "false") {
            } else {
              checkIfCan = checkIfCan + 1;
            }
          }
        }

        if (checkIfCan == 0) {
          for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[saveRandomIndexInside[i]].id);
            var getDocData = await transaction.get(getCardId);
            saveCradsNumbers.add(getDocData.get("card_cardNumber"));
            saveCardsExpiryDate.add(getDocData.get("card_expiryDate"));
            saveCradsSerial.add(getDocData.get("card_cardSerial"));
          }

          for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[saveRandomIndexInside[i]].id);
            var checkCardId = await transaction.update(getCardId, {
              "card_sellingStatus": "true",
              "card_status": "true",
              "card_whoBroughtId": storeId,
              "card_BroughtPrice": cardPrice,
              "card_storeOfStoreId":
                  myStoreOfStoreId['storesOfStores_representativesId'],
              "card_storeOfStoreProfit": profitPrice,
              "card_productPrivatePrice": productPrivatePrice,
              "card_broughtDate": formattedDate,
              "card_Quantity": productsCartsController_howmany.toString(),
              "card_balanceBefore": myBalance['store_totalBalance'],
              "card_balanceAfter": newBalance.toString(),
              "card_storeOfStoreRequestStatus": "nothing",
            });
          }

          // Update Store Balance
          if (myBalance['store_totalBalance'].toString() ==
              allPrice.toString()) {
            DocumentReference getStore = FirebaseFirestore.instance
                .collection("stores")
                .doc(storeId.toString());
            await transaction.update(getStore, {
              "store_cashBalance": "0",
              "store_debtBalance": "0",
            });
          } else if (double.parse(myBalance['store_totalBalance']) > allPrice) {
            if (double.parse(myBalance['store_cashBalance']) >= allPrice) {
              var price =
                  double.parse(myBalance['store_cashBalance']) - allPrice;
              // Update Store Balance
              DocumentReference getStore = FirebaseFirestore.instance
                  .collection("stores")
                  .doc(storeId.toString());
              await transaction.update(getStore, {
                "store_cashBalance": price.toString(),
              });
            } else if (double.parse(myBalance['store_cashBalance']) <
                allPrice) {
              var price =
                  allPrice - double.parse(myBalance['store_cashBalance']);
              var depthBalance =
                  double.parse(myBalance['store_debtBalance']) - price;

              // Update Store Balance
              DocumentReference getStore = FirebaseFirestore.instance
                  .collection("stores")
                  .doc(storeId.toString());
              await transaction.update(getStore, {
                "store_cashBalance": "0",
                "store_debtBalance": depthBalance.toString()
              });
            }
          }

          return {
            "status": "success",
            "saveCradsNumbers": saveCradsNumbers,
            "saveCradsSerial": saveCradsSerial,
            "saveCardsExpiryDate": saveCardsExpiryDate
          };
        } else {
          return {
            "status": "error",
            "saveCradsNumbers": [],
            "saveCradsSerial": [],
            "saveCardsExpiryDate": [],
          };
        }
      });
      print("got result${DateTime.now()}");
      if (checkTransaction["status"] == "success") {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);

        return {
          "status": "success",
          "saveCradsNumbers": checkTransaction['saveCradsNumbers'],
          "saveCradsSerial": checkTransaction['saveCradsSerial'],
          "saveCardsExpiryDate": checkTransaction['saveCardsExpiryDate'],
          "broughtDate": formattedDate,
          "newTotalBalance": newBalance.toStringAsFixed(2).toString(),
        };
      } else if (checkTransaction["status"] == "error") {
        return {
          "status": "error",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "needMoreBalance") {
        return {
          "status": "needMoreBalance",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "notAvailableQuantity") {
        return {
          "status": "notAvailableQuantity",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "myStoreOfStoreNotExist") {
        return {
          "status": "myStoreOfStoreNotExist",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      }
    }
  }

  buyTheCard2({
    bool userActive,
    bool userExist,
    var myStoreOfStoreId,
    var getMyWhichPrice,
    var getMyStoreOfStoresPrice,
    var storeId,
  }) async {
    print("will start the purchase proccess ${DateTime.now()}");
    var checkCardStatus = {"status": "notAvailable"};

    /// get available cards
    var cardsArray = await FirebaseFirestore.instance
        .collection('cards')
        .where("card_sellingStatus", isEqualTo: "false")
        .where("card_status", isEqualTo: "true")
        .where("card_productId", isEqualTo: productsCartsController_productId)
        .limit(int.parse(productsCartsController_howmany))
        .get();

    print("got the cards ${DateTime.now()}");

    /// calculate length and return to user if not available
    if (cardsArray.docs.length > 0) {
      checkCardStatus['quantity'] = cardsArray.docs.length.toString();
      checkCardStatus['status'] = "available";
    } else {
      return {
        "status": "notAvailableQuantity",
        "saveCradsNumbers": [],
        "saveCradsSerial": [],
        "saveCardsExpiryDate": [],
      };
    }

    /// check product availability

    /// check user availability, and status and returning to user if not exist or disabled.

    if (userExist) {
      if (userActive) {
      } else {
        return {
          "status": "userNotActive",
        };
      }
    } else {
      return {
        "status": "userNotExist",
      };
    }

    if (checkCardStatus["status"] == "available") {
      // If Available continue
      // Check My Balance
      balanceController balance = new balanceController();

      /// current balance details
      var myBalance = await balance.getMyBalance();

      print("got my balance ${DateTime.now()}");

      /// check which agent does user belong to otherwise return with failure
      // Get My StoreOfStore Id PhoneNumber

      if (myStoreOfStoreId["status"] == "myStoreOfStoreNotExist") {
        return {"status": "myStoreOfStoreNotExist"};
      }

      /// determine the price group type/value
      print("get the group name ${DateTime.now()}");
      /*if (getMyWhichPrice["status"] == "store_StoreOfStoresPriceNameNotExists") {
        return {
          "status": "store_StoreOfStoresPriceNameNotExists"
        };
      }*/

      /// get the price of the product of the agent
      // Get My Store Of Stores Group Price For Me
      if (getMyStoreOfStoresPrice['status'] == "store_groupValueNotExist") {
        return {
          "status": "store_groupValueNotExist",
        };
      }
      print("get the group price ${DateTime.now()}");

      // Get Products For Cards name and image and price
      //var getProduct = await this.getOneProductForCardNameImagePrice_withGroupValue(productId: productsCartsController_productId, GroupValue: getMyStoreOfStoresPrice['store_groupValue']);
      var checkProduct = await FirebaseFirestore.instance
          .collection('products')
          .doc(productsCartsController_productId)
          .get()
          .catchError((e) {
        print(e.toString());
      });
      print("product is available cheacked ${DateTime.now()}");

      if (checkProduct.exists) {
        if (checkProduct.get("product_status") == "true") {
        } else {
          checkCardStatus["status"] = "productNotActive";
        }
      }

      /// i think: agent can add a profit value to the product, user will buy with the price for agent + the values added by agent
      ///
      var getProduct = {};
      getProduct["product_name"] = checkProduct.get('product_name');
      getProduct["product_image"] = checkProduct.get('product_image');

      /// i think there is a logical error here, as previously the same exact condition was written and if true there is a return, how come it will still come here, i am not sure what was the programmer wanting
      if (getMyStoreOfStoresPrice['status'] == "store_groupValueNotExist") {
        getProduct["product_price"] =
            checkProduct.get(getMyStoreOfStoresPrice['store_groupValue']);
      } else {
        /// taking the agent price
        getProduct["product_price"] =
            checkProduct.get(getMyStoreOfStoresPrice['store_groupValue']);
      }

      getProduct["product_pricePrivatePrice"] =
          checkProduct.get('product_groupFour_privatePrice');
      getProduct["status"] = "productNotExist";
      getProduct["docid"] = checkProduct.id;

      // Get Store Difference Prices
      /// getting collection of differences between prices of a product according to the group added by the agent
      var storeOfStoreDifference = await this.singleGetStoreOfStoreDifference(
          myStoreOfStoreId:
              myStoreOfStoreId['storesOfStores_representativesId'],
          productsCartsController_productId: productsCartsController_productId);
      var cardPrice = '';
      var profitPrice = '';
      var productPrivatePrice = getProduct['product_pricePrivatePrice'];
      if (storeOfStoreDifference['docid'] == null) {
        // not (same as store price)
        /// go with the agent price
        cardPrice = getProduct['product_price'];
        profitPrice = '0';
      } else {
        /// add the value added by the agent to the price & calculate agent's profit
        cardPrice = (double.parse(storeOfStoreDifference[
                    getMyWhichPrice['store_StoreOfStoresPriceName']]) +
                double.parse(getProduct['product_price']))
            .toString();
        profitPrice = storeOfStoreDifference[
            getMyWhichPrice['store_StoreOfStoresPriceName']];
      }
      print("get the price, and profit ${DateTime.now()}");

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);
      var data = {};

      userinfoDatabase userInfo = new userinfoDatabase();
      CollectionReference myStore =
          FirebaseFirestore.instance.collection('stores');
      CollectionReference card = FirebaseFirestore.instance.collection('cards');

      var allPrice = (double.parse(cardPrice) *
          int.parse(productsCartsController_howmany.toString()));

      if (int.parse(productsCartsController_howmany) >
          int.parse(checkCardStatus["quantity"].toString())) {
        return {
          "status": "notAvailableQuantity",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (int.parse(productsCartsController_howmany) <= 0) {
        return {
          "status": "lessThenZero",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      }
      print("check cards availablilty  ${DateTime.now()}");

      var newBalance = myBalance['store_totalBalance'];

      var saveRandomIndexInside = [];
      forRandom() {
        var random = new Random();
        int randomIndex;

        if (cardsArray.docs.length == 1) {
          randomIndex = 0;
        } else {
          randomIndex = 0 + random.nextInt((cardsArray.docs.length) - 0);
        }

        var check = true;

        for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
          if (saveRandomIndexInside[i] == randomIndex) {
            check = false;
          }
        }

        if (check == false) {
          forRandom();
          return {"status": "notworked", "randomNumber": 0};
        } else {
          saveRandomIndexInside.add(randomIndex);
          return {
            "status": "worked",
            "randomNumber": randomIndex,
          };
        }
      }

      // Update Card Status and Who Buy it

      print("runing transaction  ${DateTime.now()}");

      var checkTransaction =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        // New Balance
        if (myBalance['store_totalBalance'].toString() == allPrice.toString()) {
          newBalance = "0";
        } else if (double.parse(myBalance['store_totalBalance']) > allPrice) {
          if (double.parse(myBalance['store_cashBalance']) >= allPrice) {
            var price = double.parse(myBalance['store_cashBalance']) - allPrice;
            newBalance = double.parse(newBalance) - allPrice;
          } else if (double.parse(myBalance['store_cashBalance']) < allPrice) {
            var price = allPrice - double.parse(myBalance['store_cashBalance']);
            var depthBalance =
                double.parse(myBalance['store_debtBalance']) - price;

            newBalance = double.parse(newBalance) - allPrice;
          }
        } else {
          return {"status": "needMoreBalance"};
        }

        /*return {
          "status": ""
        };*/

        var saveCradsNumbers = [];
        var saveCradsSerial = [];
        var saveCardsExpiryDate = [];
        var checkIfCan = 0;
        for (var i = 0;
            i < int.parse(productsCartsController_howmany);
            i = i + 1) {
          var checkTheRandom = forRandom();

          if (checkTheRandom["status"] == "worked") {
            var index = checkTheRandom["randomNumber"];
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[int.parse(index.toString())].id);
            var checkCardId = await transaction.get(getCardId);

            if (checkCardId.get("card_sellingStatus") == "false") {
            } else {
              checkIfCan = checkIfCan + 1;
            }
          }
        }

        if (checkIfCan == 0) {
          for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[saveRandomIndexInside[i]].id);
            var getDocData = await transaction.get(getCardId);
            saveCradsNumbers.add(getDocData.get("card_cardNumber"));
            saveCardsExpiryDate.add(getDocData.get("card_expiryDate"));
            saveCradsSerial.add(getDocData.get("card_cardSerial"));
          }

          for (var i = 0; i < saveRandomIndexInside.length; i = i + 1) {
            DocumentReference getCardId = FirebaseFirestore.instance
                .collection("cards")
                .doc(cardsArray.docs[saveRandomIndexInside[i]].id);
            var checkCardId = await transaction.update(getCardId, {
              "card_sellingStatus": "true",
              "card_status": "true",
              "card_whoBroughtId": storeId,
              "card_BroughtPrice": cardPrice,
              "card_storeOfStoreId":
                  myStoreOfStoreId['storesOfStores_representativesId'],
              "card_storeOfStoreProfit": profitPrice,
              "card_productPrivatePrice": productPrivatePrice,
              "card_broughtDate": formattedDate,
              "card_Quantity": productsCartsController_howmany.toString(),
              "card_balanceBefore": myBalance['store_totalBalance'],
              "card_balanceAfter": newBalance.toString(),
              "card_storeOfStoreRequestStatus": "nothing",
            });
          }

          // Update Store Balance
          if (myBalance['store_totalBalance'].toString() ==
              allPrice.toString()) {
            DocumentReference getStore = FirebaseFirestore.instance
                .collection("stores")
                .doc(storeId.toString());
            await transaction.update(getStore, {
              "store_cashBalance": "0",
              "store_debtBalance": "0",
            });
          } else if (double.parse(myBalance['store_totalBalance']) > allPrice) {
            if (double.parse(myBalance['store_cashBalance']) >= allPrice) {
              var price =
                  double.parse(myBalance['store_cashBalance']) - allPrice;
              // Update Store Balance
              DocumentReference getStore = FirebaseFirestore.instance
                  .collection("stores")
                  .doc(storeId.toString());
              await transaction.update(getStore, {
                "store_cashBalance": price.toString(),
              });
            } else if (double.parse(myBalance['store_cashBalance']) <
                allPrice) {
              var price =
                  allPrice - double.parse(myBalance['store_cashBalance']);
              var depthBalance =
                  double.parse(myBalance['store_debtBalance']) - price;

              // Update Store Balance
              DocumentReference getStore = FirebaseFirestore.instance
                  .collection("stores")
                  .doc(storeId.toString());
              await transaction.update(getStore, {
                "store_cashBalance": "0",
                "store_debtBalance": depthBalance.toString()
              });
            }
          }

          return {
            "status": "success",
            "saveCradsNumbers": saveCradsNumbers,
            "saveCradsSerial": saveCradsSerial,
            "saveCardsExpiryDate": saveCardsExpiryDate
          };
        } else {
          return {
            "status": "error",
            "saveCradsNumbers": [],
            "saveCradsSerial": [],
            "saveCardsExpiryDate": [],
          };
        }
      });
      print("got result${DateTime.now()}");
      if (checkTransaction["status"] == "success") {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);

        return {
          "status": "success",
          "saveCradsNumbers": checkTransaction['saveCradsNumbers'],
          "saveCradsSerial": checkTransaction['saveCradsSerial'],
          "saveCardsExpiryDate": checkTransaction['saveCardsExpiryDate'],
          "broughtDate": formattedDate,
          "newTotalBalance": newBalance.toStringAsFixed(2).toString(),
        };
      } else if (checkTransaction["status"] == "error") {
        return {
          "status": "error",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "needMoreBalance") {
        return {
          "status": "needMoreBalance",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "notAvailableQuantity") {
        return {
          "status": "notAvailableQuantity",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      } else if (checkTransaction["status"] == "myStoreOfStoreNotExist") {
        return {
          "status": "myStoreOfStoreNotExist",
          "saveCradsNumbers": [],
          "saveCradsSerial": [],
          "saveCardsExpiryDate": [],
        };
      }
    }
  }
}
