// import 'gtd_app_logger.dart';
// import 'gtd_error.dart';

import 'package:gtd_network/network/network_service/network_service.dart';

class GtdJsonParser {
  static T jsonToModel<T>(T Function(Map<String, dynamic> map) fromJson, Map response) {
    try {
      return fromJson(response.cast());
    } on TypeError catch (e) {
      GtdLogger.e('Trace: ${e.stackTrace} \nErrorMess: ${e.toString()}', tag: "JsonParser - jsonToModel");
      throw GtdError.custom(
         "Type error during JSON parsing", 
         errorCode: "1001_TYPE_ERROR"
      );
    } catch (e) {
      rethrow;
    }
  }

  static List<T> jsonArrayToModel<T>(T Function(Map<String, dynamic> map) fromJson, List data) {
    try {
      return data.map((e) => fromJson((e as Map).cast())).toList();
    } on TypeError catch (e) {
      GtdLogger.e('Trace: ${e.stackTrace} \nErrorMess: ${e.toString()}', tag: "JsonParser - jsonArrayToModel");
      throw GtdError.custom(
         "Type error during JSON array parsing", 
         errorCode: "1001_TYPE_ERROR"
      );
    } catch (e) {
      rethrow;
    }
  }
}
