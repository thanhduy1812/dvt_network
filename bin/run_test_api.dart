import 'package:gtd_network/network/usage/test_api.dart' as api_test;
import 'package:gtd_network/network/network_service/gtd_app_logger.dart';

void main() async {
  GtdLogger.i('Starting API test runner...');
  await api_test.main();
  GtdLogger.i('Test execution completed.');
} 