// @dart=2.11

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/companiesAndCategories.dart';
import 'package:storeapp/controller/homePageSlider.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';
import 'package:storeapp/model/companiesClass.dart';
import 'package:storeapp/model/productsClass.dart';
import 'package:storeapp/providers/user_info.dart';

class homePage extends StatefulWidget {
  GlobalKey<NavigatorState> navigationKey;

  homePage({
    this.navigationKey,
  });

  homePageState createState() => homePageState();
}

class homePageState extends State {
  GlobalKey<NavigatorState> navigationKey;

  homePageState({
    this.navigationKey,
  });

  ScrollToTop scrolling = ScrollToTop();

  var carouselArr = [
    //'assets/images/patients/Hematologie.png',
    // 'assets/images/patients/resultats-analyse.png',
    //'assets/images/patients/resultats-analyse4.png',
  ];
  var tahaHa = "s";
  FirebaseMessaging messaging;
  @override
  void initState() {
    Provider.of<UserInfoProvider>(context, listen: false).initAppGeneralData();

    messaging = FirebaseMessaging.instance;
    /*messaging.getToken().then((value) {

    });*/

    getTheDataVar = getSliderImages();
    //getProductsFun();
    getTheCategoriesVar = getCompaniesCategoriesFun();

    // Get All Company
    getTheCompaniesVar = getCompaniesFun();

    super.initState();
  }

  Future getTheDataVar;
  getSliderImages() async {
    homePageSliderController slider = new homePageSliderController();
    var sliderGetImages = await slider.getAllData();

    setState(() {
      carouselArr = sliderGetImages;
    });

    return sliderGetImages;
  }

  Future getTheCategoriesVar;
  List getCompaniesCategories = [];
  getCompaniesCategoriesFun() async {
    companiesAndCategories getCompaniesCategoriesClass =
        new companiesAndCategories();
    var getCompaniesCategoriesForDisplay =
        await getCompaniesCategoriesClass.getCompaniesCategories();

    setState(() {
      getCompaniesCategories = getCompaniesCategoriesForDisplay;
    });

    return getCompaniesCategoriesForDisplay;
  }

  // Get All Companies Data
  Future getTheCompaniesVar;
  List getCompanies = [];
  getCompaniesFun() async {
    companiesAndCategories getCompaniesClass = new companiesAndCategories();
    var getCompaniesForDisplay = await getCompaniesClass.getAllCompanies();

    setState(() {
      getCompanies = getCompaniesForDisplay;
    });

    /*await FirebaseFirestore.instance
        .collection('balanceHistory')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        await FirebaseFirestore.instance
            .collection('balanceHistory')
            .doc(doc.id).update({
          "balanceHistory_afterDebtPrice": doc.get("balanceHistory_afterDepthPrice"),
          "balanceHistory_beforeDebtPrice": doc.get("balanceHistory_beforeDepthPrice"),
        });
      });
    });*/

    return getCompaniesForDisplay;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => ExitAlertMessage(context),
      child: Scaffold(
          drawer: asideMenu(),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: MenuBar(),
          ),
          bottomNavigationBar: bottomBar(context),
          body: SingleChildScrollView(
              controller: scrolling.returnTheVariable(),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 0, left: 0),
                // padding: const EdgeInsets.only(top: 0, bottom: 100, left: 10, right: 10),
                child: Column(
                  children: [
                    /*TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                    onPressed: () async {
                    print('myBalance["store_totalBalance"]');
                    print(myBalance["store_totalBalance"]);

                    notificationData.add({"notification_amount": "700", "notification_date": "2022-02-17 – 8:00:19 PM", "notification_receiver": "XWE9DK3uG4h3PXj6x9yt", "notification_sender": "oCJkylGZgJxuqRLWc8vV", "notification_new": "no", "notification_type": "StoreOfStoreSendDebtBalanceToStore", "notification_senderName": "طه مندوب", "notification_message":" تم ارسال رصيد آجل من قبل طه مندوب بقيمة 700", "docid": "bFTCisP1yYYkwmxGfe7M"});
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                    label: Text("insert if can", style: TextStyle(color: Colors.white, fontSize: 12),)
                ),*/
                    /*TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      /*navigationKey.currentState.setState(() {
                        storeRoleFrontEnd = "taha";
                      });*/
                      //myBalance["store_totalBalance"] = "200";
                      //myBalance["store_indebtedness"] = "400";
                      //streamMessages.add({"status": "balance", "balance": "500"});
                      //Navigator.of(context).pushNamed('/HomePage');


                     /* var check = "";

                      var getCheck = await FirebaseFirestore.instance
                          .collection('test')
                          .where("status", isEqualTo: "can")
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        querySnapshot.docs.forEach((doc) {
                          check = "can";
                        });
                      });

                      if (check == "can") {
                        await FirebaseFirestore.instance
                            .collection('test')
                        .doc("1")
                        .update({
                          "status": "no"
                        });

                        await FirebaseFirestore.instance
                            .collection('test')
                            .add({
                          "data": "new data"
                        });
                      }*/

                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                        DocumentReference getCheck = FirebaseFirestore.instance.collection("test").doc("1".toString());
                        var test = FirebaseFirestore.instance.collection("test");

                        DocumentSnapshot checkInfo;
                        checkInfo = await transaction.get(getCheck);

                        if (checkInfo.get("status") == "can") {
                          CollectionReference updateTest = FirebaseFirestore.instance
                              .collection('test');
                          DocumentReference updateTestDoc = updateTest.doc("1");
                          transaction.update(updateTestDoc, {"status": "no"});


                          CollectionReference newTest = FirebaseFirestore.instance
                              .collection('test');
                          var rng = new Random();
                          DocumentReference newTestDoc = newTest.doc(rng.nextInt(50).toString());
                          transaction.set(newTestDoc, {"data": "new data"});
                        }




                      });

                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                    label: Text("insert if can", style: TextStyle(color: Colors.white, fontSize: 12),)
                ),*/

                    // Get aLL companies
                    FutureBuilder(
                      future: getTheDataVar,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return Text("");
                        } else {
                          return Container(
                              margin: const EdgeInsets.only(
                                  bottom: 5, top: 5, right: 8),
                              padding: const EdgeInsets.only(
                                right: 2,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: getCompanies
                                      .map((item) => GestureDetector(
                                            onTap: () async {
                                              Navigator.pushNamed(
                                                  context, '/products',
                                                  arguments: productClass(
                                                      companyId: item['docid'],
                                                      companyName: item[
                                                          'companies_name']));
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: Text(
                                                item["companies_name"],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1.0,
                                                      color:
                                                          HexColor("#431BA8")),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: HexColor("#1B1B1D")),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ));
                        }
                      },
                    ),

                    FutureBuilder(
                      future: getTheDataVar,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 50),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container(
                              margin: const EdgeInsets.only(bottom: 0, top: 0),
                              width: double.infinity,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  enlargeCenterPage: true,
                                  viewportFraction: 1,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 4),
                                  // aspectRatio: 1.0,
                                  //  initialPage: 2,
                                ),
                                items: carouselArr.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: double.infinity,
                                        // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                        /*decoration: BoxDecoration(
                                        color: Colors.blue
                                    ),*/
                                        child: CachedNetworkImage(
                                          imageUrl: i,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.fill,
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ));
                        }
                      },
                    ),

                    // Categories
                    FutureBuilder(
                      future: getTheCategoriesVar,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 50),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return GridView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  new SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 2 / 1.5,
                              ),
                              itemCount: getCompaniesCategories.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Navigator.pushNamed(context, '/companies',
                                        arguments: companiesClass(
                                            companyCategoryId:
                                                getCompaniesCategories[index]
                                                    ['docid'],
                                            companyCategoryName:
                                                getCompaniesCategories[index][
                                                    'companyCategories_name']));
                                  },
                                  child: Container(
                                    //alignment: Alignment.topCenter,
                                    //margin: EdgeInsets.only(bottom: 15),
                                    child: CachedNetworkImage(
                                        imageUrl: getCompaniesCategories[index]
                                            ["companyCategories_imgurl"],
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        fit: BoxFit.fill),
                                    decoration: BoxDecoration(
                                        //color: Colors.amber,
                                        //  borderRadius: BorderRadius.circular(15)
                                        ),
                                  ),
                                );
                              });
                        }
                      },
                    ),
                  ],
                ),
              )),
          floatingActionButton: scrolling.buttonLayout()),
    );
  }
}
