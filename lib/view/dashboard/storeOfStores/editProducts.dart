// @dart=2.11


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/actions/validateInputs.dart';
import 'package:storeapp/actions/validateInputs.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/controller/editProducts.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

class editProducts extends StatefulWidget {
  editProductsState createState() => editProductsState();
}

class editProductsState extends State  {

  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  inputValidator validateInput = new inputValidator();

  @override
  void initState() {
    super.initState();

    getTheDataVar = getProductsForEdit();
  }

  final formGlobalKey = GlobalKey<FormState>();

  List displayData_allNotChanged = [];

  final cardSearch = TextEditingController();
  var dropdownProductsSearch = '';
  List<String> dropdownProductsDataSearch = [''];

  var dropdownCompaniesSearch = '';
  List<String> dropdownCompaniesDataSearch = [''];

  List dropdownCompaniesDataAll = [];
  List dropdownProductsDataAll = [];

  /* Get Edit Products Data */
  List editProductsData = [];
  getProductsForEdit () async {
    editProductsController EditProducts = new editProductsController();
    var EditProductsFun = await EditProducts.getProductsStoreOfStores();

    for (var i = 0; i < EditProductsFun.length; i = i + 1) {
      dropdownProductsDataSearch.add(EditProductsFun[i]["product_name"]);
      dropdownCompaniesDataSearch.add(EditProductsFun[i]["product_companyName"]);
      dropdownCompaniesDataAll.add({
        "companies_name": EditProductsFun[i]["product_companyName"],
        "product_name": EditProductsFun[i]["product_name"],
        "companyId": EditProductsFun[i]["product_companyId"],
      });
      dropdownProductsDataAll.add({
        "companies_name": EditProductsFun[i]["product_companyName"],
        "product_name": EditProductsFun[i]["product_name"],
        "companyId": EditProductsFun[i]["product_companyId"],
      });
    }

    setState(() {
    //  dropdownProductsDataSearch = dropdownProductsDataSearch.toSet().toList();
      dropdownCompaniesDataSearch = dropdownCompaniesDataSearch.toSet().toList();
      dropdownProductsSearch = dropdownProductsDataSearch[0];
      dropdownCompaniesSearch = dropdownCompaniesDataSearch[0];

      editProductsData = EditProductsFun;
      displayData_allNotChanged = EditProductsFun;
    });

    return EditProductsFun;
  }

  /* Get Products For Specific Company */
  getProductsForSpecificCompany () async {
    setState(() {
      dropdownProductsDataSearch = [''];
      for (var i = 0; i < dropdownCompaniesDataAll.length; i = i + 1) {
        if (dropdownCompaniesSearch == dropdownCompaniesDataAll[i]["companies_name"]) {
          dropdownProductsDataSearch.add(dropdownCompaniesDataAll[i]['product_name']);
        }
      }
      dropdownProductsSearch = dropdownProductsDataSearch[0];
    });
  }

  final groupOne = TextEditingController();
  final groupTwo = TextEditingController();
  final groupThree = TextEditingController();
  final groupFour = TextEditingController();

  Future getTheDataVar;

  /* Edit */
  addOrEditPrices(BuildContext context, index) {

    setState(() {
      groupOne.text = editProductsData[index]['storesOfStoresPricesDifference_groupOne'];
      groupTwo.text = editProductsData[index]['storesOfStoresPricesDifference_groupTwo'];
      groupThree.text = editProductsData[index]['storesOfStoresPricesDifference_groupThree'];
      groupFour.text = editProductsData[index]['storesOfStoresPricesDifference_groupFour'];
    });

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("تعديل"),
      onPressed:  () async {

        if (formGlobalKey.currentState.validate()) {
          formGlobalKey.currentState.save();
          // use the email provided here
        } else {
          return;
        }


          editProductsController EditProducts = new editProductsController(
            editProducts_id: editProductsData[index]['docid'],
            editProducts_storesOfStoresPricesDifference_groupOne: groupOne.text,
            editProducts_storesOfStoresPricesDifference_groupTwo: groupTwo.text,
            editProducts_storesOfStoresPricesDifference_groupThree: groupThree.text,
            editProducts_storesOfStoresPricesDifference_groupFour: groupFour.text,
            editProducts_storesOfStoresPricesDifferenceId: editProductsData[index]['storesOfStoresPricesDifference_id'],
          );

          var pricesAddEdit = await EditProducts.addStoreOfStoresPrices();

          if (pricesAddEdit['status'] == "addedOrEdited") {

            setState(() {
              if (pricesAddEdit['docid'] != "") {
                editProductsData[index]['storesOfStoresPricesDifference_id'] = pricesAddEdit['docid'];
              }

              editProductsData[index]['storesOfStoresPricesDifference_groupOne'] = groupOne.text;
              editProductsData[index]['storesOfStoresPricesDifference_groupTwo'] = groupTwo.text;
              editProductsData[index]['storesOfStoresPricesDifference_groupThree'] = groupThree.text;
              editProductsData[index]['storesOfStoresPricesDifference_groupFour'] = groupFour.text;
            });
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("تم التعديل جاري التحديث"),
              duration: Duration(seconds: 5),
            ));
            Navigator.pop(context);
          }



      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("إضافة أسعار"),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Column(
                  children: [

                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                          "أضف أربعة أسعار",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          textAlign: TextAlign.right
                      ),
                    ),

                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 0),
                      child: Text(
                          "إسم المنتج: " + editProductsData[index]['product_name'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(bottom: 30),
                      child: Text(
                          "السعر: " + editProductsData[index]['product_price'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right
                      ),
                    ),

                    Form(
                      key: formGlobalKey,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                                "سعر واحد",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              autofocus: false,
                              controller: groupOne,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                              //initialValue: '',
                              decoration: InputDecoration(
                                hintText: 'السعر الأول',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                              ),
                              validator: (val)  {
                                var check = validateInput.validatePrice(val);
                                return check;
                              },
                            ),
                          ),



                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                                "سعر ثاني",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                              autofocus: false,
                              textDirection: TextDirection.ltr,
                              controller: groupTwo,
                              //initialValue: '',
                              decoration: InputDecoration(
                                hintText: 'السعر الثاني',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                              ),
                              validator: (val)  {
                                var check = validateInput.validatePrice(val);
                                return check;
                              }
                            ),
                          ),






                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                                "سعر ثالث",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                              autofocus: false,
                              controller: groupThree,
                              textDirection: TextDirection.ltr,
                              //initialValue: '',
                              decoration: InputDecoration(
                                hintText: 'السعر الثالث',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                              ),
                              validator: (val)  {
                                var check = validateInput.validatePrice(val);
                                return check;
                              }
                            ),
                          ),





                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                                "سعر رابع",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                              textDirection: TextDirection.ltr,
                              autofocus: false,
                              controller: groupFour,
                              //initialValue: '',
                              decoration: InputDecoration(
                                hintText: 'السعر الرابع',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                              ),
                              validator: (val)  {
                                var check = validateInput.validatePrice(val);
                                return check;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),



                  ],
                ));
          }),

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
            padding: const EdgeInsets.only(top: 0, bottom: 100, left: 10, right: 10),
            child: Column(
              children: [

                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "تعديل المنتجات",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
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
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                controller: cardSearch,
                                onChanged: (value) {
                                  var results = [];
                                  if (value.isEmpty) {
                                    // if the search field is empty or only contains white-space, we'll display all users
                                    results = displayData_allNotChanged;

                                    if (dropdownCompaniesSearch != "") {
                                      results = results
                                          .where((doc) =>
                                          doc.toString().toLowerCase().contains(dropdownCompaniesSearch.toLowerCase()))
                                          .toList();
                                    }

                                    if (dropdownProductsSearch != "") {
                                      results = results
                                          .where((doc) =>
                                          doc.toString().toLowerCase().contains(dropdownProductsSearch.toLowerCase()))
                                          .toList();
                                    }
                                  } else {
                                    results = displayData_allNotChanged
                                        .where((doc) =>
                                        doc.toString().toLowerCase().contains(value.toLowerCase()))
                                        .toList();

                                    if (dropdownCompaniesSearch != "") {
                                      results = results
                                          .where((doc) =>
                                          doc.toString().toLowerCase().contains(dropdownCompaniesSearch.toLowerCase()))
                                          .toList();
                                    }

                                    if (dropdownProductsSearch != "") {
                                      results = results
                                          .where((doc) =>
                                          doc.toString().toLowerCase().contains(dropdownProductsSearch.toLowerCase()))
                                          .toList();
                                    }
                                  }


                                  // Refresh the UI
                                  setState(() {
                                    editProductsData = results;
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
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topRight,
                                        margin: EdgeInsets.only(top: 20, bottom: 10),
                                        child: Text(
                                            "إختار شركة",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            textAlign: TextAlign.right
                                        ),
                                      ),
                                      Container(
                                        //width: do,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: dropdownCompaniesSearch,
                                          icon: const Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: const TextStyle(color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            width: double.infinity,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String value) async {

                                            setState(() {
                                              dropdownCompaniesSearch = value;
                                            });

                                            await getProductsForSpecificCompany();

                                            var results = [];

                                            if (value == "") {
                                              // if the search field is empty or only contains white-space, we'll display all users
                                              results = displayData_allNotChanged;

                                            } else {
                                              // My Companies
                                              results = displayData_allNotChanged
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(value.toLowerCase()))
                                                  .toList();
                                            }

                                            if (dropdownProductsSearch != "") {
                                              // My Products
                                              results = results
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(dropdownProductsSearch.toLowerCase()))
                                                  .toList();
                                            }

                                            if (cardSearch != "") {
                                              results = results
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(cardSearch.text.toLowerCase()))
                                                  .toList();
                                            }

                                            // Refresh the UI
                                            setState(() {
                                              editProductsData = results;
                                            });


                                          },
                                          items: dropdownCompaniesDataSearch
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: 20,
                                ),

                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topRight,
                                        margin: EdgeInsets.only(top: 20, bottom: 10),
                                        child: Text(
                                            "إختار منتج",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            textAlign: TextAlign.right
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: dropdownProductsSearch,
                                          icon: const Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: const TextStyle(color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            width: double.infinity,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String value) async {

                                            var results = [];
                                            if (value == "") {
                                              // if the search field is empty or only contains white-space, we'll display all users
                                              results = displayData_allNotChanged;
                                            } else {
                                              // My Products
                                              results = displayData_allNotChanged
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(value.toLowerCase()))
                                                  .toList();
                                            }

                                            if (dropdownCompaniesSearch != "") {
                                              results = results
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(dropdownCompaniesSearch.toLowerCase()))
                                                  .toList();
                                            }

                                            if (dropdownCompaniesSearch != "") {
                                              // My Companies
                                              results = results
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(dropdownCompaniesSearch.toLowerCase()))
                                                  .toList();
                                            }

                                            if (cardSearch != "") {
                                              results = results
                                                  .where((doc) =>
                                                  doc.toString().toLowerCase().contains(cardSearch.text.toLowerCase()))
                                                  .toList();
                                            }
                                            // Refresh the UI
                                            setState(() {
                                              editProductsData = results;
                                            });
                                            setState(() {
                                              dropdownProductsSearch = value;
                                            });

                                          },
                                          items: dropdownProductsDataSearch
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),


                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  showBottomBorder: true,
                                  dividerThickness: 5.0,
                                  dataRowHeight: 100,
                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: Text(
                                        'العدد',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'إسم المنتج',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'صورة المنتج',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'إسم الشركة',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'سعر المنتج',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'السعر الأول',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'السعر الثاني',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'السعر الثالث',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'السعر الرابع',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'إضافة أسعاري',
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ],
                                  rows: editProductsData.map((item) =>
                                      DataRow(
                                          cells: <DataCell>[
                                            DataCell(
                                                Container(
                                                  child: Text((editProductsData.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['product_name'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Image.network(
                                                    item["product_image"],
                                                    fit: BoxFit.fill,
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 100,
                                                  height: 300,
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['product_companyName'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['product_price'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['storesOfStoresPricesDifference_groupOne'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['storesOfStoresPricesDifference_groupTwo'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['storesOfStoresPricesDifference_groupThree'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Text(item['storesOfStoresPricesDifference_groupFour'].toString(), textScaleFactor: 1,),
                                                  padding: EdgeInsets.all(5),
                                                )
                                            ),
                                            DataCell(
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      TextButton.icon(
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: Colors.blueAccent,
                                                          ),
                                                          onPressed: () {
                                                            addOrEditPrices(context, editProductsData.indexOf(item));
                                                          },
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                            size: 12,
                                                          ),
                                                          label: Text("إضافة أسعار", style: TextStyle(color: Colors.white, fontSize: 12),)
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

                          ),
                        ],
                      );
                    }
                  },
                ),

              ],
            ),
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

