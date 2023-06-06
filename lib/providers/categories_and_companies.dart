import 'package:flutter/cupertino.dart';

import '../controller/companiesAndCategories.dart';

class CategoriesAndCompaniesProvider extends ChangeNotifier {
  bool dataIsInit = false;
  bool companiesAreInit = false;
  List getCompaniesCategories = [];
  List getCompanies = [];
  Map<String, List> companies = {};
  List getDataSearch = [];
  getCompaniesCategoriesFun() async {
    companiesAndCategories getCompaniesCategoriesClass =
        new companiesAndCategories();
    var getCompaniesCategoriesForDisplay =
        await getCompaniesCategoriesClass.getCompaniesCategories();
    getCompaniesCategories = getCompaniesCategoriesForDisplay;
    dataIsInit = true;
    notifyListeners();

    return getCompaniesCategories;
  }

  getCompaniesFun(String companyCategoryId) async {
    if (companies.containsKey(companyCategoryId)) {
      companiesAreInit = true;
    } else {
      companiesAreInit = false;
    }
    notifyListeners();
    companiesAndCategories getCompaniesClass = new companiesAndCategories(
        companiesAndCategories_categoryId: companyCategoryId);
    var getCompaniesForDisplay = await getCompaniesClass.getCompanies();
    getCompanies = getCompaniesForDisplay;
    if (companies.keys.contains(companyCategoryId)) {
      companies[companyCategoryId] = [];
      companies[companyCategoryId] = getCompanies;
    } else {
      companies.addAll({companyCategoryId: getCompanies});
    }
    getDataSearch = getCompaniesForDisplay;
    notifyListeners();
    companiesAreInit = true;
    return getCompaniesForDisplay;
  }
}
