// @dart=2.11

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';
import 'package:storeapp/model/productsClass.dart';
import 'package:storeapp/providers/categories_and_companies.dart'; // new

class companies extends StatefulWidget {
  final String companyCategoryId;
  final String companyCategoryName;

  companies({
    this.companyCategoryId,
    this.companyCategoryName,
  });

  @override
  companiesState createState() => companiesState(
      companyCategoryId: companyCategoryId,
      companyCategoryName: companyCategoryName);
}

class companiesState extends State {
  final String companyCategoryId;
  final String companyCategoryName;

  companiesState({
    this.companyCategoryId,
    this.companyCategoryName,
  });

  ScrollToTop scrolling = ScrollToTop();

  final storesSearch = TextEditingController();

  FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CategoriesAndCompaniesProvider>(context, listen: false)
          .getCompaniesFun(companyCategoryId);
    });
    // getTheDataVar = getCompaniesFun();
  }
  // Future getTheDataVar;

  // List getCompanies = [];
  // List getDataSearch = [];
  // getCompaniesFun () async {
  //   companiesAndCategories getCompaniesClass = new companiesAndCategories(companiesAndCategories_categoryId: companyCategoryId);
  //   var getCompaniesForDisplay = await getCompaniesClass.getCompanies();
  //
  //   setState(() {
  //     getCompanies = getCompaniesForDisplay;
  //     getDataSearch = getCompaniesForDisplay;
  //   });
  //
  //   return getCompaniesForDisplay;
  // }

  @override
  Widget build(BuildContext context) {
    var appBar = PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: MenuBar(),
    );

    return Scaffold(
        drawer: asideMenu(),
        appBar: appBar,
        bottomNavigationBar: bottomBar(context),
        body: SingleChildScrollView(
            controller: scrolling.returnTheVariable(),
            child: Container(
              margin: EdgeInsets.only(top: 15, left: 0),
              padding:
                  const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                        companyCategoryName != ''
                            ? "شركات خاصة ب: " + companyCategoryName
                            : "جميع الشركات",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.right),
                  ),
                  Consumer<CategoriesAndCompaniesProvider>(
                    builder: (context, companies, child) => companies
                            .companiesAreInit
                        ? (companies.companies.containsKey(companyCategoryId) &&
                                companies
                                    .companies[companyCategoryId].isNotEmpty)
                            ? GridView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                gridDelegate:
                                    new SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: companies
                                    .companies[companyCategoryId].length,
                                itemBuilder: (BuildContext ctx, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      Navigator.pushNamed(context, '/products',
                                          arguments: productClass(
                                              companyId: companies.companies[
                                                      companyCategoryId][index]
                                                  ['docid'],
                                              companyName: companies.companies[
                                                      companyCategoryId][index]
                                                  ['companies_name']));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: HexColor("#F65D12"),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      //  alignment: Alignment.center,
                                      //  padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 120,
                                            margin: EdgeInsets.only(bottom: 0),
                                            child: CachedNetworkImage(
                                              imageUrl: companies.companies[
                                                      companyCategoryId][index]
                                                  ["companies_image"],
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(top: 20),
                                              child: Text(
                                                  companies.companies[
                                                          companyCategoryId]
                                                      [index]['companies_name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.right)),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                            : Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Text("لاتوجد شركات متاحة",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25)),
                              )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 50),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  )
                ],
              ),
            )),
        floatingActionButton: scrolling.buttonLayout());
  }
}
//
// Widget data(){
//   return Scaffold(
//       drawer: asideMenu(),
//       appBar: appBar,
//       bottomNavigationBar: bottomBar(context),
//       body: SingleChildScrollView(
//           controller: scrolling.returnTheVariable(),
//           child: Container(
//             margin: EdgeInsets.only(top: 15, left: 0),
//             padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
//             child: Column(
//               children: [
//                 Container(
//                   alignment: Alignment.topRight,
//                   margin: EdgeInsets.only(bottom: 10),
//                   child: Text(
//                       companyCategoryName != ''?"شركات خاصة ب: " + companyCategoryName: "جميع الشركات",
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                       textAlign: TextAlign.right
//                   ),
//                 ),
//
//                 FutureBuilder(
//                   future: getTheDataVar,
//                   builder: (BuildContext context, AsyncSnapshot snapshot) {
//                     if (snapshot.hasData == false) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 5, top: 50),
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     } else {
//                       return GridView.builder(
//                           physics: ClampingScrollPhysics(),
//                           shrinkWrap: true,
//                           scrollDirection: Axis.vertical,
//
//                           gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
//                             maxCrossAxisExtent: 200,
//                             crossAxisSpacing: 20,
//                             mainAxisSpacing: 20,
//                             childAspectRatio: 0.8,
//                           ),
//
//                           itemCount: getCompanies.length,
//                           itemBuilder: (BuildContext ctx, index) {
//                             return GestureDetector(
//                               onTap: () async {
//                                 Navigator.pushNamed(context, '/products', arguments: productClass(companyId: getCompanies[index]['docid'], companyName: getCompanies[index]['companies_name']));
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: HexColor("#F65D12"),
//                                     borderRadius: BorderRadius.circular(15)
//                                 ),
//                                 //  alignment: Alignment.center,
//                                 //  padding: EdgeInsets.all(15),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       width: double.infinity,
//                                       height: 120,
//                                       margin: EdgeInsets.only(bottom: 0),
//                                       child: CachedNetworkImage(
//                                         imageUrl: getCompanies[index]["companies_image"],
//                                         errorWidget: (context, url, error) => Icon(Icons.error),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                     Container(
//                                         margin: EdgeInsets.only(top: 20),
//                                         child: Text(
//                                             getCompanies[index]['companies_name'],
//                                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//                                             textAlign: TextAlign.right
//                                         )
//                                     ),
//                                   ],
//                                 ),
//
//                               ),
//                             );
//                           });
//                     }
//                   },
//                 ),
//
//
//
//
//               ],
//             ),
//           )
//       ),
//       floatingActionButton: scrolling.buttonLayout()
//   );
// }
//
