import '../Helper/ApiBaseHelper.dart';
import '../Widget/api.dart';

class ProfileRepository {
  // for add faqs.
  static Future<Map<String, dynamic>> getSallerDetail(
    {
    var parameter,
  }
  ) async {
    try {
     var taxDetail =
          await ApiBaseHelper().postAPICall(getSellerDetailsApi, parameter);

      return taxDetail;
    } on Exception catch (e) {
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }

   static Future<Map<String, dynamic>> updateUser(
    {
    var parameter,
  }
  ) async {
    try {
     var taxDetail =
          await ApiBaseHelper().postAPICall(updateUserApi, parameter);

      return taxDetail;
    } on Exception catch (e) {
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }
}
