import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeapp/providers/categories_and_companies.dart';
import 'package:storeapp/providers/products.dart';
import 'package:storeapp/providers/user_info.dart';
import 'package:storeapp/view/dashboard/balance.dart';
import 'package:storeapp/view/dashboard/balanceRequestHistory.dart';
import 'package:storeapp/view/dashboard/homePage.dart';
import 'package:storeapp/view/dashboard/storeOfStores/balanceRequests.dart';
import 'package:storeapp/view/dashboard/storeOfStores/editProducts.dart';
import 'package:storeapp/view/dashboard/storeOfStores/myStores.dart';
import 'package:storeapp/view/dashboard/storeOfStores/profit.dart';
import 'package:storeapp/view/dashboard/stores/cards.dart';
import 'package:storeapp/view/dashboard/stores/companies.dart';
import 'package:storeapp/view/dashboard/stores/companiesCategories.dart';
import 'package:storeapp/view/dashboard/stores/myCards.dart';
import 'package:storeapp/view/dashboard/stores/printer.dart';
import 'package:storeapp/view/dashboard/stores/products.dart';
import 'package:storeapp/view/login.dart';
import 'package:storeapp/view/login_verification.dart';

import 'database/userinfoDatabase.dart';
import 'model/cardsClass.dart';
import 'model/companiesClass.dart';
import 'model/loginAuthClass.dart';
import 'model/productsClass.dart';

/* Streams */
StreamController streamMessages = StreamController.broadcast();
Stream stream = streamMessages.stream;
/* End Srteams */

/* Start Role */
var storeRoleFrontEnd;
/* End Role */

/* Start Notification Token */
var notificationToken = "";
/* End Notification Token */

/* Start My Balance */
var myBalance = {};
/* End My Balance */

/* Start Notification */
List notificationData = [];
var howManyNewNotification = 0;
/* End Notification */

Future<void> updateFrontEndFromNotification(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data["notification_type"] == "nothing") {
    // return;
  }

  // Balance
  if (message
              .data['notification_type'] ==
          "StoreOfStoreSendCashBalanceToStore" ||
      message.data['notification_type'] ==
          "StoreOfStoreSendDebtBalanceToStore" ||
      message.data['notification_type'] == "StoreOfStoreAcceptCashBalanace" ||
      message.data['notification_type'] == "StoreOfStoreAcceptDeptBalanace") {
    myBalance["store_totalBalance"] =
        (double.parse(myBalance["store_totalBalance"]) +
                double.parse(message.data["notification_amount"]))
            .toStringAsFixed(2)
            .toString();

    if (message.data['notification_type'] ==
            "StoreOfStoreSendDebtBalanceToStore" ||
        message.data['notification_type'] == "StoreOfStoreAcceptDeptBalanace") {
      myBalance["store_indebtedness"] =
          (double.parse(myBalance["store_indebtedness"]) +
                  double.parse(message.data["notification_amount"]))
              .toStringAsFixed(2)
              .toString();
    }
  } else if (message.data['notification_type'] ==
          "StoreOfStoreRetrieveCashBalanceToStore" ||
      message.data['notification_type'] ==
          "StoreOfStoreRetrieveDebtBalanceToStore") {
    myBalance["store_totalBalance"] =
        (double.parse(myBalance["store_totalBalance"]) -
                double.parse(message.data["notification_amount"]))
            .toStringAsFixed(2)
            .toString();
  }

  if (message.data['notification_type'] ==
      "StoreOfStoreSendIndebtednessToStore") {
    myBalance["store_indebtedness"] =
        (double.parse(myBalance["store_indebtedness"]) -
                double.parse(message.data["notification_amount"]))
            .toStringAsFixed(2)
            .toString();
  }

  // How Mnay
  howManyNewNotification = howManyNewNotification + 1;

  // Add The New Message
  notificationData.insert(0, {
    "notification_amount": message.data['notification_amount'],
    "notification_date": message.data["notification_date"],
    "notification_receiver": message.data["notification_receiver"],
    "notification_sender": message.data["notification_sender"],
    "notification_new": "yes",
    "notification_type": message.data['notification_type'],
    "notification_senderName": "admin",
    "notification_message": message.data['notification_message'],
    "docid": message.data['docid']
  });

  streamMessages.add({
    "message": message,
    "status": "notification",
    "store_totalBalance": myBalance["store_totalBalance"],
    "store_indebtedness": myBalance["store_indebtedness"],
    "howManyNewNotification": howManyNewNotification,
    //"notificationData": notificationData,
  });

  //_handleMessage(message);
}

Future<void> updateFrontEndFromNotificationPlusShowLocalNotification(
    RemoteMessage message) async {
  updateFrontEndFromNotification(message);

  showLocalNotification(message);
}

showLocalNotification(RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (message != null) {
    print("message");
    print(message);
    print(message.data);
    print(message);
    print(message.notification?.title.toString());
    print(message.notification?.body.toString());
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launchericon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    //onDidReceiveLocalNotification: onDidReceiveLocalNotification
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification(""));
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;

  flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launchericon',
          // other properties...
        ),
      ));
}

selectNotification(String payload) {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

void requestIOSPermissions() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: false,
        badge: false,
        sound: false,
      );
}

permissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

onDidReceiveLocalNotification() async {
  // display a dialog with the notification details, tap ok to go to another page
  var context;
  showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text("title"),
      content: Text("body"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {},
        )
      ],
    ),
  );
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
      updateFrontEndFromNotificationPlusShowLocalNotification);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    updateFrontEndFromNotification(message);

    showLocalNotification(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    updateFrontEndFromNotification(message);
  });

  /*await FirebaseFirestore.instance.runTransaction((transaction) async {
    await FirebaseFirestore.instance
        .collection('stores')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        /*CollectionReference storesOfStores1 = FirebaseFirestore.instance.collection('stores');
        storesOfStores1.doc(doc.id).update({
            'store_email': "",
        });*/



        /*CollectionReference storesOfStores = FirebaseFirestore.instance.collection('storesInfo');
        storesOfStores.doc(doc.id).update({
          'store_email': doc.get("store_email"),
        });*/
      });
    });
  });*/

  var selectedIndex = 0;

  var initialRoute = '/';
  //await FirebaseAuth.instance.signOut();
  User user = FirebaseAuth.instance.currentUser;

  myBalance["store_totalBalance"] = "";
  myBalance["store_indebtedness"] = "";
  if (user != null) {
    userinfoDatabase userInfo = new userinfoDatabase();
    storeRoleFrontEnd = await userInfo.getStoreRole();
    var checkIfLoggedIn =
        await userInfo.checkIfLoggedIn(phonenumberParameter: "");

    if (checkIfLoggedIn["status"] != "empty") {
      // signed in
      initialRoute = '/HomePage';

      RemoteMessage message;
      message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        if (message
                    .data['notification_type'] ==
                "StoreOfStoreSendCashBalanceToStore" ||
            message
                    .data['notification_type'] ==
                "StoreOfStoreSendDebtBalanceToStore" ||
            message.data['notification_type'] ==
                "StoreOfStoreAcceptCashBalanace" ||
            message.data['notification_type'] ==
                "StoreOfStoreAcceptDeptBalanace" ||
            message.data['notification_type'] ==
                "StoreOfStoreRetrieveCashBalanceToStore" ||
            message.data['notification_type'] ==
                "StoreOfStoreRetrieveDebtBalanceToStore" ||
            message.data['notification_type'] ==
                "StoreOfStoreSendIndebtednessToStore") {
          initialRoute = "/balance";
        } else if (message.data['notification_type'] ==
                "storeRequestCashBalanceFromStoreOfStore" ||
            message.data['notification_type'] ==
                "storeRequestDebtBalanceFromStoreOfStore") {
          initialRoute = "/balanceRequests";
        }
      }

      //FirebaseMessaging.instance.subscribeToTopic("all");

      //balanceController balance = new balanceController();
      //myBalance = await balance.getMyBalance();
      myBalance = checkIfLoggedIn["data"];
    }
  }
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<CategoriesAndCompaniesProvider>(
          create: (context) => CategoriesAndCompaniesProvider()),
      ChangeNotifierProvider<UserInfoProvider>(
          create: (context) => UserInfoProvider()),
      ChangeNotifierProvider<ProductsProvider>(
        create: (contex) => ProductsProvider(),
      )
    ],
    child: Builder(builder: (context) {
      return MaterialApp(
          navigatorKey: navigatorKey,
          /*builder: (context, child) {
                  return Scaffold(
                    key: _scaffoldkeyRetrieveBalance,
                   // drawer: asideMenu(navigationKey: navigatorKey,),
                    appBar: MenuBar(context, ""),
                    body: child,
                  );
                },*/
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => loginPage(),
            '/HomePage': (context) => homePage(),
            '/balance': (context) => balance(),
            '/balanceRequestHistory': (context) => balanceRequestHistory(),
            '/editproducts': (context) => editProducts(),
            '/myStores': (context) => myStores(),
            '/profit': (context) => profit(),
            '/balanceRequests': (context) => balanceRequest(),
            '/companiesCategories': (context) => companiesCategories(),
            '/myCards': (context) => myCards(),
            '/printer': (context) => printerPage(),
          },
          // Start the app with the "/" named route. In this case, the app starts
          // on the FirstScreen widget.
          initialRoute: initialRoute,
          onGenerateRoute: (settings) {
            // If you push the PassArguments route
            if (settings.name == '/loginAuthentication') {
              // Cast the arguments to the correct type: ScreenArguments.
              final args = settings.arguments as loginAuthClass;

              // Then, extract the required data from the arguments and
              // pass the data to the correct screen.
              return MaterialPageRoute(
                builder: (context) {
                  return loginVerification(
                      countryCode: args.countryCode,
                      phoneNumber: args.phoneNumber,
                      storeId: args.storeId,
                      storeRole: args.storeRole);
                },
              );
            } else if (settings.name == '/cards') {
              // Cast the arguments to the correct type: ScreenArguments.
              final args = settings.arguments as cardsClass;

              // Then, extract the required data from the arguments and
              // pass the data to the correct screen.
              return MaterialPageRoute(
                builder: (context) {
                  return cards(productId: args.productId);
                },
              );
            } else if (settings.name == '/companies') {
              // Cast the arguments to the correct type: ScreenArguments.
              final args = settings.arguments as companiesClass;

              // Then, extract the required data from the arguments and
              // pass the data to the correct screen.
              return MaterialPageRoute(
                builder: (context) {
                  return companies(
                    companyCategoryId: args.companyCategoryId,
                    companyCategoryName: args.companyCategoryName,
                  );
                },
              );
            } else if (settings.name == '/products') {
              // Cast the arguments to the correct type: ScreenArguments.
              final args = settings.arguments as productClass;

              // Then, extract the required data from the arguments and
              // pass the data to the correct screen.
              return MaterialPageRoute(
                builder: (context) {
                  return products(
                    companyId: args.companyId,
                    companyName: args.companyName,
                  );
                },
              );
            }
          },
          debugShowCheckedModeBanner: false,
          title: 'Souq Card',
          theme: ThemeData(
              brightness: Brightness.light, primaryColor: Colors.white),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          //home: HomePage(),
          supportedLocales: [
            const Locale('ar', 'AE'), // Arabic
            const Locale('en', 'US'), // English
          ],
          locale: Locale('ar') // OR Locale('ar', 'AE') OR Other RTL locales,

          );
    }),
  ));
}

/*

navigationKey.currentState.pushNamed('/')
* StreamBuilder(
                  stream: streamMessages.stream,
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot, ) {
                    if (!snapshot.hasData) {
                      if (storeRoleFrontEnd == "empty") {
                        return Drawer(
                          child: Text(""),
                        );
                      } else {
                        return asideMenu(navigationKey: navigatorKey,);
                      }
                    } else {
                      if (snapshot.data["status"] == "logout") {
                        return Drawer(
                          child: Text(""),
                        );
                      } else if (snapshot.data["status"] == "login") {
                        return asideMenu(navigationKey: navigatorKey, );
                      } else {
                        return Drawer(
                          child: Text(""),
                        );
                      }
                    }
              })
* */
