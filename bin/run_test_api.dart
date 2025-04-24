import 'package:gtd_network/network/usage/test_api.dart' as api_test;

void main() async {
  print('Starting API test runner...');
  await api_test.main();
  print('Test execution completed.');
} 