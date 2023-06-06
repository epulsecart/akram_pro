// @dart=2.11

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/list_extensions.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class notificationClass {
  String id;


  notificationClass({
    this.id,
  });

  factory notificationClass.fromJson(Map<String, dynamic>json){
    return notificationClass(
      id: json['id'],
    );
  }

  getAllData ({id}) async {
    var allNotificationData = [];
    var storeId = "";

    if (id != null) {
      storeId = id;
    } else {
      userinfoDatabase userInfo = new userinfoDatabase();
      storeId = await userInfo.getStoreId();
    }


    var howManyNewNotification = 0;
    // How Many New
    var howMany = await FirebaseFirestore.instance
        .collection('notifications')
        .where("notification_new", isEqualTo: "yes")
        .where("notification_receiver", isEqualTo: storeId)
        .get();

    howManyNewNotification = howMany.docs.length;

    // Get My Stores
    await FirebaseFirestore.instance
        .collection('notifications')
        .orderBy("notification_date", descending: true)
        .where("notification_receiver", isEqualTo: storeId)
        .limit(20)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        var data = {
          "notification_amount": doc["notification_amount"],
          "notification_date": doc["notification_date"],
          "notification_receiver": doc["notification_receiver"],
          "notification_sender": doc["notification_sender"],
          "notification_new": doc["notification_new"],
          "notification_type": doc["notification_type"],
          "notification_senderName": "admin",
          "notification_message": "",
          "docid": doc.id
        };
        // if (doc["notification_new"] == "yes") {
        //   howManyNewNotification = howManyNewNotification + 1;
        // }

        allNotificationData.add(data);
      });
    });

    List storesId = [];
    allNotificationData
        .where((doc) {
        storesId.add(doc['notification_sender']);
        return true;
    }).toList();

    storesId = storesId.toSet().toList();
    storesId.add('');

    var getAllStores = await FirebaseFirestore.instance
        .collection('stores')
        //.where("store_id", whereIn: storesId)
        .get()
        .catchError((error) => print("Failed"));

    for (var i = 0; i < allNotificationData.length; i = i + 1) {
      var checkAdmin = false;
      for (var t = 0; t < getAllStores.docs.length; t = t + 1) {
        if (allNotificationData[i]['notification_sender'] == getAllStores.docs[t].id) {
          allNotificationData[i]['notification_senderName'] = getAllStores.docs[t].get("store_name");
          var messageData = await notificationMessage(notification_type: allNotificationData[i]['notification_type'],
              notification_senderName: allNotificationData[i]['notification_senderName'],
              notification_amount: allNotificationData[i]['notification_amount']
          );
          print("messageData");
          print(allNotificationData[i]['docid']);
          print(allNotificationData[i]['notification_type']);
          allNotificationData[i]['notification_message'] = messageData["body"];

          checkAdmin = false;
          break;
        } else {
          checkAdmin = true;
        }
      }

      if (checkAdmin == true) {
        allNotificationData[i]['notification_senderName'] = "أدمن";
        var messageData = await notificationMessage(notification_type: allNotificationData[i]['notification_type'],
            notification_senderName: allNotificationData[i]['notification_senderName'],
            notification_amount: allNotificationData[i]['notification_amount']
        );
        allNotificationData[i]['notification_message'] = messageData["body"];
      }
    }

    return {
      "data": allNotificationData,
      "howManyNewNotification": howManyNewNotification
    };
  }

  notificationMessage ({notification_type, notification_senderName, notification_amount}) async {
    if (notification_type == "StoreOfStoreSendCashBalanceToStore") {
      return {
        "title": "ارسال رصيد كاش",
        "body": "تم ارسال رصيد كاش بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "StoreOfStoreSendDebtBalanceToStore") {
      return {
        "title": "ارسال رصيد آجل",
        "body": "تم ارسال رصيد آجل بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "StoreOfStoreAcceptCashBalanace") {
      return {
        "title": "الموافقة على رصيد كاش",
        "body": "تمت الموافقة على رصيد كاش بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "StoreOfStoreAcceptDeptBalanace") {
      return {
        "title": "الموافقة على رصيد آجل",
        "body": "تمت الموافقة على رصيد آجل بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    }
    // Reject Balance
    else if (notification_type == "StoreOfStoreRejectCashBalanceToStore") {
      return {
        "title": "رفض رصيد كاش",
        "body": "تم رفض رصيد كاش بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "StoreOfStoreRejectDebtBalanceToStore") {
      return {
        "title": "رفض رصيد آجل",
        "body": "تم رفض رصيد آجل بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    }

    // IndebtednessToStore
    else if (notification_type == "StoreOfStoreSendIndebtednessToStore") {
      return {
        "title": "خصم مديونية",
        "body": "تم خصم مديونية بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    }

    // Retrieve Balance
    else if (notification_type == "StoreOfStoreRetrieveCashBalanceToStore") {
      return {
        "title": "استرجاع رصيد كاش",
        "body": "تم استرجاع رصيد كاش بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "StoreOfStoreRetrieveDebtBalanceToStore") {
      return {
        "title": "استرجاع رصيد آجل",
        "body": "تم استرجاع رصيد آجل بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    }

    // Request Balance
    else if (notification_type == "storeRequestCashBalanceFromStoreOfStore") {
      return {
        "title": "طلب رصيد كاش",
        "body": "تم طلب رصيد كاش بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else if (notification_type == "storeRequestDebtBalanceFromStoreOfStore") {
      return {
        "title": "طلب رصيد آجل",
        "body": "تم طلب رصيد آجل بقيمة " + notification_amount + " من قبل " + notification_senderName
      };
    } else {
      return {
        "title": "",
        "body": ""
      };
    }
  }

  sendNotification ({
    token,
    title,
    body,
    storeId,
    notification_type,
    notification_amount,
    notification_senderName,
    notification_date,
    notification_sender,
    notification_receiver,
    docid,
  }) async {

    var messageData = await notificationMessage(notification_type: notification_type,
        notification_senderName: notification_senderName,
        notification_amount: notification_amount
    );

    var title = messageData["title"];
    var body = messageData["body"];


    print(token);
    var getAllItems = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $notificationToken',
        },
        body: json.encode({
          "notification": {"title": title, "body": body, "sound": "default"},
          "priority": "high",
          "data": {
            "notification_type": notification_type,
            "notification_amount": notification_amount,
            "notification_date": notification_date,
            "notification_sender": notification_sender,
            "notification_receiver": notification_receiver,
            "notification_message": body,
            "docid": docid,
          },
          "registration_ids": [
            token
          ]
        })
    );

    return "sent";
  }

  removeNewNotificationStatus () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var storeId = await userInfo.getStoreId();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    await FirebaseFirestore.instance
        .collection('notifications')
        .where("notification_receiver", isEqualTo: storeId)
        .get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.update(document.reference, {
          "notification_new": "no"
        });
      });

      return batch.commit();
    });

    return "deletedNewStatus";

  }

}