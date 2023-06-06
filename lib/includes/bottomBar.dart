import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:storeapp/model/companiesClass.dart';

int selectedIndex = 0;

var bottomBarIcons = [
  Icon(Icons.home_outlined, size: 30, color: Colors.white,),
  Icon(Icons.location_city, size: 30, color: Colors.white,),
  Icon(Icons.card_travel_sharp, size: 30, color: Colors.white,),
  Icon(Icons.message, size: 30, color: Colors.white,),
];

Widget bottomBar(context)  {



  GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey();
  return CurvedNavigationBar(
    animationDuration: Duration(milliseconds: 300),
    color: HexColor("#F65D12"),
    buttonBackgroundColor: HexColor("#F65D12"),
    backgroundColor: Colors.white,
    height: 50,
    index: selectedIndex,
    key: bottomNavigationKey,
    items: bottomBarIcons,
    onTap: (index) {
      selectedIndex = index;

      switch (index) {
        case 0:
          Timer(Duration(milliseconds: 100), () {
            Navigator.pushNamed(context, '/HomePage');
          });

          break;

        case 1:
          Timer(Duration(milliseconds: 100), () {
            Navigator.pushNamed(context, '/companies', arguments: companiesClass(companyCategoryId: "", companyCategoryName : ""));
          });
          break;

        case 2:
          Timer(Duration(milliseconds: 100), () {
            Navigator.pushNamed(context, '/myCards',);
          });
          break;

        case 3:
         /* Timer(Duration(milliseconds: 100), () {

          });*/
          break;
      }
    },
  );
}