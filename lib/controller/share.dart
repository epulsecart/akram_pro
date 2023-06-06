// import 'package:flutter_share_me/flutter_share_me.dart';
//
// ///sharing platform
// enum Share {
//   facebook,
//   messenger,
//   twitter,
//   whatsapp,
//   whatsapp_personal,
//   whatsapp_business,
//   share_system,
//   share_instagram,
//   share_telegram
// }
//
// Future<void> onButtonTap(Share share) async {
//   String msg =
//       'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
//   String url = 'https://pub.dev/packages/flutter_share_me';
//
//   String? response;
//   final FlutterShareMe flutterShareMe = FlutterShareMe();
//   switch (share) {
//     case Share.facebook:
//       response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
//       break;
//     case Share.messenger:
//       response = await flutterShareMe.shareToMessenger(url: url, msg: msg);
//       break;
//     case Share.twitter:
//       response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
//       break;
//     case Share.whatsapp:
//       if (file != null) {
//         response = await flutterShareMe.shareToWhatsApp(
//             imagePath: file!.path,
//             fileType: videoEnable ? FileType.video : FileType.image);
//       } else {
//         response = await flutterShareMe.shareToWhatsApp(msg: msg);
//       }
//       break;
//     case Share.whatsapp_business:
//       response = await flutterShareMe.shareToWhatsApp(msg: msg);
//       break;
//     case Share.share_system:
//       response = await flutterShareMe.shareToSystem(msg: msg);
//       break;
//     case Share.whatsapp_personal:
//       response = await flutterShareMe.shareWhatsAppPersonalMessage(
//           message: msg, phoneNumber: 'phone-number-with-country-code');
//       break;
//     case Share.share_instagram:
//       response = await flutterShareMe.shareToInstagram(
//           filePath: file!.path,
//           fileType: videoEnable ? FileType.video : FileType.image);
//       break;
//     case Share.share_telegram:
//       response = await flutterShareMe.shareToTelegram(msg: msg);
//       break;
//   }
//   debugPrint(response);
// }


import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

void sharingData(BuildContext context, text, subject) async {
  // A builder is used to retrieve the context immediately
  // surrounding the ElevatedButton.
  //
  // The context's `findRenderObject` returns the first
  // RenderObject in its descendent tree when it's not
  // a RenderObjectWidget. The ElevatedButton's RenderObject
  // has its position and size after it's built.
  final box = context.findRenderObject() as RenderBox;


    await Share.share(text,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}