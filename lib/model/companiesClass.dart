class companiesClass {
  String companyCategoryId;
  String companyCategoryName;

  companiesClass({this.companyCategoryId, this.companyCategoryName});

  factory companiesClass.fromJson(Map<String,dynamic>json){
    return companiesClass(
      companyCategoryId: json['companyCategoryId'],
      companyCategoryName: json['companyCategoryName'],
    );
  }
}