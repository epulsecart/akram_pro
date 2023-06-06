// @dart=2.11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/controller/notification.dart';
import 'package:storeapp/providers/user_info.dart';
import 'package:storeapp/view/colors.dart';

import '../main.dart';

var appBarHeight = 60.0;

class MenuBar extends StatefulWidget {
  MenuBarState createState() => MenuBarState();
}

class MenuBarState extends State {
  var counter;
  @override
  void initState() {
    message();
    requestIOSPermissions();
    permissions();
    counter = 0;

    //FirebaseMessaging.onMessage.listen(_handleMessage);
    super.initState();
  }

  RemoteMessage initialMessage;
  message() async {
    initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  }

  var test;

  notification(BuildContext context) async {
    var counter = 0;

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert;
        return Stack(
          children: [
            Positioned(
              //   bottom: 0,
              left: 0,
              // right: 0,
              top: 60,
              child: Container(
                  width: 200,
                  height: 300,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: notificationData.map((item) {
                        if (counter >= 10) {
                          return Visibility(
                            visible: false,
                            child: Text(""),
                          );
                        }
                        counter = counter + 1;

                        return GestureDetector(
                            onTap: () async {
                              if (item['notification_type'] == "StoreOfStoreSendCashBalanceToStore" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreSendDebtBalanceToStore" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreAcceptCashBalanace" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreAcceptDeptBalanace" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreRetrieveCashBalanceToStore" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreRetrieveDebtBalanceToStore" ||
                                  item['notification_type'] ==
                                      "StoreOfStoreSendIndebtednessToStore") {
                                item["notification_type"] = "yes";

                                Navigator.pushNamed(context, '/balance');
                              } else if (item['notification_type'] ==
                                      "storeRequestCashBalanceFromStoreOfStore" ||
                                  item['notification_type'] ==
                                      "storeRequestDebtBalanceFromStoreOfStore") {
                                Navigator.pushNamed(
                                    context, '/balanceRequests');
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: item["notification_new"] == "yes"
                                    ? HexColor("#B2B2B2")
                                    : Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    //margin: const EdgeInsets.only(left: 5,),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 0),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      item["notification_message"],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: item["notification_new"] == "yes"
                                            ? Colors.white
                                            : mainColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    //margin: const EdgeInsets.only(left: 5,),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item["notification_date"],
                                      style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: secondColor),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.0,
                                            color: Color(0xFF000000)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ));
                      }).toList(),
                    ),
                  )),
            ),
          ],
        );
      },
    );

    //print("howManyNewNotification");
    //print(howManyNewNotification);

    if (howManyNewNotification != 0) {
      notificationClass notifification = new notificationClass();
      var removeNewNotificationStatus =
          await notifification.removeNewNotificationStatus();
      print("removeNewNotificationStatus");
      print(removeNewNotificationStatus);
      if (removeNewNotificationStatus == "deletedNewStatus") {
        streamMessages.add(
            {"status": "howManyNewNotification", "howManyNewNotification": 0});

        for (var i = 0; i < notificationData.length; i = i + 1) {
          notificationData[i]['notification_new'] = "no";
        }
      }
    }
  }

  var leadingWidth = 60;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      leadingWidth: storeRoleFrontEnd == "empty" ? 20 : 60,
      backgroundColor: HexColor("#F65D12"),
      leading: StatefulBuilder(
        builder: (BuildContext context, StateSetter state) {
          if (storeRoleFrontEnd != "empty") {
            return Container(
              child: IconButton(
                alignment: Alignment.center,
                icon: const Icon(Icons.menu, size: 30, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          } else {
            return Container();
          }
        },
      ),
      centerTitle: false,
      title:
          StatefulBuilder(builder: (BuildContext context, StateSetter state) {
        if (storeRoleFrontEnd != "empty") {
          return StreamBuilder(
              stream: streamMessages.stream,
              builder: (
                BuildContext context,
                AsyncSnapshot<dynamic> snapshot,
              ) {
                if (snapshot.hasData) {
                  if (snapshot.data["status"] == "notification") {
                    //   _handleMessage(snapshot.data["message"]);

                    myBalance["store_totalBalance"] =
                        snapshot.data["store_totalBalance"];
                    myBalance["store_indebtedness"] =
                        snapshot.data["store_indebtedness"];
                  } else {
                    //  return Text("");
                  }
                }

                return Consumer<UserInfoProvider>(
                  builder: (context, user, child) =>
                      StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stores')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> userData) {
                      Map userData2 = {};
                      if (userData.data != null && userData.data.docs != null) {
                        userData2 = userData.data.docs
                            .firstWhere((element) => element.id == user.myId)
                            .data();
                        myBalance["store_totalBalance"] = (double.tryParse(
                                    userData2["store_cashBalance"].toString()) +
                                double.tryParse(
                                    userData2["store_debtBalance"].toString()))
                            .toStringAsFixed(2)
                            .toString();
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text("الرصيد",
                                    style: TextStyle(fontSize: 14)),
                              ),
                              Container(
                                child: Text(myBalance["store_totalBalance"],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text("المديونية",
                                    style: TextStyle(fontSize: 14)),
                              ),
                              Container(
                                child: Text(myBalance["store_indebtedness"],
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                );
              });
        } else {
          return Container(child: Text("تسجيل الدخول"));
        }
      }),
      actions: <Widget>[
        storeRoleFrontEnd == "empty"
            ? Container()
            : Container(
                margin: EdgeInsets.only(right: 0, left: 0),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: const Icon(Icons.notifications,
                            size: 30, color: Colors.white),
                        onPressed: () {
                          notification(context);
                        },
                      ),
                    ),
                    StreamBuilder(
                        stream: streamMessages.stream,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<dynamic> snapshot,
                        ) {
                          if (snapshot.hasData) {
                            if (snapshot.data["status"] == "notification") {
                              howManyNewNotification =
                                  snapshot.data["howManyNewNotification"];
                            } else if (snapshot.data["status"] ==
                                "howManyNewNotification") {
                              // return Text("");
                              howManyNewNotification =
                                  snapshot.data["howManyNewNotification"];
                            }
                          }

                          return howManyNewNotification != 0
                              ? Positioned(
                                  right: 5,
                                  top: 2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      howManyNewNotification.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: secondColor,
                                        shape: BoxShape.circle),
                                  ))
                              : Container();
                        }),
                  ],
                )
                /*Row(
              children: [
                Container(
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: const Icon(Icons.notifications, size: 30, color: Colors.white),
                    onPressed: () {
                      notification(context);
                    },
                  ),
                ),
              ]
          ),*/
                ),
      ],
    );
  }
}
/*
AppBar MenuBar(context) {




}*/
