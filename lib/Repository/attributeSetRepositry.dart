import '../Helper/ApiBaseHelper.dart';
import '../Widget/api.dart';

class AttributeRepository {

  static Future<Map<String, dynamic>> setAttributeset(
  ) async {
    try {
   var parameter = {};
      var data =
          await ApiBaseHelper().postAPICall(getAttributeSetApi, parameter);

      return data;
    } on Exception catch (e){
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }
   static Future<Map<String, dynamic>> attributeset(
  ) async {
    try {
   var parameter = {};
      var data =
          await ApiBaseHelper().postAPICall(getAttributesApi, parameter);

      return data;
    } on Exception catch (e) {
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }

   static Future<Map<String, dynamic>> attributeValue(
  ) async {
    try {
   var parameter = {};
      var data =
          await ApiBaseHelper().postAPICall(getAttributrValuesApi, parameter);

      return data;
    } on Exception catch (e) {
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }
}
