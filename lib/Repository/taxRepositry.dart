import '../Helper/ApiBaseHelper.dart';
import '../Widget/api.dart';

class TaxRepository {
  // for add faqs.
  static Future<Map<String, dynamic>> setTax(
  ) async {
    try {
      var parameter = {};
      var taxDetail =
          await ApiBaseHelper().postAPICall(getTaxesApi, parameter);

      return taxDetail;
    } on Exception catch (e) {
      throw ApiException('Something went wrong, ${e.toString()}');
    }
  }
}