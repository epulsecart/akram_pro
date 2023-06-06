import 'package:flutter/services.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

class printer {
  static const platform =  MethodChannel("com.cybitsec.souqcardstoreapp/text");

  connectToPrinter () async {
    userinfoDatabase userInfo = new userinfoDatabase();
    var printerAddress = await userInfo.getPrinterAddress();

    String result = "";

    if (printerAddress != "empty") {
      String value;
      try {
        value = await platform.invokeMethod('connectToPrinter',{"printerAddress": printerAddress});

        if (value.toString() == "connect") {
          userinfoDatabase userInfo = new userinfoDatabase();
          await userInfo.updatePrinterAddress(printerAddress: printerAddress);

          result = "connected";
        } else {
          result = "notconnected";
        }

      } on PlatformException catch (e) {
        result = "notconnected";
      }

      return result;
    } else {
      return "notconnected";
    }

  }
}