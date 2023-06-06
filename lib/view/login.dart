// @dart=2.11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/model/loginAuthClass.dart';

import '../database/userinfoDatabase.dart';
import '../main.dart';
import 'colors.dart';           // new


class loginPage extends StatefulWidget {
  LogInState createState() => LogInState();

}

class LogInState extends State  {

  ScrollToTop scrolling = ScrollToTop();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String countryCode = "+966";
  final  phoneNumber = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  checkIfPhoneNumberIsAdminandMakeValidation () async {

    if (phoneNumber.text == "") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("أدخل رقم الهاتف "),
        duration: Duration(seconds: 5),
      ));
    } else {
      var checkStore = "storeNotFound";
      var getStore = await FirebaseFirestore.instance
          .collection('storesInfo')
          .where("store_phoneNumber", isEqualTo: countryCode + phoneNumber.text)
          .get()
          .catchError((e) {

          });

      for (var i = 0; i < getStore.docs.length; i = i + 1) {
        print(getStore.docs[0].get("store_status"));
        if (getStore.docs[i].get("store_status") == "true") {

          /*var storeData = await FirebaseFirestore.instance
              .collection('stores')
              .doc(getStore.docs[i].id)
              .get()
              .catchError((e) {
          });*/

          checkStore = '';
          Navigator.pushNamed(context, '/loginAuthentication', arguments: loginAuthClass(countryCode: countryCode, phoneNumber: phoneNumber.text, storeId: getStore.docs[i].id, storeRole: ""));

          break;
        } else {
          checkStore = 'storeNotActive';
        }
      }

      if (checkStore == "storeNotFound") {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("المتجر غير مسجل"),
          duration: Duration(seconds: 5),
        ));
      } else if (checkStore == "storeNotActive") {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("المتجر غير فعال"),
          duration: Duration(seconds: 5),
        ));
      }
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>[
      'email',
     // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _handleSignIn() async {
    try {
      googleSignInAccount =
      await _googleSignIn.signIn();


    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();


  GoogleSignInAuthentication googleSignInAuthentication;
  GoogleSignInAccount googleSignInAccount;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {

      print("this is account");
      print(account);

      signInWithGoogleToFireBase(account);




      // setState(() {
      //   _currentUser = account;
      // });
      // if (_currentUser != null) {
      //   //_handleGetContact(_currentUser!);
      // }
    });
    _googleSignIn.signInSilently();
  }

  signInWithGoogleToFireBase (GoogleSignInAccount account) async {

    if (googleSignInAccount != null) {
      googleSignInAuthentication =
      await googleSignInAccount.authentication;
    }


    print(googleSignInAuthentication);

    if (googleSignInAuthentication != null) {
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      /*print("hello work");
      print(credential);*/
      
      var checkStore = "storeNotFound";
      var getStore = await FirebaseFirestore.instance
          .collection('storesInfo')
          .where("store_email", isEqualTo: account.email)
          .get();

      if (getStore.docs.length != 0) {
        await _auth.signInWithCredential(credential);
      }

      for (var i = 0; i < getStore.docs.length; i = i + 1) {
        print(getStore.docs[0].get("store_status"));
        if (getStore.docs[i].get("store_status") == "true") {

          checkStore = '';
          //Navigator.pushNamed(context, '/loginAuthentication', arguments: loginAuthClass(countryCode: countryCode, phoneNumber: phoneNumber.text, storeId: getStore.docs[i].id, storeRole: ""));

          userinfoDatabase userDatabase = userinfoDatabase();
          var checkIfLoggedIn = await userDatabase.checkIfLoggedIn(phonenumberParameter: getStore.docs[i].get("store_phoneNumber"));
          if (checkIfLoggedIn != "empty") {
            myBalance = checkIfLoggedIn["data"];
            // balanceController balance = new balanceController();
            // myBalance = await balance.getMyBalance();

            User user = FirebaseAuth.instance.currentUser;
            await userDatabase.updateUserInfo(token: user.uid, phonenumber: getStore.docs[i].get("store_phoneNumber"), storeId: getStore.docs[i].id, storeRole: checkIfLoggedIn["storeRole"]);

            storeRoleFrontEnd = checkIfLoggedIn["storeRole"];

            // Update Top Bar

            Navigator.pushNamed(context, '/HomePage');
          } else {
            Navigator.pushNamed(context, '/');
          }
          
          break;
        } else {
          checkStore = 'storeNotActive';
        }
      }

      if (checkStore == "storeNotFound") {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("المتجر غير مسجل"),
          duration: Duration(seconds: 5),
        ));
      } else if (checkStore == "storeNotActive") {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("المتجر غير فعال"),
          duration: Duration(seconds: 5),
        ));
      }
    }


  }

  var textDirection = {
    "phoneNumberTextDirection": TextDirection.rtl,
  };

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      //drawer: SideDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MenuBar(),
      ),
      //bottomNavigationBar: createBottomNavigationBar(context),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 60),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20,),
                  alignment: Alignment.center,
                  child: Image.asset("assets/images/user.png", width: 120, height: 120, fit: BoxFit.cover,),
                ),

               /* Container(
                  margin: EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  child: CountryCodePicker(
                    padding: EdgeInsets.all(0),
                    onChanged: (country) {
                      setState(() {
                        countryCode = country.dialCode;
                      });
                    },
                    initialSelection: "US",
                    showCountryOnly: false,
                    alignLeft: true,
                    showOnlyCountryWhenClosed: false,
                    favorite: ["+1", "US", "SA","+961"],
                  ),
                ),*/

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    autofocus: false,
                    controller: phoneNumber,
                    textDirection: textDirection['phoneNumberTextDirection'],
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]+'))],
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الهاتف',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 7.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    style: TextStyle(fontSize: 14,),
                    onChanged: (val) {
                      RegExp exp = RegExp("[0-9]");

                      if (val.isNotEmpty) {
                        if(exp.hasMatch(val.substring(val.length-1)) && val.substring(val.length-1) != " "){
                          setState(() {
                            textDirection['phoneNumberTextDirection'] = TextDirection.ltr;
                          });
                        } else if(val.substring(val.length-1) != " " && !exp.hasMatch(val.substring(val.length-1))){
                          setState(() {
                            textDirection['phoneNumberTextDirection'] = TextDirection.rtl;
                          });
                        }
                      } else {
                        textDirection['phoneNumberTextDirection'] = TextDirection.rtl;
                      }

                    },
                  ),
                ),


                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onPressed: () {
                      checkIfPhoneNumberIsAdminandMakeValidation();
                    },
                    padding: EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 7.0),
                    color: Colors.blue,
                    child: Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 14,)),
                  ),
                ),


                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onPressed: () async {
                      await signOutFromGoogle();
                      await _handleSignIn();

                    },
                    padding: EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 7.0),
                    color: Colors.blue,
                    child: Image.asset("assets/images/googleLogin.jpg", width: double.infinity, fit: BoxFit.cover,),
                  ),
                ),
              ],
            ),
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

