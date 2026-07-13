import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkConnectivity() async {
  final result = await Connectivity().checkConnectivity();
  // ignore: unrelated_type_equality_checks
  return result != ConnectivityResult.none;
}
/*
Future<bool> checkConnectivity() async {
  try {
    final response = await http.get(
      Uri.parse('http://YOUR_IP:8080/health'),
    ).timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
*/