class productClass {
  String companyId;
  String companyName;

  productClass({this.companyId, this.companyName});

  factory productClass.fromJson(Map<String,dynamic>json){
    return productClass(
      companyId: json['companyId'],
      companyName: json['CompanyName'],
    );
  }
}