// @dart=2.11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storeapp/controller/notification.dart';

import '../main.dart';

class userinfoDatabase {

  final userInfo = new FlutterSecureStorage();

  updateUserInfo({token, phonenumber, storeId, storeRole, printerAddress}) async{
    await userInfo.write(key: 'token', value: token);
    await userInfo.write(key: 'phonenumber', value: phonenumber);
    await userInfo.write(key: 'storeId', value: storeId);
    await userInfo.write(key: 'storeRole', value: storeRole);
  }

  deleteUserInfo() async{
    await userInfo.delete(key: 'token');
    await userInfo.delete(key: 'phonenumber');
    await userInfo.delete(key: 'storeId');
    await userInfo.delete(key: 'storeRole');
  }

  Future<String> getSecurityToken () async{
    String token =  await userInfo.read(key: 'token');
    if(token.toString() == "null"){
      token = "empty";
    }
    return token;
  }

  Future<String> getUserphonenumber () async{
    String phonenumber = await userInfo.read(key: 'phonenumber');
    if(phonenumber == null){
      phonenumber = 'empty';
    } else {

    }
    return phonenumber;
  }

  updateUserTextSize({size}) async{
    await userInfo.write(key: 'textSize', value: size);
  }

  Future<String> getUserTextSize () async{
    String textSize = await userInfo.read(key: 'textSize');
    if(textSize == null){
      textSize = 'empty';
    } else {

    }
    return textSize;
  }

  checkIfLoggedIn ({phonenumberParameter}) async{
    String phonenumber = "";
    if (phonenumberParameter == "") {
      phonenumber = await userInfo.read(key: 'phonenumber');

      if (phonenumber == null) {
        phonenumber = "empty";
      }
    } else {
      phonenumber = phonenumberParameter;
    }

    var checkUser = "empty";
    if (phonenumber == "empty") {
      return {
        "status": checkUser,
      };
    }



    var userBalance = {
      "store_debtBalance": "",
      "store_cashBalance": "",
      "store_indebtedness": "",
      "store_totalBalance": "",
    };

    var id = "";

    var storeRole = "";

    var storeInfo = await FirebaseFirestore.instance
        .collection('storesInfo')
        .where("store_phoneNumber", isEqualTo: phonenumber)
        .get()
        .catchError((e) {
          print("error");
        });

    for (var i = 0; i < storeInfo.docs.length; i = i + 1) {
      if (storeInfo.docs[i].get("store_status") == "true") {

        var storeData = await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeInfo.docs[i].id)
            .get()
            .catchError((e) {
            });

        if (storeData != null) {
          checkUser = "exist";
          userBalance["store_debtBalance"] = double.parse(storeData.get("store_debtBalance").toString()).toStringAsFixed(2).toString();
          userBalance["store_cashBalance"] = double.parse(storeData.get("store_cashBalance").toString()).toStringAsFixed(2).toString();
          userBalance["store_indebtedness"] = double.parse(storeData.get("store_indebtedness").toString()).toStringAsFixed(2).toString();
          userBalance["store_totalBalance"] = ((double.parse(storeData.get("store_cashBalance").toString()) + double.parse(storeData.get("store_debtBalance").toString())).toStringAsFixed(2)).toString();
          storeRole = storeData.get("store_storeType");
          id = storeInfo.docs[i].id;

          // Notification Update My Token
          FirebaseMessaging messaging;
          messaging = FirebaseMessaging.instance;
          messaging.getToken().then((value) async {
            print("token");
            print(value);

            await FirebaseFirestore.instance
                .collection('stores')
                .doc(id)
                .update({
              "store_token": value,
            });
          });

          // Get Notification Key
          var getKey = await FirebaseFirestore.instance
              .collection('notification')
              .get();


          notificationToken = getKey.docs[0].get("token");
        }


        break;
      } else {
        checkUser = 'empty';
      }
    }

    if (storeInfo.docs.length == 0) {
      checkUser = 'empty';
    }

    notificationClass getNotData = new notificationClass();
    var getNotificationData = await getNotData.getAllData(id: id);
    notificationData = getNotificationData['data'];
    howManyNewNotification = getNotificationData['howManyNewNotification'];

    return {
      "status": checkUser,
      "id": id,
      "data": userBalance,
      "storeRole": storeRole,
      "notificationData": getNotificationData['data'],
      "howManyNewNotification": getNotificationData['howManyNewNotification']
    };
  }

  Future<String> getStoreId () async{
    String storeId = await userInfo.read(key: 'storeId');
    if(storeId == null){
      storeId = 'empty';
    }
    return storeId;
  }

  Future<String> getStoreRole () async{
    String storeRole = await userInfo.read(key: 'storeRole');
    if(storeRole == null){
      storeRole = 'empty';
    }
    return storeRole;
  }

  updatePrinterAddress ({String printerAddress}) async {
    await userInfo.write(key: 'printerAddress', value: printerAddress);
  }

  updatePrinterName ({String printerName}) async {
    await userInfo.write(key: 'printerName', value: printerName);
  }

  Future<String> getPrinterAddress () async{
    String printerAddress = await userInfo.read(key: 'printerAddress');
    if(printerAddress == null){
      printerAddress = 'empty';
    }
    return printerAddress;
  }

  Future<String> getPrinterName () async{
    String printerName = await userInfo.read(key: 'printerName');
    if(printerName == null){
      printerName = 'empty';
    }
    return printerName;
  }

}