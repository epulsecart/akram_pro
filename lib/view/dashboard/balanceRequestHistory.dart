// @dart=2.11


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

class balanceRequestHistory extends StatefulWidget {
  balanceRequestHistoryState createState() => balanceRequestHistoryState();
}

class balanceRequestHistoryState extends State  {

  var showLoading = false;
  showLoadingFun(BuildContext context) {
    if (showLoading) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    } else {
      Navigator.pop(context);

      return;
    }
  }

  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getTheDataVar = getBalanceRequestsData();
  }

  balanceController balanceClass = new balanceController();
  /* Get Data */
  List balanceRequests = [];
  getBalanceRequestsData () async {

    var balanceRequestsFun = await balanceClass.getBalanceRequests();

    setState(() {
      balanceRequests = balanceRequestsFun;
    });

    return balanceRequests;
  }

  Future getTheDataVar;

  /* Start Varaibles */
  var store_requestBalanceType, store_requestBalanceTypeArray = ['آجل', 'كاش'];
  /* End Variables */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: asideMenu(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: MenuBar(),
      ),
      bottomNavigationBar: bottomBar(context),
      body: SingleChildScrollView(
          controller: scrolling.returnTheVariable(),
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 0), // (MediaQuery.of(context).size.height / 2)
            padding: const EdgeInsets.only(top: 0, bottom: 100, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "طلبات رصيدي",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(

                      onPressed: () async {
                        setState(() {
                          showLoading = true;
                        });
                        showLoadingFun(context);

                        await getBalanceRequestsData();

                        setState(() {
                          showLoading = false;
                        });
                        showLoadingFun(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
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
                      return balanceRequests.length != 0? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              showBottomBorder: true,
                              dividerThickness: 5.0,
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    'العدد',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'التاريخ',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'الحالة',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'المبلغ',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'نوع المبلغ عند الطلب',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'نوع المبلغ بعد الطلب',
                                    style: TextStyle(),
                                  ),
                                ),
                              ],
                              rows: balanceRequests.map((item) =>
                                  DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                            Container(
                                              child: Text((balanceRequests.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceRequest_date'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceRequest_status'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceRequest_amount'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceRequest_amountType'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceRequest_amountTypeEdit'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                      ]
                                  )
                              ).toList()
                          )
                      ):Container(
                        child: Text("لم تطلب رصيد بعد"),
                      );
                    }
                  },
                ),

                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(

                      onPressed: () async {
                        setState(() {
                          showLoading = true;
                        });
                        showLoadingFun(context);

                        await getBalanceRequestsData();

                        setState(() {
                          showLoading = false;
                        });
                        showLoadingFun(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

