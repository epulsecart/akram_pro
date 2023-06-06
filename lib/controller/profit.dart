// @dart=2.11

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

class profitController {

  var profit_totalProfitRequest;

  profitController({
    this.profit_totalProfitRequest
  });

  factory profitController.fromJson(Map<String,dynamic>json){
    return profitController(
      profit_totalProfitRequest: json['profit_totalProfitRequest'],
    );
  }

  // Get My Profit
  getMyProfit () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var getMyProfit = [];

    await FirebaseFirestore.instance
        .collection('cards')
        .where("card_sellingStatus", isEqualTo: "true")
        .where("card_storeOfStoreId", isEqualTo: storeId)
        .where("card_storeOfStoreProfit", isNotEqualTo: "0")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var data = {};
        data["card_BroughtPrice"] = doc["card_BroughtPrice"];
        data["card_storeOfStoreProfit"] = doc["card_storeOfStoreProfit"];
        data["card_whoBroughtId"] = doc['card_whoBroughtId'];
        data["card_productId"] = doc['card_productId'];
        data["card_broughtDate"] = doc['card_broughtDate'];
        data["card_date"] = doc['card_date'];
        data["card_storeOfStoreRequestStatus"] = doc['card_storeOfStoreRequestStatus'];
        data["card_storeOfStoreProfit"] = doc['card_storeOfStoreProfit'];

        getMyProfit.add(data);
      });
    });


    // Get Products Names And Image
    await FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        for (var i = 0; i < getMyProfit.length; i = i + 1) {
          if (getMyProfit[i]['card_productId'] == doc.id) {
            getMyProfit[i]['card_productName'] = doc['product_name'];
            getMyProfit[i]['card_productImage'] = doc['product_image'];
          }
        }
      });
    });

    List storesId = [];
    getMyProfit
        .where((doc) {
      storesId.add(doc["card_whoBroughtId"]);
      return true;
    }).toList();
    storesId = storesId.toSet().toList();
    storesId.add('');

    // Get Store Name Who Brought It
    var getStores = await FirebaseFirestore.instance
        .collection('stores')
      //  .where("store_id", whereIn: storesId)
        .get();

    for (var i = 0; i < getMyProfit.length; i = i + 1) {
      for (var t = 0; t < getStores.docs.length; t = t + 1) {
        if (getMyProfit[i]['card_whoBroughtId'] == getStores.docs[t].id) {
          getMyProfit[i]['card_whoBroughtName'] =  getStores.docs[t].get('store_name');
          break;
        } else {
          getMyProfit[i]['card_whoBroughtName'] = "";
        }
      }
    }

    List profit_nothing = [];
    List profit_pending = [];
    List profit_accepted = [];

    double totalProfit_nothing = 0;
    double totalProfit_pending = 0;
    double totalProfit_accepted = 0;
    for (var i = 0; i < getMyProfit.length; i = i + 1) {
      if (getMyProfit[i]['card_storeOfStoreRequestStatus'] == "nothing") {
        profit_nothing.add(getMyProfit[i]);
        totalProfit_nothing = totalProfit_nothing + double.parse(getMyProfit[i]["card_storeOfStoreProfit"]);
      } else if (getMyProfit[i]['card_storeOfStoreRequestStatus'] == "pending") {
        profit_pending.add(getMyProfit[i]);
        totalProfit_pending = totalProfit_pending + double.parse(getMyProfit[i]["card_storeOfStoreProfit"]);
      } else if (getMyProfit[i]['card_storeOfStoreRequestStatus'] == "accepted") {
        profit_accepted.add(getMyProfit[i]);
        totalProfit_accepted = totalProfit_accepted + double.parse(getMyProfit[i]["card_storeOfStoreProfit"]);
      }
    }

    return {
      "profit_nothing": profit_nothing,
      "profit_pending": profit_pending,
      "profit_accepted": profit_accepted,
      "totalProfit_nothing": totalProfit_nothing,
      "totalProfit_pending": totalProfit_pending,
      "totalProfit_accepted": totalProfit_accepted,
    };
  }

  requestMyProfit () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    var counter = 0;

    await FirebaseFirestore.instance
        .collection('cards')
        .where("card_sellingStatus", isEqualTo: "true")
        .where("card_storeOfStoreRequestStatus", isEqualTo: "nothing")
        .where("card_storeOfStoreId", isEqualTo: storeId)
        .where("card_storeOfStoreProfit", isNotEqualTo: "0")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (counter < 500) {
          batch.update(doc.reference, {
            "card_storeOfStoreRequestStatus": "pending",
            "card_storeOfStoreRequestTime": formattedDate,
          });
        }

        counter = counter + 1;
      });

      return batch.commit();
    });

    return {
      "status": "success",
    };
  }

}