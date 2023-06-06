// @dart=2.11

import 'dart:async';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:storeapp/view/dashboard/homePage.dart';

import '../main.dart';
import 'bottomBar.dart';


class asideMenu extends StatefulWidget {
  GlobalKey<NavigatorState> navigationKey;
 // String storeRoleFrontEnd;

  asideMenu({
    this.navigationKey,
   // this.storeRoleFrontEnd,
  });

  asideMenuState createState() => asideMenuState(navigationKey: navigationKey,);

}
class asideMenuState extends State {

  GlobalKey<NavigatorState> navigationKey;
  //String storeRoleFrontEnd;
  final GlobalKey _scaffoldkeyRetrieveBalance = new GlobalKey();
  asideMenuState({
    this.navigationKey,
 //   this.storeRoleFrontEnd,
  });

  @override
  void initState() {
    super.initState();

    /*stream.listen((value) async {
      print('Value from controller: $value');
      tahaHa = value;
      if (mounted) {
        print("yes yes");
        setState(() {
          tahaHa = value;
          print(tahaHa);

          storeRoleFrontEnd = tahaHa;
          tahaHa = tahaHa;


        });
      }
    });*/
  }

  var marginBetween = double.parse("20");
  
  Widget build(BuildContext context) {


    List MenuArray = [];
    // Balance
    var menu_balance_sectionValue = 'الرصيد';
    List<String> menu_balance_sectionArray = [];

    // Edit Products
    var menu_editProducts = GestureDetector(
      child: Visibility(
        child: Text("Gone"),
        visible: false,
      ),
    );

    // Add Edit Stores
    var menu_stores = GestureDetector(
      child: Visibility(
        child: Text("Gone"),
        visible: false,
      ),
    );

    // My Profit
    var menu_profit = GestureDetector(
      child: Visibility(
        child: Text("Gone"),
        visible: false,
      ),
    );


    // My Cards
    var menu_myCards = GestureDetector(
      child: Visibility(
        child: Text("Gone"),
        visible: false,
      ),
    );

    // Companies Categories
    var menu_companiesCategories = GestureDetector(
      child: Visibility(
        child: Text("Gone"),
        visible: false,
      ),
    );

    if (storeRoleFrontEnd == "مندوب") {

      MenuArray = [
        {
          "name": "لوحة التحكم",
          "route": "/HomePage"
        },
        {
          "name": "الطابعة",
          "route": "/printer"
        },
        {
          "name": "الرصيد",
          "route": ""
        },
        {
          "name": "تعديل المنتجات",
          "route": "/editproducts"
        },
        {
          "name": "محلاتي",
          "route": "/myStores"
        },
        {
          "name": "أرباحي",
          "route": "/profit"
        },
        {
          "name": "تسجيل الخروج",
          "route": "/logout"
        },
      ];

      menu_balance_sectionArray = ['الرصيد', 'طلبات الرصيد', 'سجل طلبات رصيدي'];

      menu_editProducts = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/editproducts');
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: marginBetween),
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0),
                    icon: Icon(Icons.receipt_outlined, size:16,),
                    onPressed: () => {},
                    constraints: BoxConstraints(),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 0)),
                Expanded(child: Text("تعديل المنتجات", style: TextStyle(fontSize:16,)),),
              ],
            ),
          )
      );


      menu_stores = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/myStores');
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: marginBetween),
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0),
                    icon: Icon(Icons.receipt_outlined, size:16,),
                    onPressed: () => {},
                    constraints: BoxConstraints(),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 0)),
                Expanded(child: Text("محلاتي", style: TextStyle(fontSize:16,)),),
              ],
            ),
          )
      );



      menu_profit = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profit');
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: marginBetween),
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0),
                    icon: Icon(Icons.receipt_outlined, size:16,),
                    onPressed: () => {},
                    constraints: BoxConstraints(),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 0)),
                Expanded(child: Text("أرباحي", style: TextStyle(fontSize:16,)),),
              ],
            ),
          )
      );


    } else {

      MenuArray = [
        {
          "name": "لوحة التحكم",
          "route": "/HomePage"
        },
        {
          "name": "الطابعة",
          "route": "/printer"
        },
        {
          "name": "الرصيد",
          "route": ""
        },
        {
          "name": "مشترياتي",
          "route": "/myCards"
        },
        {
          "name": "تصنيفات الشركات",
          "route": "/companiesCategories"
        },
        {
          "name": "تسجيل الخروج",
          "route": "/logout"
        },
      ];

      menu_balance_sectionArray = ['الرصيد', 'سجل طلبات رصيدي'];


      menu_myCards = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/myCards');
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: marginBetween),
                  child: IconButton(
                    padding: EdgeInsets.only(left: 0),
                    icon: Icon(Icons.receipt_outlined, size:16,),
                    onPressed: () => {},
                    constraints: BoxConstraints(),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 0)),
                Expanded(child: Text("مشترياتي", style: TextStyle(fontSize:16,)),),
              ],
            ),
          )
      );


      menu_companiesCategories = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/companiesCategories');
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.receipt_outlined, size:16,),
                  onPressed: () => {},
                  padding: EdgeInsets.only(left: marginBetween),
                  constraints: BoxConstraints(),
                ),
                Padding(padding: EdgeInsets.only(left: 0)),
                Expanded(child: Text("تصنيفات الشركات", style: TextStyle(fontSize:16,)),),
              ],
            ),
          )
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(

          child:  Container(
              color: Colors.white,
              child: Column(
                  children: [

                    Container(
                        padding: EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        height:170,
                        color: HexColor("#F65D12"),
                        child:Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Image.asset('assets/images/logoNav.png',fit: BoxFit.fitWidth,),
                              Text("مرحبا ",style: TextStyle(fontSize: 25,color: Colors.white),),
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: marginBetween, top: marginBetween),
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Column(
                            children:
                              MenuArray.map((item) {
                                return GestureDetector(
                                    onTap: () async {
                                      if (item['route'] == "/logout") {
                                        userinfoDatabase userInfo = new userinfoDatabase();
                                        var userLogout = await userInfo.deleteUserInfo();

                                        await FirebaseAuth.instance.signOut();
                                        GoogleSignIn _googleSignIn = GoogleSignIn(
                                          // Optional clientId
                                          // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
                                          scopes: <String>[
                                            'email',
                                            'https://www.googleapis.com/auth/contacts.readonly',
                                          ],
                                        );

                                        await _googleSignIn.signOut();
                                        storeRoleFrontEnd = "";

                                        Scaffold.of(context).openEndDrawer();
                                        streamMessages.add({
                                          "status": "logout"
                                        });
                                        storeRoleFrontEnd = "empty";
                                        Navigator.pushNamed(context, '/');
                                      } else {
                                        Navigator.pushNamed(context, item['route']);
                                        Scaffold.of(context).openEndDrawer();
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.white,
                                      //margin: EdgeInsets.only(bottom: 10,),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children:
                                          item['name'] == "الرصيد"? [
                                            Container(
                                              margin: EdgeInsets.only(left: marginBetween),
                                              child: IconButton(
                                                padding: EdgeInsets.only(left: 0),
                                                icon: Icon(Icons.receipt_outlined, size:16,),
                                                onPressed: () => {},
                                                constraints: BoxConstraints(),
                                              ),
                                            ),
                                            Expanded(child: DropdownButton<String>(
                                              isExpanded: true,
                                              key: _scaffoldkeyRetrieveBalance,
                                              //isExpanded: true,
                                              value: menu_balance_sectionValue,
                                              icon: const Icon(Icons.arrow_downward),
                                              iconSize: 24,
                                              elevation: 16,
                                              style: const TextStyle(color: Colors.deepPurple),
                                              underline: Container(
                                                height: 2,
                                                width: double.infinity,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                              onChanged: (newValue) async {
                                                if (newValue.toString() == "الرصيد") {
                                                  Navigator.pushNamed(context, '/balance');
                                                } else if (newValue.toString() == "طلبات الرصيد") {
                                                  Navigator.pushNamed(context, '/balanceRequests');
                                                } else if (newValue.toString() == "سجل طلبات رصيدي") {
                                                  Navigator.pushNamed(context, '/balanceRequestHistory');
                                                }

                                                //  Scaffold.of(context).openEndDrawer();
                                              },
                                              items: menu_balance_sectionArray
                                                  .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ))
                                          ]: [
                                          Container(
                                            margin: EdgeInsets.only(left: marginBetween),
                                            child: IconButton(
                                              padding: EdgeInsets.only(left: 0),
                                              icon: Icon(Icons.receipt_outlined, size:16,),
                                              onPressed: () => {},
                                              constraints: BoxConstraints(),
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.only(left: 0)),
                                          Expanded(child: Text(item["name"], style: TextStyle(fontSize:16,)),)
                                        ],
                                      )
                                )
                                );
                              }).toList(),

                              /*GestureDetector(
                                  onTap: () async {
                                    Navigator.pushNamed(context, '/HomePage');
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    //margin: EdgeInsets.only(bottom: 10,),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(left: marginBetween),
                                          child: IconButton(
                                            padding: EdgeInsets.only(left: 0),
                                            icon: Icon(Icons.receipt_outlined, size:16,),
                                            onPressed: () => {},
                                            constraints: BoxConstraints(),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 0)),
                                        Expanded(child: Text("لوحة التحكم", style: TextStyle(fontSize:16,)),)
                                      ],
                                    ),
                                  )
                              ),

                              GestureDetector(
                                  onTap: () async {
                                    Navigator.pushNamed(context, '/printer');
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    //margin: EdgeInsets.only(bottom: 10,),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(left: marginBetween),
                                          child: IconButton(
                                            padding: EdgeInsets.only(left: 0),
                                            icon: Icon(Icons.receipt_outlined, size:16,),
                                            onPressed: () => {},
                                            constraints: BoxConstraints(),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 0)),
                                        Expanded(child: Text("الطابعة", style: TextStyle(fontSize:16,)),),
                                      ],
                                    ),
                                  )
                              ),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(),
                                //margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: marginBetween),
                                      child: IconButton(
                                        padding: EdgeInsets.only(left: 0),
                                        icon: Icon(Icons.receipt_outlined, size:16,),
                                        onPressed: () => {},
                                        constraints: BoxConstraints(),
                                      ),
                                    ),


                                    Expanded(child: DropdownButton<String>(
                                      isExpanded: true,
                                      key: _scaffoldkeyRetrieveBalance,
                                      //isExpanded: true,
                                      value: menu_balance_sectionValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: const TextStyle(color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        width: double.infinity,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (newValue) async {
                                        if (newValue.toString() == "الرصيد") {
                                          Navigator.pushNamed(context, '/balance');
                                        } else if (newValue.toString() == "طلبات الرصيد") {
                                          Navigator.pushNamed(context, '/balanceRequests');
                                        } else if (newValue.toString() == "سجل طلبات رصيدي") {
                                          Navigator.pushNamed(context, '/balanceRequestHistory');
                                        }

                                        //  Scaffold.of(context).openEndDrawer();
                                      },
                                      items: menu_balance_sectionArray
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    )),
                                  ],
                                ),

                              ),

                              menu_editProducts,

                              menu_stores,

                              menu_profit,

                              menu_myCards,

                              menu_companiesCategories,

                              GestureDetector(
                                  onTap: () async {
                                    userinfoDatabase userInfo = new userinfoDatabase();
                                    var userLogout = await userInfo.deleteUserInfo();

                                    await FirebaseAuth.instance.signOut();
                                    storeRoleFrontEnd = "";

                                    Scaffold.of(context).openEndDrawer();
                                    streamMessages.add({
                                      "status": "logout"
                                    });
                                    storeRoleFrontEnd = "empty";
                                    Navigator.pushNamed(context, '/');
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(left: marginBetween),
                                          child: IconButton(
                                            padding: EdgeInsets.only(left: 0),
                                            icon: Icon(Icons.receipt_outlined, size:16,),
                                            onPressed: () => {},
                                            constraints: BoxConstraints(),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 0)),
                                        Expanded(child: Text("تسجيل الخروج", style: TextStyle(fontSize:16,)),),
                                      ],
                                    ),
                                  )
                              ),*/


                        )
                    )
                  ]
              )
          )
      ),
    );
  }

}



