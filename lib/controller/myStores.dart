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
import 'package:http/http.dart' as http;
import 'balance.dart';
import 'notification.dart';

class storesController {
  String store_id;
  String store_storeType;
  String store_storeGroupName;
  String store_groupValue;
  String store_priceType;
  String store_cashBalance;
  String store_debtBalance;
  String store_status;
  String store_allowToAddStoresStatus;
  String store_userName;
  String store_phoneNumber;
  String store_email;
  String store_companyName;
  String store_fax;
  String store_address;
  String store_name;
  var store_stores;
  String store_addBalance;
  String store_removeDepth;
  String store_removeBalance;
  bool store_updateBalanceRequest;
  String store_balaneRequestUpdateId;
  String store_StoreOfStoresPriceName;
  String store_addDepthBalance;
  bool subStore;
  String store_howMany;
  var store_arrayOfStoresId;

  storesController({
     this.store_id,
     this.store_storeType,
     this.store_storeGroupName,
     this.store_groupValue,
     this.store_priceType,
     this.store_cashBalance,
     this.store_debtBalance,
     this.store_status,
     this.store_allowToAddStoresStatus,
     this.store_userName,
     this.store_phoneNumber,
     this.store_email,
     this.store_companyName,
     this.store_fax,
     this.store_address,
     this.store_stores,
     this.store_name,
     this.store_addBalance,
     this.store_removeDepth,
     this.store_updateBalanceRequest,
     this.store_balaneRequestUpdateId,
     this.store_StoreOfStoresPriceName,
     this.store_removeBalance,
     this.subStore,
     this.store_addDepthBalance,
     this.store_howMany,
     this.store_arrayOfStoresId,
  });

  factory storesController.fromJson(Map<String,dynamic>json){
    return storesController(
      store_id: json['store_id'],
      store_storeType: json['store_storeType'],
      store_storeGroupName: json['store_storeGroupName'],
      store_groupValue: json['store_groupValue'],
      store_priceType: json['store_priceType'],
      store_cashBalance: json['store_cashBalance'],
      store_debtBalance: json['store_debtBalance'],
      store_status: json['store_status'],
      store_allowToAddStoresStatus: json['store_allowToAddStoresStatus'],
      store_userName: json['store_userName'],
      store_phoneNumber: json['store_phoneNumber'],
      store_email: json['store_email'],
      store_companyName: json['store_companyName'],
      store_fax: json['store_fax'],
      store_address: json['store_address'],
      store_stores: json['store_stores'],
      store_name: json['store_name'],
      store_addBalance: json['store_addBalance'],
      store_removeDepth: json['store_removeDepth'],
      store_updateBalanceRequest: json['store_updateBalanceRequest'],
      store_balaneRequestUpdateId: json['store_balaneRequestUpdateId'],
      store_StoreOfStoresPriceName: json['store_StoreOfStoresPriceName'],
      store_removeBalance: json['store_removeBalance'],
      subStore: json['subStore'],
      store_addDepthBalance: json['store_addDepthBalance'],
      store_howMany: json['store_howMany'],
      store_arrayOfStoresId: json['store_arrayOfStoresId'],
    );
  }

  String getRandomString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  var getMyStores = [];
  var getStoresData = [];
  List<DocumentSnapshot> stores;

  getAllData () async {



    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();


    // Get My Stores
    if (getMyStores.length == 0) {
      await FirebaseFirestore.instance
          .collection('storesOfStores')
          .where("storesOfStores_representativesId", isEqualTo: storeId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          getMyStores.add({
            "storesOfStores_storeId": doc["storesOfStores_storeId"],
            "docid": doc.id
          });
        });
      });
    }



    // Get My Stores Data
    await FirebaseFirestore.instance
        .collection('stores')
        .where("store_storeType", isEqualTo: "محل فرعي")
    //.orderBy(descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) async {

        var objectData = {};

        for (var i = 0; i < getMyStores.length; i = i + 1) {
          if (doc.id == getMyStores[i]['storesOfStores_storeId']) {

            objectData['store_name'] = doc["store_name"];
            objectData['store_companyName'] = doc["store_companyName"];
            objectData['store_userName'] = doc["store_userName"];
            objectData['store_phoneNumber'] = doc["store_phoneNumber"];
            objectData['store_email'] = doc["store_email"];
            objectData['store_address'] = doc['store_address'];

            if (doc["store_StoreOfStoresPriceName"] == 'storesOfStoresPricesDifference_groupOne') {
              objectData['store_StoreOfStoresPriceName'] = 'السعر الأول';
            } else if (doc["store_StoreOfStoresPriceName"] == 'storesOfStoresPricesDifference_groupTwo') {
              objectData['store_StoreOfStoresPriceName'] = 'السعر الثاني';
            } else if (doc["store_StoreOfStoresPriceName"] == 'storesOfStoresPricesDifference_groupThree') {
              objectData['store_StoreOfStoresPriceName'] = 'السعر الثالث';
            } else if (doc["store_StoreOfStoresPriceName"] == 'storesOfStoresPricesDifference_groupFour') {
              objectData['store_StoreOfStoresPriceName'] = 'السعر الرابع';
            }


            objectData['store_allBalance'] = (double.parse(doc["store_cashBalance"].toString()) + double.parse(doc["store_debtBalance"].toString())).toStringAsFixed(2).toString();
            objectData['store_debtBalance'] = double.parse(doc['store_debtBalance'].toString()).toStringAsFixed(2).toString();
            objectData['store_cashBalance'] = double.parse(doc['store_cashBalance'].toString()).toStringAsFixed(2).toString();
            objectData['store_earnings'] = double.parse(doc['store_earnings'].toString()).toStringAsFixed(2).toString();
            objectData['store_indebtedness'] = double.parse(doc['store_indebtedness'].toString()).toStringAsFixed(2).toString();

            if (doc["store_status"] == "true") {
              objectData['store_status'] = "فعال";
              objectData['store_statusCheckBox'] = true;
            } else {
              objectData['store_status'] = "غير فعال";
              objectData['store_statusCheckBox'] = false;
            }

            objectData["docid"] = doc.id;
            getStoresData.add(objectData);
            break;
          }
        }




      });
    });

    return getStoresData;
  }

  insertOrEdit ({ String type}) async {

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);

    // Check If Phone Number Exist Before Or Not
    var phoneNumberArrayCheck = [];
    await FirebaseFirestore.instance
        .collection('stores')
        .where("store_phoneNumber", isEqualTo: store_phoneNumber)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        phoneNumberArrayCheck.add(doc.id);
      });
    });

    if (phoneNumberArrayCheck.length != 0) {
      if (store_id != phoneNumberArrayCheck[0]) {
        return {
          'status': 'phoneNumberExistBefore'
        };
      }
    }


    // Check if Email Exist
    var emailArrayCheck = [];
    await FirebaseFirestore.instance
        .collection('stores')
        .where("store_email", isEqualTo: store_email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        emailArrayCheck.add(doc.id);
      });
    });

    if (emailArrayCheck.length != 0) {
      if (store_id != emailArrayCheck[0]) {
        return {
          'status': 'emailExistBefore'
        };
      }
    }

    // Check If Phone Number Exist Before Or Not
    /*var phoneNumberList = await FirebaseFirestore.instance
        .collection('stores')
        .where("store_phoneNumber", isEqualTo: store_phoneNumber)
        .get();

    if (phoneNumberList.docs.length  != 0) {
      return {
        'status': 'phoneNumberExistBefore'
      };
    }

    var emailList = await FirebaseFirestore.instance
        .collection('stores')
        .where("store_email", isEqualTo: store_email)
        .get();

    if (emailList.docs.length != 0) {
      return {
        'status': 'emailExistBefore'
      };
    }*/

    // Check If I can edit or add
    var checkStoreAllowNumberStatus = await FirebaseFirestore.instance
        .collection('stores')
        .where("store_phoneNumber", isEqualTo: store_phoneNumber)
        .where("store_allowToAddStoresStatus", isEqualTo: "false")
        .get();

    if (checkStoreAllowNumberStatus.docs.length != 0) {
      return {
        'status': 'storeCannotAddOrEdit'
      };
    }

    var checkStoreAllowEmailStatus = await FirebaseFirestore.instance
        .collection('stores')
        .where("store_email", isEqualTo: store_email)
        .where("store_allowToAddStoresStatus", isEqualTo: "false")
        .get();

    if (checkStoreAllowEmailStatus.docs.length != 0) {
      return {
        'status': 'storeCannotAddOrEdit'
      };
    }

    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var addOrEdit = await FirebaseFirestore.instance.runTransaction((transaction) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var data = {
        'store_status': store_status,
        'store_name': store_name,
        'store_userName': store_userName,
        'store_phoneNumber': store_phoneNumber,
        'store_email': store_email,
        'store_companyName': store_companyName,
        'store_address': store_address,
       // 'store_debtBalance': "0",
       // 'store_indebtedness': "0",
       // 'store_cashBalance': "0",
        'store_createdData': formattedDate,
        'store_statusCheckBox': true
      };

      data['store_StoreOfStoresPriceName'] = store_StoreOfStoresPriceName;

      var priceTypeName = "";
      if (store_priceType == "كاش") {
        priceTypeName = "StoreOfStoreSendCashBalanceToStore";
      } else if (store_priceType == "آجل") {
        priceTypeName = "StoreOfStoreSendDebtBalanceToStore";
      }


      if (type == "add") {
        data["store_storeType"] = store_storeType;
        data['store_earnings'] = '0';
        data['store_indebtedness'] = '0';
        data["store_debtBalance"] = "0";
        data["store_cashBalance"] = "0";
        data["store_token"] = "";

        /*if (store_priceType == "آجل") {
          data["store_debtBalance"] = store_debtBalance;
          data['store_indebtedness'] = store_debtBalance;
          data["store_cashBalance"] = "0";
        } else {
          data["store_cashBalance"] = store_cashBalance;
          data["store_debtBalance"] = "0";
          data['store_indebtedness'] = '0';
        }*/
      }

      // Insert Edit Data
      CollectionReference stores = FirebaseFirestore.instance.collection('stores');

      if (type == "add") {

        // Add Store
        var randomStoreId = getRandomString(20);
        data["store_id"] = randomStoreId.toString();
        DocumentReference notExist = stores.doc(randomStoreId);
        transaction.set(notExist, data);

        // Add his phonenumber to info table
        CollectionReference storesInfoTable = FirebaseFirestore.instance.collection('storesInfo');
        DocumentReference notExistStoreInfoTable = storesInfoTable.doc(randomStoreId);
        transaction.set(notExistStoreInfoTable, {
          'store_phoneNumber': store_phoneNumber,
          'store_email': store_email,
          'store_status': "true"
        });

        // Add this store to my stores
        CollectionReference storesOfStores = FirebaseFirestore.instance.collection('storesOfStores');
        var randomStoreId2 = getRandomString(20);
        DocumentReference notExistAddToMyStore = storesOfStores.doc(randomStoreId2);
        transaction.set(notExistAddToMyStore, {
          'storesOfStores_representativesId': storeId,
          'storesOfStores_storeId': randomStoreId
        });

        /*var data2 = {
          'balanceHistory_date': formattedDate,
          //'balanceHistory_addPrice': store_addBalance,
          'balanceHistory_beforeCashPrice': '0',
          'balanceHistory_afterCashPrice': '0',
          'balanceHistory_beforeDebtPrice': '0',
          'balanceHistory_afterDebtPrice': '0',
          'balanceHistory_priceType': priceTypeName,
          'balanceHistory_sender': storeId,
          'balanceHistory_receiver': randomStoreId,
          'balanceHistory_BeforeIndebtednessPrice': '0',
          'balanceHistory_AfterIndebtednessPrice': '0',
        };

        if (store_priceType == "آجل") {
          data2["balanceHistory_addPrice"] = store_debtBalance;
          data2["balanceHistory_afterDebtPrice"] = store_debtBalance;
          data2["balanceHistory_AfterIndebtednessPrice"] = store_debtBalance;
        } else {
          data2["balanceHistory_addPrice"] = store_cashBalance;
          data2["balanceHistory_afterCashPrice"] = store_cashBalance;
        }
        // Add Balance History
        CollectionReference balanceHistory = FirebaseFirestore.instance.collection('balanceHistory');
        DocumentReference notExist2 = balanceHistory.doc();
        transaction.set(notExist2, data2);*/


        data['status'] = 'inserted';
        data['docid'] = randomStoreId.toString();
        data['store_allBalance'] = (double.parse(data["store_cashBalance"].toString()) + double.parse(data["store_debtBalance"].toString())).toString();

        if (store_status == "true") {
          data['store_status'] = "فعال";
          data['store_statusCheckBox'] = true;
        } else {
          data['store_status'] = "غير فعال";
          data['store_statusCheckBox'] = false;
        }

        return data;

      } else if (type == "edit") {
        /*await stores
            .doc(store_id.toString())
            .update(data)
            .then((value) => print("Store Updated"))
            .catchError((error) => print("Failed to update card: $error"));*/

        DocumentReference notExist = stores.doc(store_id);
        transaction.update(notExist, data);


        // Update his phonenumber to info table
        CollectionReference storesInfoTable = FirebaseFirestore.instance.collection('storesInfo');
        DocumentReference notExistStoreInfoTable = storesInfoTable.doc(store_id);
        transaction.update(notExistStoreInfoTable, {
          'store_phoneNumber': store_phoneNumber,
          'store_email': store_email,
          'store_status': store_status.toString()
        });

        if (store_status == "true") {
          data['store_status'] = "فعال";
          data['store_statusCheckBox'] = true;
        } else {
          data['store_status'] = "غير فعال";
          data['store_statusCheckBox'] = false;
        }


        data['status'] = "edited";
        data["docid"] = store_id;

        return data;
      }
    });


    return addOrEdit;
  }

  checkIfSubStoreIsForThisStore ({subStoreId, StoreId}) async {
    var checkSubStoreForThisStore = await FirebaseFirestore.instance
        .collection('storesOfStores')
        .where("storesOfStores_representativesId", isEqualTo: StoreId)
        .where("storesOfStores_storeId", isEqualTo: subStoreId)
        .get();

    if (checkSubStoreForThisStore.docs.length == 1) {
      return {
        "status": "exist",
      };
    } else {
      return {
        "status": "notExist",
      };
    }
  }

  checkUpdatedBalanceId ({storeOfStoreId}) async {
    var checkUpdatedBalanceId = await FirebaseFirestore.instance
        .collection('balanceRequest')
        .doc(store_balaneRequestUpdateId)
        .get();

    if (checkUpdatedBalanceId.exists) {
      if (checkUpdatedBalanceId.get("balanceRequest_storeRequestId") == store_id && checkUpdatedBalanceId.get("balanceRequest_to") == storeOfStoreId && checkUpdatedBalanceId.get("balanceRequest_status") == "pending") {
        return {
          "status": "can"
        };
      } else {
        return {
          "status": "wrongBalanceUpdatedId"
        };
      }
    }
  }



  addBalance () async {

    // Get My Balance StoreOfStore To Check If I Have Enough Or Not
    balanceController mybalance = new balanceController();
    var myBalance = await mybalance.getMyBalance();


    // Get My Store Info to Update My Balance
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    // Check If SubStore Is For This Store
    var checkSubStoreForThisStore = await checkIfSubStoreIsForThisStore(subStoreId: store_id, StoreId: storeId);
    if (checkSubStoreForThisStore["status"] == "notExist") {
      return {
        "status": "subStoreNotExistForThisStore"
      };
    }

    // Check Updated Balance Status If It is can be accepted Or Not
    if (store_updateBalanceRequest == true) {
      var checkBalanceStatus = await checkUpdatedBalanceId(storeOfStoreId: storeId);
      if (checkBalanceStatus["status"] == "wrongBalanceUpdatedId") {
        return {
          "status": "wrongBalanceUpdatedId"
        };
      }
    }


    var balance = await FirebaseFirestore.instance.runTransaction((transaction) async {


      // Get Store Info
      DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(store_id.toString());
      DocumentSnapshot storeInfo;
      storeInfo = await transaction.get(getStore);

      DocumentReference getStoreOfStore = FirebaseFirestore.instance.collection("stores").doc(storeId.toString());
      DocumentSnapshot storeOfStoreInfo;
      storeOfStoreInfo = await transaction.get(getStoreOfStore);


      var priceTypeName = "", priceTypeNameMySelft = "";
      if (store_priceType == "كاش") {
        priceTypeName = "StoreOfStoreSendCashBalanceToStore";
        priceTypeNameMySelft = "StoreOfStoreSendCashBalanceToHimSelf";
      } else if (store_priceType == "آجل") {
        priceTypeName = "StoreOfStoreSendDebtBalanceToStore";
        priceTypeNameMySelft = "StoreOfStoreSendDebtBalanceToHimSelf";
      }

      var returnResult = {};

      if (store_addBalance != "") {

        var myMainCashPrice = myBalance['store_cashBalance'];
        var myMainDepthPrice =  myBalance['store_debtBalance'];
        // Update My Balance
        if (double.parse(store_addBalance) < 0) {
          return {"status": "balanceLessThenZero"};
        } else if (double.parse(myBalance['store_totalBalance']) ==
            double.parse(store_addBalance)) {
          DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(storeId);
          transaction.update(getStore, {
            "store_cashBalance": "0",
            "store_debtBalance": "0",
          });

          myBalance['store_cashBalance'] = "0";
          myBalance['store_debtBalance'] = "0";

        } else if (double.parse(myBalance['store_totalBalance']) >
            double.parse(store_addBalance)) {
          if (double.parse(myBalance['store_cashBalance']) >=
              double.parse(store_addBalance)) {
            var price = double.parse(myBalance['store_cashBalance']) -
                double.parse(store_addBalance);
            DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(storeId);
            transaction.update(getStore, {
              "store_cashBalance": price.toString(),
            });
            myBalance['store_cashBalance'] = price.toString();

          } else if (double.parse(myBalance['store_cashBalance']) <
              double.parse(store_addBalance)) {
            var price = double.parse(store_addBalance) -
                double.parse(myBalance['store_cashBalance']);
            var depthBalance = double.parse(myBalance['store_debtBalance']) -
                price;

            DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(storeId);
            transaction.update(getStore, {
              "store_cashBalance": "0",
              "store_debtBalance": depthBalance.toString()
            });
            myBalance['store_cashBalance'] = "0";
            myBalance['store_debtBalance'] = depthBalance.toString();
          }
        } else {
          return {"status": "noAvailableBalance"};
        }

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);

        // Update My History
        var myHistoryData = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_addBalance,
          'balanceHistory_beforeCashPrice': myMainCashPrice,
          'balanceHistory_afterCashPrice': myBalance['store_cashBalance'],
          'balanceHistory_beforeDebtPrice': myMainDepthPrice,
          'balanceHistory_afterDebtPrice': myBalance['store_debtBalance'],
          'balanceHistory_priceType': priceTypeNameMySelft,
          'balanceHistory_sender': storeId,
          'balanceHistory_receiver': storeId,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': myBalance["store_indebtedness"],
          'balanceHistory_AfterIndebtednessPrice': myBalance["store_indebtedness"],
        };
        var myHistoryRandomId = getRandomString(20);
        CollectionReference myBalanceHistory = FirebaseFirestore.instance
            .collection('balanceHistory');
        DocumentReference notExistMyHistory = myBalanceHistory.doc(myHistoryRandomId);
        transaction.set(notExistMyHistory, myHistoryData);


        var store_debtBalance = double.parse(
            storeInfo.get('store_debtBalance'));
        var store_balancePrice = double.parse(storeInfo.get('store_cashBalance'));
        var store_indebtednessPrice = double.parse(
            storeInfo.get('store_indebtedness'));

        // Update Store Balance History
        var data = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_addBalance,
          'balanceHistory_beforeCashPrice': store_balancePrice,
          'balanceHistory_afterCashPrice': store_balancePrice,
          'balanceHistory_beforeDebtPrice': store_debtBalance,
          'balanceHistory_afterDebtPrice': store_debtBalance,
          'balanceHistory_priceType': priceTypeName,
          'balanceHistory_sender': storeId,
          'balanceHistory_receiver': store_id,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': store_indebtednessPrice
              .toString(),
          'balanceHistory_AfterIndebtednessPrice': store_indebtednessPrice
              .toString(),
        };

        if (store_priceType == 'آجل') {
          if (store_indebtednessPrice < 0) {
            //data['balanceHistory_AfterIndebtednessPrice'] = store_indebtednessPrice - double.parse(store_addBalance);
          } else {

          }
          data['balanceHistory_AfterIndebtednessPrice'] =
              store_indebtednessPrice + double.parse(store_addBalance);

          data['balanceHistory_afterDebtPrice'] =
              store_debtBalance + double.parse(store_addBalance);
        } else if (store_priceType == 'كاش') {
          data['balanceHistory_afterCashPrice'] =
              store_balancePrice + double.parse(store_addBalance);
        }
        var randomStoreId = getRandomString(20);
        CollectionReference balanceHistory = FirebaseFirestore.instance
            .collection('balanceHistory');
        DocumentReference notExist = balanceHistory.doc(randomStoreId);
        transaction.set(notExist, data);


        // Update Store Balance
        if (store_priceType == "آجل") {
          var update_store_deptPrice = store_debtBalance +
              double.parse(store_addBalance);
          var update_store_indebtedness = store_indebtednessPrice +
              double.parse(store_addBalance);

          DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(store_id.toString());
          transaction.update(getStore, {
            'store_debtBalance': update_store_deptPrice.toString(),
            'store_indebtedness': update_store_indebtedness.toString(),
          });
          returnResult['store_debtBalance'] = update_store_deptPrice.toString();
          returnResult['store_indebtedness'] =
              update_store_indebtedness.toString();
        } else if (store_priceType == "كاش") {
          var update_store_balancePrice = store_balancePrice +
              double.parse(store_addBalance);

          DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(store_id.toString());
          transaction.update(getStore, {
            'store_cashBalance': update_store_balancePrice.toString()
          });
          returnResult['store_cashBalance'] =
              update_store_balancePrice.toString();
        }

        returnResult['status'] = 'updated';






        // In Case Request Balance
        if (store_updateBalanceRequest == true) {
          DocumentReference balanceRequest = FirebaseFirestore.instance.collection("balanceRequest").doc(store_balaneRequestUpdateId.toString());
          transaction.update(balanceRequest, {
            'balanceRequest_status': "acceptedStore",
            'balanceRequest_amountTypeEdit': store_priceType
          });
          returnResult['status'] = 'accepted';

          // Send Notification For New Balance Received
          var priceType = "";

          if (store_priceType == "كاش") {
            priceType = "StoreOfStoreAcceptCashBalanace";
          } else if (store_priceType == "آجل") {
            priceType = "StoreOfStoreAcceptDeptBalanace";
          }

          DateTime notiDate = DateTime.now();
          String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);

          var newNotiString = getRandomString(20);
          CollectionReference notification = FirebaseFirestore.instance
              .collection('notifications');
          DocumentReference notExistMyNotification = notification.doc(newNotiString);
          transaction.set(notExistMyNotification, {
            "notification_sender": storeId,
            "notification_receiver": store_id,
            "notification_type": priceType,
            "notification_amount": store_addBalance,
            "notification_new": "yes",
            "notification_date": notiFormDate,
          });
          
          notificationClass notificationRequest = new notificationClass();
          notificationRequest.sendNotification(
              token: storeInfo.get("store_token"),
              notification_type: priceType,
              notification_amount: store_addBalance,
              notification_senderName: storeOfStoreInfo.get("store_name"),
              notification_date: notiFormDate,
              notification_sender: storeId,
              notification_receiver: store_id,
          );

        } else {
          // Send Notification For Store
          DateTime notiDate = DateTime.now();
          String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);
          var newNotiString = getRandomString(20);
          CollectionReference notification = FirebaseFirestore.instance
              .collection('notifications');
          DocumentReference notExistMyNotification = notification.doc(newNotiString);
          transaction.set(notExistMyNotification, {
            "notification_sender": storeId,
            "notification_receiver": store_id,
            "notification_type": priceTypeName,
            "notification_amount": store_addBalance,
            "notification_new": "yes",
            "notification_date": notiFormDate,
          });

          // Send Notification
          DocumentReference getStoreOfStore = FirebaseFirestore.instance.collection("stores").doc(storeId);

          notificationClass notificationRequest = new notificationClass();
          notificationRequest.sendNotification(
              token: storeInfo.get("store_token"),
              notification_type: priceTypeName,
              notification_amount: store_addBalance,
              notification_senderName: storeOfStoreInfo.get("store_name"),
              notification_date: notiFormDate,
              notification_sender: storeId,
              notification_receiver: store_id,
              docid: newNotiString,
          );
        }





      }





      // Remove Depth
      // Add Remove Depth
      if (store_addDepthBalance.toString() != "") {
        // Add Balance History
        CollectionReference balanceHistory = FirebaseFirestore.instance.collection('balanceHistory');


        // Get Store Info
        //  DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(store_id.toString());
        //storeInfo = await transaction.get(getStore);


        var store_debtBalance = double.parse(storeInfo.get('store_debtBalance'));
        var store_cashBalance = double.parse(storeInfo.get('store_cashBalance'));
        var store_indebtednessPrice = double.parse(storeInfo.get('store_indebtedness'));

        if (store_addBalance != "" && store_priceType == "آجل") {
          store_indebtednessPrice = store_indebtednessPrice + double.parse(store_addBalance);
          store_debtBalance = store_debtBalance + double.parse(store_addBalance);
        } else if (store_addBalance != "" && store_priceType == "كاش") {
          store_cashBalance = store_cashBalance + double.parse(store_addBalance);
        }



        var balanceHistory_AfterIndebtednessPrice = store_indebtednessPrice - double.parse(store_addDepthBalance);

        DateTime now2 = DateTime.now();
        String formattedDate2 = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now2);


        var data = {
          'balanceHistory_date': formattedDate2,
          'balanceHistory_addPrice': store_addDepthBalance.toString(),
          'balanceHistory_beforeCashPrice': store_cashBalance.toString(),
          'balanceHistory_afterCashPrice': store_cashBalance.toString(),
          'balanceHistory_beforeDebtPrice': store_debtBalance.toString(),
          'balanceHistory_afterDebtPrice': store_debtBalance.toString(),
          'balanceHistory_priceType': "StoreOfStoreSendIndebtednessToStore",
          'balanceHistory_sender': storeId,
          'balanceHistory_receiver': store_id,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': store_indebtednessPrice.toString(),
          'balanceHistory_AfterIndebtednessPrice': balanceHistory_AfterIndebtednessPrice.toString(),
        };

        balanceHistory = FirebaseFirestore.instance.collection('balanceHistory');
        DocumentReference notExist = balanceHistory.doc();
        transaction.set(notExist, data);

        transaction.update(getStore, {
          'store_indebtedness': balanceHistory_AfterIndebtednessPrice.toString(),
        });

        returnResult['status'] = 'updated';
        returnResult['store_indebtedness'] = balanceHistory_AfterIndebtednessPrice.toString();

        // Send Notification For Store
        DateTime notiDate = DateTime.now();
        String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);

        var newNotiString = getRandomString(20);
        CollectionReference notification = FirebaseFirestore.instance
            .collection('notifications');
        DocumentReference notExistMyNotification = notification.doc(newNotiString);
        transaction.set(notExistMyNotification, {
          "notification_sender": storeId,
          "notification_receiver": store_id,
          "notification_type": "StoreOfStoreSendIndebtednessToStore",
          "notification_amount": store_addDepthBalance,
          "notification_new": "yes",
          "notification_date": notiFormDate,
        });

        notificationClass notificationRequest = new notificationClass();
        notificationRequest.sendNotification(
            token: storeInfo.get("store_token"),
            notification_senderName: storeOfStoreInfo.get("store_name"),
            notification_type: "StoreOfStoreSendIndebtednessToStore",
            notification_amount: store_addDepthBalance,
            notification_date: notiFormDate,
            notification_sender: storeId,
            notification_receiver: store_id,
            docid: newNotiString,
        );
      }

      return returnResult;
    });

    return balance;
  }

  rejectBalance () async {
    // Get My Store Info to Update My Balance
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    // Check If SubStore Is For This Store
    var checkSubStoreForThisStore = await checkIfSubStoreIsForThisStore(subStoreId: store_id, StoreId: storeId);
    if (checkSubStoreForThisStore["status"] == "notExist") {
      return {
        "status": "subStoreNotExistForThisStore"
      };
    }

    // Check Updated Balance Status If It is can be accepted Or Not
    if (store_updateBalanceRequest == true) {
      var checkBalanceStatus = await checkUpdatedBalanceId(storeOfStoreId: storeId);
      if (checkBalanceStatus["status"] == "wrongBalanceUpdatedId") {
        return {
          "status": "wrongBalanceUpdatedId"
        };
      }
    }
    
    var getBalanceRequest = await FirebaseFirestore.instance
        .collection('balanceRequest')
        .doc(store_balaneRequestUpdateId);
    
    var getBalanceRequestData = await getBalanceRequest.get();
    
    await getBalanceRequest
        .update({
      "balanceRequest_status": "rejectedStore"
    });

    DateTime notiDate = DateTime.now();
    String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);
    
    var notificationType = "";
    if (getBalanceRequestData.get("balanceRequest_amountType") == "كاش") {
      notificationType = "StoreOfStoreRejectCashBalanceToStore";
    } else if (getBalanceRequestData.get("balanceRequest_amountType") == "آجل") {
      notificationType = "StoreOfStoreRejectDebtBalanceToStore";
    }
    
    await FirebaseFirestore.instance
        .collection('notifications').add({
          "notification_sender": storeId,
          "notification_receiver": store_id,
          "notification_type": notificationType,
          "notification_amount": store_addDepthBalance,
          "notification_new": "yes",
          "notification_date": notiFormDate,
        });


    var storeInfo = await FirebaseFirestore.instance
        .collection('stores')
        .doc(store_id)
        .get();

    var storeOfStoreInfo = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    notificationClass notificationRequest = new notificationClass();
    notificationRequest.sendNotification(
        token: storeInfo.get("store_token"),
        notification_type: notificationType,
        notification_amount: store_addBalance,
        notification_senderName: storeOfStoreInfo.get("store_name"),
        notification_date: notiFormDate,
        notification_sender: storeId,
        notification_receiver: store_id,
        //docid: newNotiString,
    );

    return {
      "status": "rejected",
    };
  }


  // Retrieve balance (get them back)
  retrieveBalance () async {

    if (double.parse(store_removeBalance) <= 0) {
      return {
        "status": "lessThanZero",
        "alert": "أدخل رصيد أصغر أو أكبر من صفر"
      };
    }

    var balance = await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get My Balance
      balanceController balance = new balanceController();
      var myBalance = await balance.getMyBalance();

      // Get My Info
      userinfoDatabase userInfo = new userinfoDatabase();
      var myStoreId = await userInfo.getStoreId();

      DocumentReference getMyStore = FirebaseFirestore.instance.collection("stores").doc(myStoreId.toString());
      var getMyStoreInfo = await transaction.get(getMyStore);
      var myStore_debtBalance = double.parse(myBalance['store_debtBalance']);
      var myStore_cashBalance = double.parse(myBalance['store_cashBalance']);
      var myStoretotalBalance = myStore_debtBalance + myStore_cashBalance;



      // Get Store Info
      DocumentReference getStore = FirebaseFirestore.instance.collection("stores").doc(store_id.toString());
      var storeInfo = await transaction.get(getStore);

      var store_debtBalance = double.parse(storeInfo.get('store_debtBalance'));
      var store_cashBalance = double.parse(storeInfo.get('store_cashBalance'));
      var totalBalance = store_debtBalance + store_cashBalance;

      var priceTypeName = "", priceTypeNameMySelft = "";
      if (store_priceType == "كاش") {
        priceTypeName = "StoreOfStoreRetrieveCashBalanceToStore";
        priceTypeNameMySelft = "StoreOfStoreRetrieveCashBalanceToHimSelf";
      } else if (store_priceType == "آجل") {
        priceTypeName = "StoreOfStoreRetrieveDebtBalanceToStore";
        priceTypeNameMySelft = "StoreOfStoreRetrieveDebtBalanceToHimSelf";
      }

      CollectionReference balanceHistory = FirebaseFirestore.instance.collection('balanceHistory');

      if (store_cashBalance >= double.parse(store_removeBalance) && store_priceType == "كاش") {

        var price = store_cashBalance - double.parse(store_removeBalance);

        transaction.update(getStore, {
          "store_cashBalance": price.toString(),
        });

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);

        // Update Store Balance
        var data = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_removeBalance.toString(),
          'balanceHistory_beforeCashPrice': storeInfo.get('store_cashBalance'),
          'balanceHistory_afterCashPrice': price.toString(),
          'balanceHistory_beforeDebtPrice': storeInfo.get('store_debtBalance'),
          'balanceHistory_afterDebtPrice': storeInfo.get('store_debtBalance'),
          'balanceHistory_priceType': priceTypeName,
          'balanceHistory_sender': myStoreId,
          'balanceHistory_receiver': store_id,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': storeInfo.get('store_indebtedness'),
          'balanceHistory_AfterIndebtednessPrice': storeInfo.get('store_indebtedness'),
        };

        // Add Balance History
        var storeRandomId = getRandomString(20);
        DocumentReference notExistStore = balanceHistory.doc(storeRandomId);
        transaction.set(notExistStore, data);


        // My Balance Update Store Of Store
        var myPrice = myStore_cashBalance + double.parse(store_removeBalance);
        transaction.update(getMyStore, {
          "store_cashBalance": myPrice.toString(),
        });

        // Update Store Balance
        var data2 = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_removeBalance.toString(),
          'balanceHistory_beforeCashPrice': myBalance['store_cashBalance'],
          'balanceHistory_afterCashPrice': myPrice.toString(),
          'balanceHistory_beforeDebtPrice': myBalance['store_debtBalance'],
          'balanceHistory_afterDebtPrice': myBalance['store_debtBalance'],
          'balanceHistory_priceType': priceTypeNameMySelft,
          'balanceHistory_sender': myStoreId,
          'balanceHistory_receiver': myStoreId,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': myBalance['store_indebtedness'],
          'balanceHistory_AfterIndebtednessPrice': myBalance['store_indebtedness'],
        };

        // Add Balance History
        var MyStoreHistoryRandomId = getRandomString(20);
        DocumentReference notExistMyStoreHistory = balanceHistory.doc(MyStoreHistoryRandomId);
        transaction.set(notExistMyStoreHistory, data2);

        // Send Notification For Store
        DateTime notiDate = DateTime.now();
        String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);

        var newNotiString = getRandomString(20);
        CollectionReference notification = FirebaseFirestore.instance
            .collection('notifications');
        DocumentReference notExistMyNotification = notification.doc(newNotiString);
        transaction.set(notExistMyNotification, {
          "notification_sender": myStoreId,
          "notification_receiver": store_id,
          "notification_type": "StoreOfStoreRetrieveCashBalanceToStore",
          "notification_amount": store_removeBalance,
          "notification_new": "yes",
          "notification_date": notiFormDate,
        });

        notificationClass notificationRequest = new notificationClass();
        notificationRequest.sendNotification(
          token: storeInfo.get("store_token"),
          notification_senderName: getMyStoreInfo.get("store_name"),
          notification_type: "StoreOfStoreRetrieveCashBalanceToStore",
          notification_amount: store_removeBalance,
          notification_date: notiFormDate,
          notification_sender: myStoreId,
          notification_receiver: store_id,
        );

        return {
          "status": "updated",
          "store_cashBalance": double.parse(price.toString()).toStringAsFixed(2).toString(),
        };


      } else if (store_cashBalance < double.parse(store_removeBalance) && store_priceType == "كاش") {

        return {
          "status": "bigBalance",
          "alert": "المبلغ الذي أدخلته أكبر من رصيد العميل"
        };

      } else if (store_debtBalance >= double.parse(store_removeBalance) && store_priceType == "آجل") {
        var price = store_debtBalance - double.parse(store_removeBalance);

        transaction.update(getStore, {
          "store_debtBalance": price.toString(),
        });

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(now);

        // Update Store Balance
        var data = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_removeBalance.toString(),
          'balanceHistory_beforeCashPrice': storeInfo.get('store_cashBalance'),
          'balanceHistory_afterCashPrice': storeInfo.get('store_cashBalance'),
          'balanceHistory_beforeDebtPrice': storeInfo.get('store_debtBalance'),
          'balanceHistory_afterDebtPrice': price.toString(),
          'balanceHistory_priceType': priceTypeName,
          'balanceHistory_sender': myStoreId,
          'balanceHistory_receiver': store_id,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': storeInfo.get('store_indebtedness'),
          'balanceHistory_AfterIndebtednessPrice': storeInfo.get('store_indebtedness'),
        };

        // Add Balance History
        var storeRandomId = getRandomString(20);
        DocumentReference notExistStore = balanceHistory.doc(storeRandomId);
        transaction.set(notExistStore, data);


        // My Balance Update Store Of Store
        var myPrice = myStore_debtBalance + double.parse(store_removeBalance);
        transaction.update(getMyStore, {
          "store_debtBalance": myPrice.toString(),
        });

        // Update Store Balance
        var data2 = {
          'balanceHistory_date': formattedDate,
          'balanceHistory_addPrice': store_removeBalance.toString(),
          'balanceHistory_beforeCashPrice':  myBalance['store_cashBalance'],
          'balanceHistory_afterCashPrice':  myBalance['store_cashBalance'],
          'balanceHistory_beforeDebtPrice':  myBalance['store_debtBalance'],
          'balanceHistory_afterDebtPrice': myPrice.toString(),
          'balanceHistory_priceType': priceTypeNameMySelft,
          'balanceHistory_sender': myStoreId,
          'balanceHistory_receiver': myStoreId,
          'balanceHistory_storeReceiver': store_id,
          'balanceHistory_BeforeIndebtednessPrice': myBalance['store_indebtedness'],
          'balanceHistory_AfterIndebtednessPrice': myBalance['store_indebtedness'],
        };

        // Add Balance History
        var MyStoreHistoryRandomId = getRandomString(20);
        DocumentReference notExistMyStoreHistory = balanceHistory.doc(MyStoreHistoryRandomId);
        transaction.set(notExistMyStoreHistory, data2);

        // Send Notification For Store
        DateTime notiDate = DateTime.now();
        String notiFormDate = DateFormat('yyyy-MM-dd – h:mm:ss a').format(notiDate);

        var newNotiString = getRandomString(20);
        CollectionReference notification = FirebaseFirestore.instance
            .collection('notifications');
        DocumentReference notExistMyNotification = notification.doc(newNotiString);
        transaction.set(notExistMyNotification, {
          "notification_sender": myStoreId,
          "notification_receiver": store_id,
          "notification_type": "StoreOfStoreRetrieveDebtBalanceToStore",
          "notification_amount": store_removeBalance,
          "notification_new": "yes",
          "notification_date": notiFormDate,
        });

        notificationClass notificationRequest = new notificationClass();
        notificationRequest.sendNotification(
          token: storeInfo.get("store_token"),
          notification_senderName: getMyStoreInfo.get("store_name"),
          notification_type: "StoreOfStoreRetrieveDebtBalanceToStore",
          notification_amount: store_removeBalance,
          notification_date: notiFormDate,
          notification_sender: myStoreId,
          notification_receiver: store_id,
        );


        return {
          "status": "updated",
          "store_debtBalance": double.parse(price.toString()).toStringAsFixed(2).toString(),
        };

      } else if (store_debtBalance < double.parse(store_removeBalance) && store_priceType == "آجل") {
        return {
          "status": "bigBalance",
          "alert": "المبلغ الذي أدخلته أكبر من رصيد العميل"
        };
      }
    });

    return balance;
  }

  removeDepth () async {

    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    // Add Balance History
    CollectionReference balanceHistory = FirebaseFirestore.instance.collection('balanceHistory');

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    // Get Store Info
    CollectionReference getStore = FirebaseFirestore.instance.collection('stores');
    var storeInfo = await getStore
        .doc(store_id.toString())
        .get();

    var store_debtBalance = double.parse(storeInfo.get('store_debtBalance'));
    var store_balancePrice = double.parse(storeInfo.get('store_cashBalance'));
    var store_indebtednessPrice = double.parse(storeInfo.get('store_indebtedness'));

    var balanceHistory_AfterIndebtednessPrice = store_indebtednessPrice - double.parse(store_addBalance);

    var data = {
      'balanceHistory_date': formattedDate,
      'balanceHistory_addPrice': store_addBalance.toString(),
      'balanceHistory_beforeCashPrice': storeInfo.get('store_cashBalance'),
      'balanceHistory_afterCashPrice': storeInfo.get('store_cashBalance'),
      'balanceHistory_beforeDebtPrice': storeInfo.get('store_debtBalance'),
      'balanceHistory_afterDebtPrice': storeInfo.get('store_debtBalance'),
      'balanceHistory_priceType': 'StoreOfStoreSendIndebtednessToStore',
      'balanceHistory_sender': storeId,
      'balanceHistory_receiver': store_id,
      'balanceHistory_BeforeIndebtednessPrice': store_indebtednessPrice.toString(),
      'balanceHistory_AfterIndebtednessPrice': balanceHistory_AfterIndebtednessPrice.toString(),
    };

    DocumentReference docRef = await balanceHistory
        .add(data);

    var update_storeInfo = await getStore
        .doc(store_id.toString())
        .update({
      'store_indebtedness': balanceHistory_AfterIndebtednessPrice.toString(),
    })
        .then((value) => print("Store Updated"))
        .catchError((error) => print("Failed to update store: $error"));

    data['status'] = 'updated';
    data['store_indebtedness'] = double.parse(balanceHistory_AfterIndebtednessPrice.toString()).toStringAsFixed(2).toString();
    return data;
  }


  // Get Balance History
  getBalanceHistory () async {
    var getHistoryData = [];
    await FirebaseFirestore.instance
        .collection('balanceHistory')
        .where("balanceHistory_receiver", isEqualTo: store_id)
        .orderBy("balanceHistory_date", descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {

        var data = {
          'balanceHistory_date': doc['balanceHistory_date'],
          'balanceHistory_addPrice': double.parse(doc['balanceHistory_addPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_beforeCashPrice': double.parse(doc['balanceHistory_beforeCashPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_afterCashPrice': double.parse(doc['balanceHistory_afterCashPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_beforeDebtPrice': double.parse(doc['balanceHistory_beforeDebtPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_afterDebtPrice': double.parse(doc['balanceHistory_afterDebtPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_priceType': doc['balanceHistory_priceType'],
          'balanceHistory_sender': doc['balanceHistory_sender'],
          'balanceHistory_receiver': doc['balanceHistory_receiver'],
          'balanceHistory_BeforeIndebtednessPrice': double.parse(doc['balanceHistory_BeforeIndebtednessPrice'].toString()).toStringAsFixed(2).toString(),
          'balanceHistory_AfterIndebtednessPrice': double.parse(doc['balanceHistory_AfterIndebtednessPrice'].toString()).toStringAsFixed(2).toString(),
        };

        if (doc['balanceHistory_priceType'] == "StoreOfStoreRetrieveCashBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد كاش";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreRetrieveDebtBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد آجل";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreSendCashBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreSendDebtBalanceToHimSelf") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreSendIndebtednessToStore") {
          data['balanceHistory_priceType'] = "إرسال مديونية";
        } else if (doc['balanceHistory_priceType'] == "AdminSendIndebtednessToStore") {
          data['balanceHistory_priceType'] = "إرسال مديونية من الأدمن";
        } else if (doc['balanceHistory_priceType'] == "AdminSendCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش من الأدمن";
        } else if (doc['balanceHistory_priceType'] == "AdminSendDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل من الأدمن";
        } else if (doc['balanceHistory_priceType'] == "AdminRetrieveCashBalanceToStore") {
          data['balanceHistory_priceType'] = "سحب رصيد كاش من الأدمن";
        } else if (doc['balanceHistory_priceType'] == "AdminRetrieveDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "سحب رصيد آجل من الأدمن";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreSendCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد كاش";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreSendDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إرسال رصيد آجل";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreRetrieveCashBalanceToStore") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد كاش";
        } else if (doc['balanceHistory_priceType'] == "StoreOfStoreRetrieveDebtBalanceToStore") {
          data['balanceHistory_priceType'] = "إسترجاع رصيد آجل";
        }


        getHistoryData.add(data);
      });
    });

    return getHistoryData;
  }

  var getStoresBalanceRequests = [];
  var getBalanceRequestsArray = [];
  List<DocumentSnapshot> getDataHistoryArray;

  // Get Balance Requests
  getBalanceRequests () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    var getRequests;
    if (getBalanceRequestsArray.length != 0) {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceRequest')
          .where("balanceRequest_to", isEqualTo: storeId)
          .orderBy("balanceRequest_date", descending: true)
          .startAfterDocument(getDataHistoryArray[getDataHistoryArray.length - 1])
          .limit(100)
          .get();

      getDataHistoryArray = getDataHistoryArray + getRequests.docs;

    } else {
      getRequests = await FirebaseFirestore.instance
          .collection('balanceRequest')
          .where("balanceRequest_to", isEqualTo: storeId)
          .orderBy("balanceRequest_date", descending: true)
          .limit(100)
          .get();
      getDataHistoryArray = getRequests.docs;
    }
    for (var i = 0; i < getRequests.docs.length; i = i + 1) {
      var data = {
        'balanceRequest_amount': double.parse(getRequests.docs[i]['balanceRequest_amount']).toStringAsFixed(2).toString(),
        'balanceRequest_amountType': getRequests.docs[i]['balanceRequest_amountType'],
        'balanceRequest_date': getRequests.docs[i]['balanceRequest_date'],
        'balanceRequest_status': getRequests.docs[i]['balanceRequest_status'],
        'balanceRequest_storeRequestId': getRequests.docs[i]['balanceRequest_storeRequestId'],
        'balanceRequest_to': getRequests.docs[i]['balanceRequest_to'],
        'docid': getRequests.docs[i].id,
        'storeId': getRequests.docs[i]['balanceRequest_storeRequestId']
      };

      if (getRequests.docs[i]['balanceRequest_status'] == "pending") {
        data["balanceRequest_status"] = "بانتظار الموافقة";
        data["balanceRequest_status_check"] = true;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "accepted") {
        data["balanceRequest_status"] = "تمت الموافقة";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "acceptedAdmin") {
        data["balanceRequest_status"] = "تمت موافقة من قبل الأدمن";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "acceptedStore") {
        data["balanceRequest_status"] = "تمت موافقة من قبل المندوب";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejected") {
        data["balanceRequest_status"] = "تم الرفض";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejectedAdmin") {
        data["balanceRequest_status"] = "تم الرفض من قبل الأدمن";
        data["balanceRequest_status_check"] = false;
      } else if (getRequests.docs[i]['balanceRequest_status'] == "rejectedStore") {
        data["balanceRequest_status"] = "تم الرفض من قبل المندوب";
        data["balanceRequest_status_check"] = false;
      }

      getBalanceRequestsArray.add(data);
    }


    await FirebaseFirestore.instance
        .collection('balanceRequest')
        .where("balanceRequest_to", isEqualTo: storeId)
        .orderBy("balanceRequest_date", descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {



      });
    });

    var array = [];
    var arrayOfNames = [];

    List storesId = [];
    getBalanceRequestsArray
        .where((doc) {
      storesId.add(doc["storeId"]);
      return true;
    }).toList();
    storesId = storesId.toSet().toList();
    storesId.add('');

    if (getStoresBalanceRequests.length == 0) {
      await FirebaseFirestore.instance
          .collection('stores')
      // .where("store_id", whereIn: storesId)
      //.orderBy(descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          getStoresBalanceRequests.add({
            "docid": doc.id,
            "store_name": doc.get("store_name")
          });
        });
      });
    }


    //

    for (var i = 0; i < getBalanceRequestsArray.length; i = i + 1) {
      for (var t = 0; t < getStoresBalanceRequests.length; t = t + 1) {
        if (getBalanceRequestsArray[i]['storeId'] == getStoresBalanceRequests[t]['docid']) {
          getBalanceRequestsArray[i]['balanceRequest_store_name'] = getStoresBalanceRequests[t]['store_name'];
          break;
        } else {
          getBalanceRequestsArray[i]['balanceRequest_store_name'] = "";
        }
      }



      var check = array
          .contains(getBalanceRequestsArray[i]['storeId']);



      /*if (check == false) {
        var getStoreName = await FirebaseFirestore.instance
            .collection('stores')
            .doc(getBalanceRequests[i]['storeId'])
        //.orderBy(descending: true)
            .get();

        array.add(getBalanceRequests[i]['storeId']);



        if (getStoreName.exists) {
          getBalanceRequests[i]['balanceRequest_store_name'] = getStoreName.get("store_name");
          arrayOfNames.add(getBalanceRequests[i]['store_name']);
        } else {
          getBalanceRequests[i]['balanceRequest_store_name'] = "";
          arrayOfNames.add(getBalanceRequests[i]['balanceRequest_store_name']);
        }
      } else {

        getBalanceRequests[i]['balanceRequest_store_name'] = arrayOfNames[array.indexOf(getBalanceRequests[i]['storeId'])];
      }*/

    }
    return getBalanceRequestsArray;
  }

  delete () async {
    CollectionReference delete = FirebaseFirestore.instance.collection('stores');

    await delete
        .doc(store_id.toString())
        .delete()
        .then((value) => print("Store Deleted"))
        .catchError((error) => print("Failed to delete Store: $error"));

    CollectionReference storeInfoTable = FirebaseFirestore.instance.collection('storesInfo');
    await storeInfoTable
        .doc(store_id.toString())
        .delete()
        .then((value) => print("Store Info Deleted"))
        .catchError((error) => print("Failed to delete Store Info: $error"));

    // Delete His Stores
    CollectionReference storesOfStores = FirebaseFirestore.instance.collection('storesOfStores');

    await FirebaseFirestore.instance
        .collection('storesOfStores')
        .where("storesOfStores_representativesId", isEqualTo: store_id.toString())
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        storesOfStores.doc(doc.id).delete();
      });
    });

    // Delete His Balance
    CollectionReference storeBalance = FirebaseFirestore.instance.collection('balanceHistory');

    await FirebaseFirestore.instance
        .collection('balanceHistory')
        .where("balanceHistory_receiver", isEqualTo: store_id.toString())
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        storeBalance.doc(doc.id).delete();
      });
    });

    return "deleted";
  }


  activateOrDeactivateStores () async {



    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    if (store_howMany == "all") {
      var arrayOfId = [];
      var getMyStores = await FirebaseFirestore.instance
          .collection('storesOfStores')
          .where("storesOfStores_representativesId", isEqualTo: storeId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          arrayOfId.add(doc['storesOfStores_storeId']);
        });
      }).catchError((onError) {
        print(onError);
      });


      for (var i = 0; i < arrayOfId.length; i = i + 1) {
        var updateStoreStatus = await FirebaseFirestore.instance
            .collection('stores')
            .doc(arrayOfId[i])
            .update({
          "store_status": store_status
        }).catchError((onError) {
          print(onError);
        });
      }


    } else {
      // Check If I own this store
      var objectOfId = {};
      var getMyStores = await FirebaseFirestore.instance
          .collection('storesOfStores')
          .where("storesOfStores_representativesId", isEqualTo: storeId)
          .where("storesOfStores_storeId", isEqualTo: store_id)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          objectOfId['id'] = doc.id;
        });
      }).catchError((onError) {
        print(onError);
      });

      if (objectOfId['id'] != null) {
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(store_id)
            .update({
          "store_status": store_status
        }).catchError((onError) {
          print(onError);
        });

      }

    }

    return {
      "status": "edited"
    };
  }

}