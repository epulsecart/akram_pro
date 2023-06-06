import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storeapp/controller/productsAndCart.dart';

import '../database/userinfoDatabase.dart';

class UserInfoProvider extends ChangeNotifier {
  userinfoDatabase userInfo = new userinfoDatabase();
  var myRole;
  var myPhoneNumber;
  var myId;
  var myStoreOfStoreId;
  var getMyWhichPrice;
  var getMyStoreOfStoresPrice;
  var storeOfStoreDifference;
  bool userExist;
  bool userActive;

  void initAppGeneralData() async {
    productsCartsController prd = productsCartsController();

    myRole = await userInfo.getStoreRole();
    myPhoneNumber = await userInfo.getUserphonenumber();
    myId = await userInfo.getStoreId();
    if (myRole == "محل فرعي") {
      myStoreOfStoreId = await prd.getMyStoreOfStores();
      storeOfStoreDifference = await prd.getStoreOfStoreDifference(
          myStoreOfStoreId:
              myStoreOfStoreId['storesOfStores_representativesId'],
          productsCartsController_productId: "");
    }
    getMyWhichPrice = await prd.getMyWhichPrice(myId);
    getMyStoreOfStoresPrice = await prd.getMyStoreOfStoresPrice(
        store_id: myStoreOfStoreId['store_id']);

    var user =
        await FirebaseFirestore.instance.collection('stores').doc(myId).get();

    if (user.exists) {
      userExist = true;
      if (user.get("store_status") == "true") {
        userActive = true;
      } else
        userActive = false;
    } else
      userExist = false;
  }
}
