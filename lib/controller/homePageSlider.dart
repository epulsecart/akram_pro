// @dart=2.11
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class homePageSliderController {
  String sliderIndex;
  String sliderId;
  File sliderImage;
  String type;

  homePageSliderController({this.sliderIndex, this.sliderId, this.sliderImage, this.type});

  factory homePageSliderController.fromJson(Map<String,dynamic>json){
    return homePageSliderController(
      sliderIndex: json['sliderIndex'],
      sliderId: json['sliderId'],
      sliderImage: json['sliderImage'],
      type: json['type'],
    );
  }

  getAllData () async {
    var getSliderImages = [];

    await FirebaseFirestore.instance
        .collection('homePageSlider')
        .orderBy("sliderIndex", descending: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        getSliderImages.add(doc["sliderImage"]);
      });
    });

    return getSliderImages;
  }

}