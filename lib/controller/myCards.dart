// @dart=2.11

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

class myCardsController {

  String myCards_id;
  var myCards_dateFrom;
  var myCards_dateTo;

  myCardsController({
    this.myCards_id,
    this.myCards_dateFrom,
    this.myCards_dateTo
  });

  factory myCardsController.fromJson(Map<String,dynamic>json){
    return myCardsController(
      myCards_id: json['myCards_id'],
      myCards_dateFrom: json['myCards_dateFrom'],
      myCards_dateTo: json['myCards_dateTo'],
    );
  }

  var getCardsProducts = [];
  var getCardsCompanies = [];
  var getCardsArray = [];
  List<DocumentSnapshot> getCardsData;

  // Get My Cards
  getMyCards ({myCards_dateFrom, myCards_dateTo}) async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var getRequests;
    if (getCardsArray.length != 0) {
      getRequests = await FirebaseFirestore.instance
          .collection('cards')
          .where("card_whoBroughtId", isEqualTo: storeId)
          .where("card_sellingStatus", isEqualTo: "true")
          .orderBy("card_broughtDate", descending: true)
          .startAfterDocument(getCardsData[getCardsData.length - 1])
          .limit(50)
          .get();

      getCardsData = getCardsData + getRequests.docs;

    } else {
      getRequests = await FirebaseFirestore.instance
          .collection('cards')
          .where("card_whoBroughtId", isEqualTo: storeId)
          .where("card_sellingStatus", isEqualTo: "true")
          .orderBy("card_broughtDate", descending: true)
          .limit(50)
          .get();
      getCardsData = getRequests.docs;
    }

    for (var i = 0; i < getRequests.docs.length; i = i + 1) {
      var data = {};

      if (myCards_dateFrom != null && myCards_dateTo != null) {
        var cardDate = DateTime.parse(getRequests.docs[i]["card_broughtDate"].split(" –")[0]);
        if((cardDate.isAfter(myCards_dateFrom) || cardDate.isAtSameMomentAs(myCards_dateFrom)) && (cardDate.isBefore(myCards_dateTo) || cardDate.isAtSameMomentAs(myCards_dateTo))) {
          data["card_BroughtPrice"] = getRequests.docs[i]["card_BroughtPrice"];
          data["card_cardNumber"] = getRequests.docs[i]["card_cardNumber"];
          data["card_cardSerial"] = getRequests.docs[i]["card_cardSerial"];
          data["card_productId"] = getRequests.docs[i]["card_productId"];
          data["card_broughtDate"] = getRequests.docs[i]["card_broughtDate"];

          data["card_balanceBefore"] = getRequests.docs[i]["card_balanceBefore"];
          data["card_balanceAfter"] = getRequests.docs[i]["card_balanceAfter"];

          getCardsArray.add(data);
        }
      } else {
        data["card_BroughtPrice"] = getRequests.docs[i]["card_BroughtPrice"];
        data["card_cardNumber"] = getRequests.docs[i]["card_cardNumber"];
        data["card_cardSerial"] = getRequests.docs[i]["card_cardSerial"];
        data["card_productId"] = getRequests.docs[i]["card_productId"];
        data["card_broughtDate"] = getRequests.docs[i]["card_broughtDate"];
        data["card_expiryDate"] = getRequests.docs[i]["card_expiryDate"];
        data["card_balanceBefore"] = getRequests.docs[i]["card_balanceBefore"];
        data["card_balanceAfter"] = getRequests.docs[i]["card_balanceAfter"];

        getCardsArray.add(data);
      }
    }

    if (getCardsProducts.length == 0) {
      await FirebaseFirestore.instance
          .collection('products')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          getCardsProducts.add({
            "docid": doc.id,
            "product_name": doc.get("product_name"),
            "product_image": doc.get("product_image"),
            "product_companyId": doc.get("product_companyId"),
          });
        });
      });
    }

    if (getCardsCompanies.length == 0) {
      await await FirebaseFirestore.instance
          .collection('companies')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          getCardsCompanies.add({
            "docid": doc.id,
            "companies_name": doc.get("companies_name"),
            "companies_printinglogo": doc.get("companies_printinglogo"),
          });
        });
      });
    }

    for (var i = 0; i < getCardsArray.length; i = i + 1) {

      for (var t = 0; t < getCardsProducts.length; t = t + 1) {
        if (getCardsArray[i]['card_productId'] == getCardsProducts[t]['docid']) {
          getCardsArray[i]['card_productName'] = getCardsProducts[t]['product_name'];
          getCardsArray[i]['card_productImage'] = getCardsProducts[t]['product_image'];
          print("taha7");

          // Companies
          for (var z = 0; z < getCardsCompanies.length; z = z + 1) {
            if (getCardsProducts[t]["product_companyId"] == getCardsCompanies[z]['docid']) {
              getCardsArray[i]['card_productCompany'] = getCardsCompanies[z]["companies_name"];
              getCardsArray[i]['card_productCompanyId'] = getCardsProducts[t]["product_companyId"];
              getCardsArray[i]['card_productCompanyPrintingImage'] = getCardsCompanies[z]["companies_printinglogo"];

              break;
            }
          }
          break;
        } else {
          getCardsArray[i]['card_productName'] = "";
          getCardsArray[i]['card_productImage'] = "";

          getCardsArray[i]['card_productCompany'] = "";
          getCardsArray[i]['card_productCompanyId'] = "";
          getCardsArray[i]['card_productCompanyPrintingImage'] = "";
        }


      }
    }

    return getCardsArray;
  }

}