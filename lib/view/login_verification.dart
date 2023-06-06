// @dart=2.11
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:storeapp/includes/appBar.dart';

import '../main.dart';
import 'colors.dart';

class loginVerification extends StatefulWidget{

  final String countryCode;
  final String phoneNumber;
  final String storeId;
  final String storeRole;

  loginVerification({
     this.countryCode,
     this.phoneNumber,
     this.storeId,
     this.storeRole,
  });



  @override
  loginVerificationState createState() => loginVerificationState(countryCode: this.countryCode, phoneNumber: this.phoneNumber, storeId: this.storeId, storeRole: this.storeRole);
}

class loginVerificationState extends State {
  final String countryCode;
  final String phoneNumber;
  final String storeId;
  final String storeRole;

  final FocusNode _pinFocus = FocusNode();
  final TextEditingController _pinController = TextEditingController();
  String verificationCode;

  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final BoxDecoration pinDecoration = BoxDecoration(
    color: mainColor,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: mainColor
    )
  );

var testvar = "taha";

  @override
  void initState() {

    super.initState();

    verifyPhoneNumber();
  }

  verifyPhoneNumber () async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCode + phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
            if (value.user != null) {
              userinfoDatabase userDatabase = userinfoDatabase();
              var checkIfLoggedIn = await userDatabase.checkIfLoggedIn(phonenumberParameter: countryCode + phoneNumber);
              if (checkIfLoggedIn != "empty") {
                myBalance = checkIfLoggedIn["data"];
                // balanceController balance = new balanceController();
                // myBalance = await balance.getMyBalance();
                await userDatabase.updateUserInfo(token: value.user.uid, phonenumber: countryCode + phoneNumber, storeId: storeId, storeRole: checkIfLoggedIn["storeRole"]);

                storeRoleFrontEnd = checkIfLoggedIn["storeRole"];

                // Update Top Bar

                Navigator.pushNamed(context, '/HomePage');
              } else {
                Navigator.pushNamed(context, '/');
              }



              /*streamMessages.add({
                "status": "login",
                "storeRoleFrontEnd": storeRoleFrontEnd,
              });*/



            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            testvar = e.message.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("حدث خطأ ما يرجى إعادة إرسال الرمز"),
                duration: Duration(seconds: 5),
              )
          );
        },
        codeSent: (String vId, int resentToken) {
          setState(() {
            verificationCode = vId;
          });
        },
        codeAutoRetrievalTimeout: (String vId) {
          setState(() {
            verificationCode = vId;
          });
        },
        timeout: Duration(seconds: 120)
    );
  }

  loginVerificationState({
     this.countryCode,
     this.phoneNumber,
     this.storeId,
     this.storeRole,
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MenuBar(),
      ),
      key: _scaffoldKey,
        body:SingleChildScrollView(
          controller: scrolling.returnTheVariable(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height / 2,
            // decoration: BoxDecoration(color: HexColor("#0F78A3")),
            margin: EdgeInsets.only(top: 0), // (MediaQuery.of(context).size.height / 2)
            padding: EdgeInsets.only(top: 100, bottom: 60, left: 15, right: 15),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10,),
                  alignment: Alignment.center,
                  child: Image.asset("assets/images/check.png", width: 120, height: 120, fit: BoxFit.cover,),
                ),

                Container(
                  alignment: Alignment.center,
                  child: Text(
                      "التحقق من رقم الهاتف",
                      style: TextStyle(fontSize: 18, color: secondColor),
                      textAlign: TextAlign.right
                  ),
                ),

                /*Container(
                  alignment: Alignment.topRight,
                  child: Text(
                      testvar.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),*/

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                            "" + countryCode + "  " + phoneNumber,
                            style: TextStyle(fontSize: 16, color: secondColor),
                            textAlign: TextAlign.right
                        ),
                    ),
                    onTap: () {

                    },
                  )
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),

                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: PinPut(
                      fieldsCount: 6,
                      textStyle: TextStyle(color: Colors.white, fontSize: 16),
                      eachFieldWidth: 20,
                      eachFieldHeight: 45,
                      focusNode: _pinFocus,
                      controller: _pinController,
                      submittedFieldDecoration: pinDecoration,
                      selectedFieldDecoration: pinDecoration,
                      followingFieldDecoration: pinDecoration,
                      pinAnimationType: PinAnimationType.rotation,
                      //eachFieldMargin: EdgeInsets.only(left: 3),
                      onSubmit: (pin) async {
                        try {
                          await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationCode, smsCode: pin)).then((value) async {
                            if (value.user != null) {
                              userinfoDatabase userDatabase = userinfoDatabase();

                              var checkIfLoggedIn = await userDatabase.checkIfLoggedIn(phonenumberParameter: countryCode + phoneNumber);

                              if (checkIfLoggedIn != "empty") {
                                await userDatabase.updateUserInfo(token: value.user.uid, phonenumber: countryCode + phoneNumber, storeId: storeId, storeRole: checkIfLoggedIn["storeRole"]);
                                storeRoleFrontEnd = checkIfLoggedIn["storeRole"];

                                myBalance = checkIfLoggedIn["data"];
                                // balanceController balance = new balanceController();
                                // myBalance = await balance.getMyBalance();

                                Navigator.pushNamed(context, '/HomePage');
                              } else {
                                Navigator.pushNamed(context, '/');
                              }


                              /*streamMessages.add({
                                "status": "login",
                                "storeRoleFrontEnd": storeRoleFrontEnd,
                              });*/


                            }
                          });
                        } catch (e) {
                          print("error is error");
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("الكود غير صحيح"),
                                duration: Duration(seconds: 3),
                              )
                          );
                        }
                      },
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () async {
                    verifyPhoneNumber();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.center,
                    child: Text('إعادة إرسال الرمز', style: TextStyle(fontWeight: FontWeight.bold, color: secondColor, fontSize: 11,)),
                  ),
                ),


                GestureDetector(
                  onTap: () async {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.center,
                    child: Text('تعديل الرقم', style: TextStyle(fontWeight: FontWeight.bold, color: secondColor, fontSize: 11,)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  
}