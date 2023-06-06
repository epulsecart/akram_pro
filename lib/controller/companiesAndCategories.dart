// @dart=2.11

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:storeapp/database/userinfoDatabase.dart';

class companiesAndCategories {

  String companiesAndCategories_categoryId;

  companiesAndCategories({
    this.companiesAndCategories_categoryId,
  });

  factory companiesAndCategories.fromJson(Map<String,dynamic>json){
    return companiesAndCategories(
      companiesAndCategories_categoryId: json['companiesAndCategories_categoryId'],
    );
  }


  getCompaniesCategories () async {
    var getCompaniesCategoriesData = [];
    await FirebaseFirestore.instance
        .collection('companyCategories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        getCompaniesCategoriesData.add({
          'companyCategories_name': doc['companyCategories_name'],
          'companyCategories_imgurl': doc['companyCategories_imgurl'],
          'docid': doc.id,
        });
      });
    });

    return getCompaniesCategoriesData;
  }
  
  
  getCompanies () async {
    var getCompaniesData = [];

    if (companiesAndCategories_categoryId == "") {
      await FirebaseFirestore.instance
          .collection('companies')
        //  .orderBy("companies_categoryId", descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var objectData = {};
          objectData['companies_image'] = doc["companies_image"];
          objectData['companies_name'] = doc["companies_name"];
          objectData['companies_printinglogo'] = doc["companies_printinglogo"];
          objectData["docid"] = doc.id;
          getCompaniesData.add(objectData);
        });
      });
    } else {
      await FirebaseFirestore.instance
          .collection('companies')
          .where("companies_categoryId", isEqualTo: companiesAndCategories_categoryId)
        //  .orderBy("companies_categoryId", descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var objectData = {};
          objectData['companies_image'] = doc["companies_image"];
          objectData['companies_name'] = doc["companies_name"];
          objectData['companies_printinglogo'] = doc["companies_printinglogo"];
          objectData["docid"] = doc.id;
          getCompaniesData.add(objectData);
        });
      });
    }


    return getCompaniesData;
  }

  // Get All Companies
  getAllCompanies () async {
    var getCompaniesData = [];


    await FirebaseFirestore.instance
        .collection('companies')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var objectData = {};
        objectData['companies_image'] = doc["companies_image"];
        objectData['companies_name'] = doc["companies_name"];
        objectData['companies_printinglogo'] = doc["companies_printinglogo"];
        objectData["docid"] = doc.id;
        getCompaniesData.add(objectData);
      });
    });

    return getCompaniesData;
  }
}