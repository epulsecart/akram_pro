// @dart=2.11

class inputValidator {

  String inputValue;

  inputValidator({
    this.inputValue,
  });

  factory inputValidator.fromJson(Map<String, dynamic>json){
    return inputValidator(
      inputValue: json['inputValue'],
    );
  }


  validatePrice (String value)  {
    if (value.length < 1) {
      return "أضف سعر";
    } else if (value.split(".").length > 2) {
      return 'خطأ في السعر';
    }

   return null;
  }

  validateDotsPrice (String value)  {
    if (value.split(".").length > 2) {
      return 'خطأ في السعر';
    }

    return null;
  }
}