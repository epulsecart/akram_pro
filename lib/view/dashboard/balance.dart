// @dart=2.11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/actions/validateInputs.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

import '../colors.dart';

class balance extends StatefulWidget {
  balanceHisotry createState() => balanceHisotry();
}

class balanceHisotry extends State  {

  ScrollToTop scrolling = ScrollToTop();
  var showLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final balanceSearch = TextEditingController();
  List displayData_allNotChanged = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  inputValidator validateInput = new inputValidator();
  final formGlobalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getTheDataVarHistory = getBalanceHistoryData();
    getTheDataVar = getMyBalanceFun();

    store_requestBalanceType = store_requestBalanceTypeArray[0];
  }

  Future getTheDataVar, getTheDataVarHistory;

  /* Get My Balance */
  var getMyBalance = {
    "store_debtBalance": "",
    "store_cashBalance": "",
    "store_indebtedness": "",
    "store_totalBalance": "",
    "stores_indebtedness": "",
  };
  getMyBalanceFun () async {
    balanceController balanceClass = new balanceController(stores_indebtedness: "true");
    var myBalance = await balanceClass.getMyBalance();

    setState(() {
      getMyBalance = {
        "store_debtBalance": myBalance['store_debtBalance'],
        "store_cashBalance": myBalance['store_cashBalance'],
        "store_indebtedness": myBalance['store_indebtedness'],
        "store_totalBalance": myBalance['store_totalBalance'],
        "stores_indebtedness": myBalance['stores_indebtedness'],
      };
    });

    return myBalance;
  }
  balanceController balanceClass = new balanceController();
  /* Get Data */
  List balanceHistory = [];
  getBalanceHistoryData () async {

    var balanceHistoryFun = await balanceClass.getBalanceHistory();

    setState(() {
      balanceHistory = balanceHistoryFun;
      displayData_allNotChanged = balanceHistoryFun;
    });

    return balanceHistoryFun;
  }

  /* Start Varaibles */
  final store_requestBalance = TextEditingController();
  var store_requestBalanceType, store_requestBalanceTypeArray = ['آجل', 'كاش'];
  /* End Variables */

  /* Start Request Balance */
  /* Delete Category */
  requestBalance(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("طلب"),
      onPressed:  () async {
        setState(() {
          showLoading = true;
        });
        showLoadingFun(context);

        if (formGlobalKey.currentState.validate()) {
          formGlobalKey.currentState.save();
          // use the email provided here
        } else {
          Navigator.pop(context);
          return;
        }


        balanceController storeClass = new balanceController(balance_RequestAmount: store_requestBalance.text, balance_RequestAmountType: store_requestBalanceType);
        var requestBalance = await storeClass.requestBalance();

        if (requestBalance == "requested") {
          setState(() {
            store_requestBalance.text = "";
          });
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("تم الطلب"),
            duration: Duration(seconds: 2),
          ));
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("طلب رصيد"),
      content: Text("هل أنت متأكد؟"),
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
  /* End Request Balance */

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
                      return Column(
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text("الرصيد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(getMyBalance['store_totalBalance'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text("المديونية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(getMyBalance['store_indebtedness'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                            ),
                          ),

                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text("الرصيد الكاش", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(getMyBalance['store_cashBalance'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text("الرصيد الآجل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(getMyBalance['store_debtBalance'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                            ),
                          ),


                          getMyBalance['stores_indebtedness'] != ""?Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text("مجموع المديونيات", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(getMyBalance['stores_indebtedness'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                            ),
                          ):Text(""),
                        ],
                      );
                    }
                  },
                ),





                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "طلب الرصيد",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                Form(
                  key: formGlobalKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          controller: store_requestBalance,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                          //initialValue: '',
                          decoration: InputDecoration(
                            hintText: 'السعر',
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                          ),
                          validator: (val)  {
                            var check = validateInput.validatePrice(val);

                            if (val.length < 1) {
                              return "أضف سعر";
                            }
                            return check;
                          },
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
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text('طلب رصيد', style: TextStyle(color: Colors.white,), ),
                            color: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),

                            onPressed: () async {
                              await requestBalance(context);
                            },
                          )
                      ),
                    ],
                  ),
                ),


                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "سجل الرصيد",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      controller: balanceSearch,
                      onChanged: (value) {
                        var results = [];
                        if (value.isEmpty) {
                          // if the search field is empty or only contains white-space, we'll display all users
                          results = displayData_allNotChanged;
                        } else {
                          results = displayData_allNotChanged
                              .where((doc) =>
                              doc.toString().toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }


                        // Refresh the UI
                        setState(() {
                          balanceHistory = results;
                        });
                      },
                      //initialValue: '',
                      decoration: InputDecoration(
                        hintText: 'إبحث',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      )
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

                        await getBalanceHistoryData();

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
                  future: getTheDataVarHistory,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == false) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 5, top: 50),
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
                                    'المبلغ المرسل',
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
                                    'إسم المحل المرسل إليه',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ الكاش قبل الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ الكاش بعد الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ الآجل قبل الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ الآجل بعد الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ المديونية قبل الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'مبلغ المديونية بعد الإرسال',
                                    style: TextStyle(),
                                  ),
                                ),
                              ],
                              rows: balanceHistory.map((item) =>
                                  DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                            Container(
                                              child: Text((balanceHistory.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_date'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_addPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_priceType'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_receiverName'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_beforeCashPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_afterCashPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_beforeDebtPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_afterDebtPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_BeforeIndebtednessPrice'].toString(), textScaleFactor: 1,),
                                              padding: EdgeInsets.all(5),
                                            )
                                        ),
                                        DataCell(
                                            Container(
                                              child: Text(item['balanceHistory_AfterIndebtednessPrice'].toString(), textScaleFactor: 1,),
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

                        await getBalanceHistoryData();

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

