class loginAuthClass{
  String countryCode;
  String phoneNumber;
  String storeId;
  String storeRole;

  loginAuthClass({this.countryCode, this.phoneNumber, this.storeId, this.storeRole});

  factory loginAuthClass.fromJson(Map<String,dynamic>json){
    return loginAuthClass(
      countryCode: json['countryCode'],
      phoneNumber: json['phoneNumber'],
      storeId: json['storeId'],
      storeRole: json['storeRole']
    );
  }
}