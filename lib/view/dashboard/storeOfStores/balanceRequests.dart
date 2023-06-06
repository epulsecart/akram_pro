// @dart=2.11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/myStores.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

import '../../../main.dart';

class balanceRequest extends StatefulWidget {
  balanceRequestState createState() => balanceRequestState();
}

class balanceRequestState extends State  {

  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyBalance = new GlobalKey<ScaffoldState>();

  /* Start Variables */
  var showLoading = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getTheDataVar = getBalanceRequestsData();
  }
  var getTheDataVar;

  storesController balanceClass = new storesController();
  /* Get Data */
  List balanceRequests = [];
  getBalanceRequestsData () async {

    var balanceRequestsFun = await balanceClass.getBalanceRequests();

    setState(() {
      balanceRequests = balanceRequestsFun;
    });

    return balanceRequestsFun;
  }

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

  /* Start Varaibles */
  var store_requestBalanceType, store_requestBalanceTypeArray = ['آجل', 'كاش'];
  /* End Variables */

  /* Start Accept Or Not Balance */
  editAndAcceptBalance(BuildContext context, index) {

    setState(() {
      showLoading = true;
    });
    showLoadingFun(context);

    bool sureOrNot = false;
    setState(() {
      store_requestBalanceType = balanceRequests[index]['balanceRequest_amountType'];
    });

    setState(() {
      showLoading = false;
    });
    showLoadingFun(context);


    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("موافقة"),
      onPressed:  () async {

        if (sureOrNot) {
          setState(() {
            showLoading = true;
          });
          showLoadingFun(context);

          storesController storesClass = new storesController(
              store_id: balanceRequests[index]['storeId'],
              store_balaneRequestUpdateId: balanceRequests[index]['docid'],
              store_addBalance: balanceRequests[index]['balanceRequest_amount'],
              store_priceType: store_requestBalanceType,
              store_updateBalanceRequest: true,
              store_addDepthBalance: "",
          );

          var requestBalance = await storesClass.addBalance();

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
          if (requestBalance['status'] == "accepted") {
            setState(() {
              balanceRequests[index]['balanceRequest_status'] = "تمت الموافقة";
              balanceRequests[index]['balanceRequest_status_check'] = false;
            });

            setState(() {
              myBalance["store_totalBalance"] = (double.parse(myBalance["store_totalBalance"]) - double.parse(balanceRequests[index]['balanceRequest_amount'])).toString();
            });
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("تمت الموافقة وتم تحديث الرصيد"),
              duration: Duration(seconds: 5),
            ));
            Navigator.pop(context);
          } else if (requestBalance['status'] == "noAvailableBalance") {
            _scaffoldKeyBalance.currentState.showSnackBar(SnackBar(
              content: Text("لايوجد رصيد كافي"),
              duration: Duration(seconds: 5),
            ));
          } else if (requestBalance["status"] == "wrongBalanceUpdatedId") {
            _scaffoldKeyBalance.currentState.showSnackBar(SnackBar(
              content: Text("حدث خطأ ما"),
              duration: Duration(seconds: 5),
            ));
          }
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("موافقة على الطلب"),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              key: _scaffoldKeyBalance,
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                          "المبلغ: " + balanceRequests[index]['balanceRequest_amount'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right
                      ),
                    ),

                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                          "تعديل نوع الرصيد",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: store_requestBalanceType,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          width: double.infinity,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String newValue) async {
                          setState(() {
                            store_requestBalanceType = newValue;
                          });


                        },
                        items: store_requestBalanceTypeArray
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),



                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                          "هل أنت متأكد؟",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.right
                      ),
                    ),

                    Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row (
                          children: [
                            Checkbox(
                              value: sureOrNot,
                              onChanged: (bool value) {
                                setState(() {
                                  sureOrNot = value;
                                });
                              },
                            ),
                            Text("نعم")
                          ],
                        )
                    ),



                  ],
                ),
              ),
            );
          }
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // StatefulBuilder
          builder: (context, setState) {
            return alert;
          },
        );
      },
    );
  }
  /* End Request Balance */

  /* Start Reject Balance */
  rejectBalance(BuildContext context, index) {

    setState(() {
      showLoading = true;
    });
    showLoadingFun(context);

    bool sureOrNot = false;
    setState(() {
      store_requestBalanceType = balanceRequests[index]['balanceRequest_amountType'];
    });

    setState(() {
      showLoading = false;
    });
    showLoadingFun(context);


    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("رفض"),
      onPressed:  () async {

        if (sureOrNot) {
          setState(() {
            showLoading = true;
          });
          showLoadingFun(context);

          storesController storesClass = new storesController(
            store_id: balanceRequests[index]['storeId'],
            store_balaneRequestUpdateId: balanceRequests[index]['docid'],
            store_addDepthBalance: "",
          );

          var requestBalance = await storesClass.rejectBalance();

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
          if (requestBalance['status'] == "rejected") {
            setState(() {
              balanceRequests[index]['balanceRequest_status'] = "تم الرفض";
              balanceRequests[index]['balanceRequest_status_check'] = false;
            });
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("تم الرفض"),
              duration: Duration(seconds: 5),
            ));
            Navigator.pop(context);
          } else if (requestBalance["status"] == "wrongBalanceUpdatedId") {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("حدث خطأ ما"),
              duration: Duration(seconds: 5),
            ));
          }
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("رفض"),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                        "المبلغ: " + balanceRequests[index]['balanceRequest_amount'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.right
                    ),
                  ),

                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                        "هل أنت متأكد؟",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.right
                    ),
                  ),

                  Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row (
                        children: [
                          Checkbox(
                            value: sureOrNot,
                            onChanged: (bool value) {
                              setState(() {
                                sureOrNot = value;
                              });
                            },
                          ),
                          Text("نعم")
                        ],
                      )
                  ),



                ],
              ),
            );
          }
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  /* End Reject Balance */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: asideMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: MenuBar(),
      ),
      bottomNavigationBar: bottomBar(context),
      body: SingleChildScrollView(
          controller: scrolling.returnTheVariable(),
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 0), // (MediaQuery.of(context).size.height / 2)
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "طلبات الرصيد",
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
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return SingleChildScrollView(
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
                                    'نوع المبلغ',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'إسم المتجر',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'موافقة',
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
                                              child: Text(item['balanceRequest_store_name'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Row(
                                                children: [
                                                  item['balanceRequest_status_check'] == true ?
                                                  TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.blueAccent,
                                                      ),
                                                      onPressed: () {
                                                        editAndAcceptBalance(context, balanceRequests.indexOf(item));
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                      label: Text("تعديل وموافقة", style: TextStyle(color: Colors.white, fontSize: 12),)
                                                  ): Text(''),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  item['balanceRequest_status_check'] == true ?
                                                  TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        rejectBalance(context, balanceRequests.indexOf(item));
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                      label: Text("رفض", style: TextStyle(color: Colors.white, fontSize: 12),)
                                                  ): Text(''),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                      ]
                                  )
                              ).toList()
                          )

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

