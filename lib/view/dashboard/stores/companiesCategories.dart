// @dart=2.11

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';
import 'package:storeapp/model/companiesClass.dart';
import 'package:storeapp/providers/categories_and_companies.dart';

import '../../colors.dart'; // new

class companiesCategories extends StatefulWidget {
  @override
  companiesCategoriesState createState() => companiesCategoriesState();
}

class companiesCategoriesState extends State {
  ScrollToTop scrolling = ScrollToTop();

  FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CategoriesAndCompaniesProvider>(context, listen: false)
          .getCompaniesCategoriesFun();
    });
    print("got the data ");
    // getTheDataVar = getCompaniesCategoriesFun();
  }

  // List getCompaniesCategories = [];
  // getCompaniesCategoriesFun () async {
  //   companiesAndCategories getCompaniesCategoriesClass = new companiesAndCategories();
  //   var getCompaniesCategoriesForDisplay = await getCompaniesCategoriesClass.getCompaniesCategories();
  //
  //   setState(() {
  //     getCompaniesCategories = getCompaniesCategoriesForDisplay;
  //   });
  //
  //   return getCompaniesCategories;
  // }

  Future getTheDataVar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: asideMenu(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: MenuBar(),
        ),
        bottomNavigationBar: bottomBar(context),
        body: Consumer<CategoriesAndCompaniesProvider>(
          builder: (context, categories, child) => categories.dataIsInit
              ? SingleChildScrollView(
                  controller: scrolling.returnTheVariable(),
                  child: Container(
                    margin: EdgeInsets.only(top: 15, left: 0),
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 100, left: 10, right: 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text("التصنيفات",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                              textAlign: TextAlign.right),
                        ),
                        GridView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: categories.getCompaniesCategories.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/companies',
                                      arguments: companiesClass(
                                          companyCategoryId: categories
                                                  .getCompaniesCategories[index]
                                              ['docid'],
                                          companyCategoryName: categories
                                                  .getCompaniesCategories[index]
                                              ['companyCategories_name']));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        categories.getCompaniesCategories[index]
                                            ["companyCategories_imgurl"],
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                  decoration: BoxDecoration(
                                      color: secondColor,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              );
                            }),
                      ],
                    ),
                  ))
              : Container(
                  margin: const EdgeInsets.only(bottom: 5, top: 50),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ),
        floatingActionButton: scrolling.buttonLayout());
  }
}
//
// FutureBuilder(
// future: getTheDataVar,
// builder: (BuildContext context, AsyncSnapshot snapshot) {
// if (snapshot.hasData == false) {
// return Container(
// margin: const EdgeInsets.only(bottom: 5, top: 50),
// child: Center(
// child: CircularProgressIndicator(),
// ),
// );
// } else {
// return SingleChildScrollView(
// controller: scrolling.returnTheVariable(),
// child: Container(
// margin: EdgeInsets.only(top: 15, left: 0),
// padding: const EdgeInsets.only(top: 0, bottom: 100, left: 10, right: 10),
// child: Column(
// children: [
// Container(
// alignment: Alignment.topRight,
// margin: EdgeInsets.only(bottom: 10),
// child: Text(
// "التصنيفات",
// style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
// textAlign: TextAlign.right
// ),
// ),
//
// GridView.builder(
// physics: ClampingScrollPhysics(),
// shrinkWrap: true,
// scrollDirection: Axis.vertical,
// gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
// crossAxisCount: 2,
// crossAxisSpacing: 20,
// mainAxisSpacing: 20,
// ),
// itemCount: getCompaniesCategories.length,
// itemBuilder: (BuildContext ctx, index) {
// return GestureDetector(
// onTap: () async {
// Navigator.pushNamed(context, '/companies', arguments: companiesClass(companyCategoryId: getCompaniesCategories[index]['docid'], companyCategoryName : getCompaniesCategories[index]['companyCategories_name']));
// },
// child: Container(
// alignment: Alignment.center,
// padding: EdgeInsets.only(left: 15, right: 15),
// child: CachedNetworkImage(
// imageUrl: getCompaniesCategories[index]["companyCategories_imgurl"],
// errorWidget: (context, url, error) => Icon(Icons.error),
// ),
// decoration: BoxDecoration(
// color: secondColor,
// borderRadius: BorderRadius.circular(15)),
// ),
// );
// }),
//
//
// ],
// ),
// )
// );
// }
// },
// )
//
