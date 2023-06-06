class cardsClass {
  String productId;

  cardsClass({this.productId});

  factory cardsClass.fromJson(Map<String,dynamic>json){
    return cardsClass(
        productId: json['productId'],
    );
  }
}