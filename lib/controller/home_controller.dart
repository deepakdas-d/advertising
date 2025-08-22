import 'package:advertising/view/signin.dart' show Signin;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  String? accessToken;
  String? refreshToken;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    accessToken = null;
    refreshToken = null;
    Get.offAll(() => Signin());

    Get.snackbar("Logged Out", "You have been logged out successfully");
  }
}
