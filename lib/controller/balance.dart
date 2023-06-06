// @dart=2.11

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

import 'notification.dart';

class balanceController {

  String balance_RequestAmount;
  String balance_RequestAmountType;
  String stores_indebtedness;

  balanceController({
     this.balance_RequestAmount,
     this.balance_RequestAmountType,
      this.stores_indebtedness
  });

  factory balanceController.fromJson(Map<String,dynamic>json){
    return balanceController(
      balance_RequestAmount: json['balance_RequestAmount'],
      balance_RequestAmountType: json['balance_RequestAmountType'],
      stores_indebtedness: json['stores_indebtedness'],
    );
  }



  var getStoresBalanceHistory = [];
  var getBalanceHistoryArray = [];
  List<DocumentSnapshot> getDataHistoryArray;
  var getBalanceHistoryStoresArray = [];
  var getHistoryData = [];
  // Get Balance History
  getBalanceHistory () async {

    userinfoDatabase userInfo = new userinfoDatabase();

    var storeId = await userInfo.getStoreId();
    var storeRole = await userInfo.getStoreRole();



    var getRequests;
    if (getHistoryData.length != 0) {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceHistory')
      //.where("balanceHistory_receiver", isEqualTo: storeId)
          .orderBy("balanceHistory_date", descending: true)
          .startAfterDocument(getDataHistoryArray[getDataHistoryArray.length - 1])
          .limit(300)
          .get();

      getDataHistoryArray = getDataHistoryArray + getRequests.docs;

    } else {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceHistory')
      //.where("balanceHistory_receiver", isEqualTo: storeId)
          .orderBy("balanceHistory_date", descending: true)
          .limit(300)
          .get();
      getDataHistoryArray = getRequests.docs;
    }

    for (var i = 0; i < getRequests.docs.length; i = i + 1) {
      print("match1");
      print(getRequests.docs[i]["balanceHistory_receiver"]);
      print(getRequests.docs[i]["balanceHistory_sender"]);

      if (getRequests.docs[i]["balanceHistory_receiver"] == storeId || getRequests.docs[i]["balanceHistory_sender"] == storeId) {
        print("match");
        var data = {
          'balanceHistory_date': getRequests.docs[i]['balanceHistory_date'],
          'balanceHistory_addPrice': double.parse(getRequests.docs[i]['balanceHistory_addPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_beforeCashPrice': double.parse(getRequests.docs[i]['balanceHistory_beforeCashPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_afterCashPrice': double.parse(getRequests.docs[i]['balanceHistory_afterCashPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_beforeDebtPrice': double.parse(getRequests.docs[i]['balanceHistory_beforeDebtPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_afterDebtPrice': double.parse(getRequests.docs[i]['balanceHistory_afterDebtPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_priceType': getRequests.docs[i]['balanceHistory_priceType'],
          'balanceHistory_sender': getRequests.docs[i]['balanceHistory_sender'],
          'balanceHistory_receiver': getRequests.docs[i]['balanceHistory_receiver'],
          'balanceHistory_BeforeIndebtednessPrice': double.parse(getRequests.docs[i]['balanceHistory_BeforeIndebtednessPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_AfterIndebtednessPrice': double.parse(getRequests.docs[i]['balanceHistory_AfterIndebtednessPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_receiverName': "",
          'id': getRequests.docs[i].id
        };

        if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveCashBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد كاش";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveDebtBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد آجل";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendCashBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendDebtBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendIndebtednessToStore") {
          data['balanceHistory_priceType'] = "إرسال مديونية لمحل";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "AdminSendIndebtednessToStore") {
          data['balanceHistory_priceType'] = "إرسال مديونية من الأدمن";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "AdminSendCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش من الأدمن";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "AdminSendDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل من الأدمن";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "AdminRetrieveCashBalanceToStore") {
          data['balanceHistory_priceType'] = "سحب رصيد كاش من الأدمن";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "AdminRetrieveDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "سحب رصيد آجل من الأدمن";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد كاش";
        } else if (getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد آجل";
        }

        if ((getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendCashBalanceToStore" ||
            getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreSendDebtBalanceToStore" ||
            getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveCashBalanceToStore" ||
            getRequests.docs[i]['balanceHistory_priceType'] == "StoreOfStoreRetrieveDebtBalanceToStore") && storeRole == "مندوب"
        ) {

        } else {


          if (getRequests.docs[i].data().toString().contains("balanceHistory_storeReceiver")) {
            print("yes yes");
            data['balanceHistory_storeReceiver'] = getRequests.docs[i]['balanceHistory_storeReceiver'];
            // for (var t = 0; t < stores.docs.length; t = t + 1) {
            //   if (doc["balanceHistory_storeReceiver"] == stores.docs[t].id) {
            //     data["balanceHistory_receiverName"] = stores.docs[t].get("store_name");
            //     break;
            //   } else {
            //     data["balanceHistory_receiverName"] = "";
            //   }
            // }
          } else {
            data['balanceHistory_storeReceiver'] = "";
          }

          getHistoryData.add(data);
        }
      }
    }


    if (storeRole == "مندوب") {

      List storesId = [];
      getHistoryData
          .where((doc) {
        if (doc["balanceHistory_storeReceiver"] != "") {
          storesId.add(doc['balanceHistory_storeReceiver']);
        }
        return true;
      }).toList();
      storesId = storesId.toSet().toList();
      storesId.add('');

      if (getBalanceHistoryStoresArray.length == 0) {
        var stores = await FirebaseFirestore.instance
            .collection('stores')
        // .where("store_id", whereIn: storesId)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            getBalanceHistoryStoresArray.add({
              "docid": doc.id,
              "store_name": doc.get("store_name"),
            });
          });
        });
      }


      for (var i = 0; i < getHistoryData.length; i = i + 1) {
        for (var t = 0; t < getBalanceHistoryStoresArray.length; t = t + 1) {
          if (getHistoryData[i]["balanceHistory_storeReceiver"] == getBalanceHistoryStoresArray[t]['docid']) {
            getHistoryData[i]["balanceHistory_receiverName"] = getBalanceHistoryStoresArray[t]['store_name'];
            break;
          } else {
            getHistoryData[i]["balanceHistory_receiverName"] = "";
          }
        }
      }


    }



    return getHistoryData;
  }

  // Request Balance
  requestBalance () async {
    userinfoDatabase userInfo = new userinfoDatabase();

    var storeId = await userInfo.getStoreId();
    var storeRole = await userInfo.getStoreRole();

    CollectionReference balanceRequest = FirebaseFirestore.instance.collection('balanceRequest');

    // balance_RequestAmount

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);

    var data = {
      "balanceRequest_amount": balance_RequestAmount,
      "balanceRequest_storeRequestId": storeId,
      "balanceRequest_amountType": balance_RequestAmountType,
      "balanceRequest_date": formattedDate,
      "balanceRequest_amountTypeEdit": "",
      "balanceRequest_status": "pending"
    };

    var getMyParentStoreArray = [];

    if (storeRole == "مندوب") {
      data['balanceRequest_to'] = "admin";
    } else {
      CollectionReference getMyParentStore = FirebaseFirestore.instance.collection('storesOfStores');


      await FirebaseFirestore.instance
          .collection('storesOfStores')
          .where("storesOfStores_storeId", isEqualTo: storeId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          //print("doc['storesOfStores_representativesId']");
          //print(doc['storesOfStores_representativesId']);
          getMyParentStoreArray.add({
            "parentStoreId": doc['storesOfStores_representativesId']
          });
        });
      });

      if (getMyParentStoreArray.length == 0) {
        data['balanceRequest_to'] = "admin";
      } else {
        data['balanceRequest_to'] = getMyParentStoreArray[0]['parentStoreId'];
      }
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Store
      DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(storeId);
      var getStoreData = await transaction.get(getStore);

      // Store Of Store
      DocumentReference getStoreOfStore;
      var getStoreOfStoreData;
      if (storeRole != "مندوب") {
        getStoreOfStore = FirebaseFirestore.instance.collection("stores").doc(getMyParentStoreArray[0]['parentStoreId']);
        getStoreOfStoreData = await transaction.get(getStoreOfStore);
      }

      CollectionReference requestBalance = FirebaseFirestore.instance.collection('balanceRequest');
      var randomStoreId = getRandomString(20);
      DocumentReference notExistRequestBalanceTable = requestBalance.doc(randomStoreId);
      transaction.set(notExistRequestBalanceTable, data);

      /*DocumentReference requestBalanceAdd = await balanceRequest
          .add(data);*/

      if (storeRole != "مندوب") {

        var priceTypeName = "";
        if (balance_RequestAmountType == "كاش") {
          priceTypeName = "storeRequestCashBalanceFromStoreOfStore";
        } else if (balance_RequestAmountType == "آجل") {
          priceTypeName = "storeRequestDebtBalanceFromStoreOfStore";
        }

        // Send Notification For Store
        DateTime notiDate = DateTime.now();
        String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);
        var newNotiString = getRandomString(20);
        CollectionReference notification = FirebaseFirestore.instance
            .collection('notifications');
        DocumentReference notExistMyNotification = notification.doc(newNotiString);
        transaction.set(notExistMyNotification, {
          "notification_sender": storeId,
          "notification_receiver": getMyParentStoreArray[0]['parentStoreId'],
          "notification_type": priceTypeName,
          "notification_amount": balance_RequestAmount,
          "notification_new": "yes",
          "notification_date": notiFormDate,
        });

        // Send Notification




        notificationClass notificationRequest = new notificationClass();
        notificationRequest.sendNotification(
          token: getStoreOfStoreData.get("store_token"),
          notification_type: priceTypeName,
          notification_amount: balance_RequestAmount,
          notification_senderName: getStoreData.get("store_name"),
          notification_date: notiFormDate,
          notification_sender: storeId,
          notification_receiver: getMyParentStoreArray[0]['parentStoreId'],
          docid: newNotiString,
        );
      }
    });


    return "requested";
  }

  String getRandomString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }


  var getBalanceRequestsArray = [];
  List<DocumentSnapshot> getDataRequests;


  // Get Balance Requests
  getBalanceRequests () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var getRequests;
    if (getBalanceRequestsArray.length != 0) {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceRequest')
          .where("balanceRequest_storeRequestId", isEqualTo: storeId)
          .orderBy("balanceRequest_date", descending: true)
          .startAfterDocument(getDataRequests[getDataRequests.length - 1])
          .limit(100)
          .get();

      getDataRequests = getDataRequests + getRequests.docs;

    } else {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceRequest')
          .where("balanceRequest_storeRequestId", isEqualTo: storeId)
          .orderBy("balanceRequest_date", descending: true)
          .limit(100)
          .get();
      getDataRequests = getRequests.docs;
    }
    for (var i = 0; i < getRequests.docs.length; i = i + 1) {
      var data = {
        'balanceRequest_amount': getRequests.docs[i]['balanceRequest_amount'],
        'balanceRequest_amountType': getRequests.docs[i]['balanceRequest_amountType'],
        'balanceRequest_amountTypeEdit': getRequests.docs[i]['balanceRequest_amountTypeEdit'],
        'balanceRequest_date': getRequests.docs[i]['balanceRequest_date'],
        'balanceRequest_status': getRequests.docs[i]['balanceRequest_status'],
        'balanceRequest_storeRequestId': getRequests.docs[i]['balanceRequest_storeRequestId'],
        'balanceRequest_to': getRequests.docs[i]['balanceRequest_to'],
        'docid': getRequests.docs[i].id,
        'storeId': getRequests.docs[i]['balanceRequest_storeRequestId']
      };


      if (getRequests.docs[i]['balanceRequest_status'] == "pending") {
        data["balanceRequest_status"] = "بانتظار الموافقة";
      }else if (getRequests.docs[i]['balanceRequest_status'] == "accepted") {
        data["balanceRequest_status"] = "تمت الموافقة";
      } else if (getRequests.docs[i]['balanceRequest_status'] == "acceptedAdmin") {
        data["balanceRequest_status"] = "تمت موافقة من قبل الأدمن";
      } else if (getRequests.docs[i]['balanceRequest_status'] == "acceptedStore") {
        data["balanceRequest_status"] = "تمت موافقة من قبل المندوب";
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejected") {
        data["balanceRequest_status"] = "تم الرفض";
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejectedAdmin") {
        data["balanceRequest_status"] = "تم الرفض من قبل الأدمن";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejectedStore") {
        data["balanceRequest_status"] = "تم الرفض من قبل المندوب";
        data["balanceRequest_status_check"] = false;
      }

      getBalanceRequestsArray.add(data);
    }

    return getBalanceRequestsArray;
  }

  // Get My Balance
  getMyBalance () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeRole = await userInfo.getStoreRole();
    var storeId = await userInfo.getStoreId();

    var getMyBalance = {
      "store_debtBalance": "0",
      "store_cashBalance": "0",
      "store_indebtedness": "0",
      "store_totalBalance": "0",
      "stores_indebtedness": "0",
    };
    var balance = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    if (balance.exists) {
      getMyBalance["store_debtBalance"] = double.parse(balance.get("store_debtBalance").toString()).toStringAsFixed(2).toString();
      getMyBalance["store_cashBalance"] = double.parse(balance.get("store_cashBalance").toString()).toStringAsFixed(2).toString();
      getMyBalance["store_indebtedness"] = double.parse(balance.get("store_indebtedness").toString()).toStringAsFixed(2).toString();
      getMyBalance["store_totalBalance"] = (double.parse(balance.get("store_cashBalance").toString()) + double.parse(balance.get("store_debtBalance").toString())).toStringAsFixed(2).toString();
      getMyBalance["stores_indebtedness"] = "";
    }

    if (stores_indebtedness == "true" && storeRole == "مندوب") {
      var storesRelation = await FirebaseFirestore.instance
          .collection('storesOfStores')
          .where("storesOfStores_representativesId", isEqualTo: storeId)
          .get();

      List storesId = [];
      storesRelation.docs
          .where((doc) {
        storesId.add(doc.get("storesOfStores_storeId"));
        return true;
      }).toList();
      storesId = storesId.toSet().toList();
     // storesId.add('');


      var stores = await FirebaseFirestore.instance
          .collection('stores')
          //.where("store_id", whereIn: storesId)
          .get();
      print("stores");
      print(stores.docs.length);
      var howManyIndebtedness = 0.0;

      for (var t = 0; t < storesRelation.docs.length; t = t + 1) {
        //if (storesRelation.docs[t]['storesOfStores_representativesId'] == storeId) {
          for (var i = 0; i < stores.docs.length; i = i + 1) {
            if (storesRelation.docs[t]['storesOfStores_storeId'] == stores.docs[i].id) {
              howManyIndebtedness = howManyIndebtedness + double.parse(stores.docs[i]['store_indebtedness']);
              break;
            }
          }
       // }
      }

      getMyBalance["stores_indebtedness"] = howManyIndebtedness.toString();

    }

    return getMyBalance;
  }

}