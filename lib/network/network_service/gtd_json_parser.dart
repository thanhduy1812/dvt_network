// import 'gtd_app_logger.dart';
// import 'gtd_dio_exception.dart';

// class JsonParser {
//   static T jsonToModel<T>(T Function(Map<String, dynamic> map) fromJson, Map response) {
//     try {
//       return fromJson(response.cast());
//     } on TypeError catch (e) {
//       NetWorkLogger.e('Trace: ${e.stackTrace} \nErrorMess: ${e.toString()}', tag: "JsonParser - jsonToModel");
//       throw GtdDioException.fromError(code: "1001_TYPE_ERROR", message: e.stackTrace.toString());
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static List<T> jsonArrayToModel<T>(T Function(Map<String, dynamic> map) fromJson, List data) {
//     try {
//       return data.map((e) => fromJson((e as Map).cast())).toList();
//     } on TypeError catch (e) {
//       NetWorkLogger.e('Trace: ${e.stackTrace} \nErrorMess: ${e.toString()}', tag: "JsonParser - jsonArrayToModel");
//       throw GtdDioException.fromError(code: "1001_TYPE_ERROR", message: e.stackTrace.toString());
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
