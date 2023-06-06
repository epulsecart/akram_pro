import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

class editProductsController {

  String editProducts_id;
  String editProducts_storesOfStoresPricesDifference_groupOne;
  String editProducts_storesOfStoresPricesDifference_groupTwo;
  String editProducts_storesOfStoresPricesDifference_groupThree;
  String editProducts_storesOfStoresPricesDifference_groupFour;
  String editProducts_storesOfStoresPricesDifferenceId;

  editProductsController({
     this.editProducts_id,
     this.editProducts_storesOfStoresPricesDifference_groupOne,
     this.editProducts_storesOfStoresPricesDifference_groupTwo,
     this.editProducts_storesOfStoresPricesDifference_groupThree,
     this.editProducts_storesOfStoresPricesDifference_groupFour,
     this.editProducts_storesOfStoresPricesDifferenceId,
  });

  factory editProductsController.fromJson(Map<String,dynamic>json){
    return editProductsController(
      editProducts_id: json['editProducts_id'],
      editProducts_storesOfStoresPricesDifference_groupOne: json['editProducts_storesOfStoresPricesDifference_groupOne'],
      editProducts_storesOfStoresPricesDifference_groupTwo: json['editProducts_storesOfStoresPricesDifference_groupTwo'],
      editProducts_storesOfStoresPricesDifference_groupThree: json['editProducts_storesOfStoresPricesDifference_groupThree'],
      editProducts_storesOfStoresPricesDifference_groupFour: json['editProducts_storesOfStoresPricesDifference_groupFour'],
      editProducts_storesOfStoresPricesDifferenceId: json['editProducts_storesOfStoresPricesDifferenceId'],
    );
  }




  // Get Products For Edit
  getProductsStoreOfStores () async {

    userinfoDatabase userInfo = new userinfoDatabase();

    var storeId = await userInfo.getStoreId();
    var storePhoneNumber = await userInfo.getUserphonenumber();

    var storeData = {};
    await FirebaseFirestore.instance
        .collection('stores')
        .where("store_phoneNumber", isEqualTo: storePhoneNumber.toString())
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            storeData['store_storeGroupName'] = doc['store_storeGroupName'];
            storeData['store_groupValue'] = doc['store_groupValue'];
          });
    });

    var companiesData = [];
    // Get Companies For Products
    await FirebaseFirestore.instance
        .collection('companies')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        companiesData.add({
          "companies_name": doc['companies_name'],
          "companies_image": doc['companies_image'],
          "docid": doc.id,
        });
      });
    });




    // Get Current User Store Prices
    var userStorePrices = [];
    await FirebaseFirestore.instance
        .collection('storesOfStoresPricesDifference')
        .where("storesOfStoresPricesDifference_storeid", isEqualTo: storeId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        userStorePrices.add({
          "storesOfStoresPricesDifference_groupOne": doc["storesOfStoresPricesDifference_groupOne"],
          "storesOfStoresPricesDifference_groupTwo": doc["storesOfStoresPricesDifference_groupTwo"],
          "storesOfStoresPricesDifference_groupThree": doc["storesOfStoresPricesDifference_groupThree"],
          "storesOfStoresPricesDifference_groupFour": doc["storesOfStoresPricesDifference_groupFour"],
          "storesOfStoresPricesDifference_productId": doc["storesOfStoresPricesDifference_productId"],
          "docid": doc.id,
        });
      });
    });
    var getProductsData = [];
    await FirebaseFirestore.instance
        .collection('products')
        .where("product_status", isEqualTo: "true")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var data = {
          'product_name': doc['product_name'],
          'product_storeGroupName': storeData['store_storeGroupName'],
          'product_image': doc['product_image'],
          'product_price': doc[storeData['store_groupValue']],
          'docid': doc.id,
          "product_companyId": doc["product_companyId"],
        };

        for (var i = 0; i < companiesData.length; i = i + 1) {
          if (doc["product_companyId"] == companiesData[i]["docid"]) {
            data["product_companyName"] = companiesData[i]["companies_name"];

            break;
          } else {
            data["product_companyName"] = "";
          }
        }

        for (var i = 0; i < userStorePrices.length; i = i + 1) {
          if (doc.id == userStorePrices[i]["storesOfStoresPricesDifference_productId"]) {
            data["storesOfStoresPricesDifference_groupOne"] = userStorePrices[i]["storesOfStoresPricesDifference_groupOne"];
            data["storesOfStoresPricesDifference_groupTwo"] = userStorePrices[i]["storesOfStoresPricesDifference_groupTwo"];
            data["storesOfStoresPricesDifference_groupThree"] = userStorePrices[i]["storesOfStoresPricesDifference_groupThree"];
            data["storesOfStoresPricesDifference_groupFour"] = userStorePrices[i]["storesOfStoresPricesDifference_groupFour"];
            data["storesOfStoresPricesDifference_id"] = userStorePrices[i]["docid"];
            break;
          } else {
            data["storesOfStoresPricesDifference_groupOne"] = "";
            data["storesOfStoresPricesDifference_groupTwo"] = "";
            data["storesOfStoresPricesDifference_groupThree"] = "";
            data["storesOfStoresPricesDifference_groupFour"] = "";
            data["storesOfStoresPricesDifference_id"] = "";
          }
        }

        if (userStorePrices.length == 0) {
          data["storesOfStoresPricesDifference_groupOne"] = "";
          data["storesOfStoresPricesDifference_groupTwo"] = "";
          data["storesOfStoresPricesDifference_groupThree"] = "";
          data["storesOfStoresPricesDifference_groupFour"] = "";
          data["storesOfStoresPricesDifference_id"] = "";
        }

        getProductsData.add(data);
      });
    });



    return getProductsData;
  }


  addStoreOfStoresPrices () async {
    var storeData = [];

    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    await FirebaseFirestore.instance
        .collection('storesOfStoresPricesDifference')
        .where("storesOfStoresPricesDifference_storeid", isEqualTo: storeId)
        .where("storesOfStoresPricesDifference_productId", isEqualTo: editProducts_id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        storeData.add(doc);
      });
    });

    CollectionReference storeEditPrice = FirebaseFirestore.instance.collection('storesOfStoresPricesDifference');

    if (storeData.length == 0) {
      DocumentReference storeAddPrice = await storeEditPrice
          .add({
        "storesOfStoresPricesDifference_storeid": storeId,
        "storesOfStoresPricesDifference_productId": editProducts_id,
        "storesOfStoresPricesDifference_groupOne": editProducts_storesOfStoresPricesDifference_groupOne,
        "storesOfStoresPricesDifference_groupTwo": editProducts_storesOfStoresPricesDifference_groupTwo,
        "storesOfStoresPricesDifference_groupThree": editProducts_storesOfStoresPricesDifference_groupThree,
        "storesOfStoresPricesDifference_groupFour": editProducts_storesOfStoresPricesDifference_groupFour,
      });

      return {
        'status': 'addedOrEdited',
        'docid': storeAddPrice.id
      };
    } else {
      await storeEditPrice
          .doc(editProducts_storesOfStoresPricesDifferenceId)
          .update({
        "storesOfStoresPricesDifference_groupOne": editProducts_storesOfStoresPricesDifference_groupOne,
        "storesOfStoresPricesDifference_groupTwo": editProducts_storesOfStoresPricesDifference_groupTwo,
        "storesOfStoresPricesDifference_groupThree": editProducts_storesOfStoresPricesDifference_groupThree,
        "storesOfStoresPricesDifference_groupFour": editProducts_storesOfStoresPricesDifference_groupFour,
      })
          .then((value) => print("Product Updated"))
          .catchError((error) => print("Failed to update product:"));

      return {
        'status': 'addedOrEdited',
        'docid': ''
      };
    }
  }

}