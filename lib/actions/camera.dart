/* Start Camera */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class handleCameraGalleryFiles  {

  /* Open Camera */
  openCamera(BuildContext context) async {
    PickedFile image;

    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      image = (await ImagePicker().getImage(
        source: ImageSource.camera ,
      ));

      if (image != null){
        return File(image.path);
      } else {
        return "null";
      }
    }
  }

  /* Open Gallery */
  openGallery(BuildContext context) async {
    PickedFile image;

    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      image = (await ImagePicker().getImage(
        source: ImageSource.gallery ,
      ));

      if (image != null){
        return File(image.path);
      } else {
        return "null";
      }
    }
  }

  var saveInsideItImage;
  /* Show Alert To Choose Camera or Gallery */
  Future<dynamic> showChoiceDialog(BuildContext context)
  {
    return showDialog(context: context,builder: (BuildContext context) {

      return AlertDialog(
        title: Text("إختار خيار",style: TextStyle(color: Colors.blue),),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Divider(height: 1,color: Colors.blue,),
              ListTile(
                onTap: () async {
                  var getTheImage = await openGallery(context);
                  Navigator.pop(context);
                  //setState(() {
                  saveInsideItImage = getTheImage;
                 // });
                },
                title: Text("معرض الصور"),
                leading: Icon(Icons.account_box,color: Colors.blue,),
              ),

              Divider(height: 1,color: Colors.blue,),
              ListTile(
                onTap: () async {
                  var getTheImage = await openCamera(context);
                  Navigator.pop(context);
                  //setState(() {
                  saveInsideItImage = getTheImage;
                  //});
                },
                title: Text("الكاميرا"),
                leading: Icon(Icons.camera,color: Colors.blue,),
              ),
            ],
          ),
        ),);
    });
  }

  giveSaveInsideItImage () {
    return saveInsideItImage;
  }


}
