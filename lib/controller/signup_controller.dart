import 'dart:developer';
import 'dart:io';
import 'package:advertising/model/signup_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var profileImage = Rx<File?>(null);
  var logo = Rx<File?>(null);

  void setProfileImage(File file) {
    profileImage.value = file;
  }

  void setLogo(File file) {
    logo.value = file;
  }

  Future<void> signup(SignupModel model) async {
    isLoading.value = true;
    try {
      final baseUrl = dotenv.env['BASE_URL']!;
      final endpoint = dotenv.env['SIGNUP_ENDPOINT']!;
      final url = Uri.parse("$baseUrl$endpoint");

      var request = http.MultipartRequest("POST", url);

      // Add text fields
      request.fields.addAll(model.toJson());

      // Add images if selected
      if (model.profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            model.profileImage!.path,
          ),
        );
      }
      if (model.logo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', model.logo!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      log(resBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("✅ Success", "Signup successful!");

        // Reset inputs
        usernameController.clear();
        phoneController.clear();
        emailController.clear();
        passwordController.clear();
        profileImage.value = null;
        logo.value = null;
        Get.toNamed('/signin');
      } else {
        Get.snackbar("❌ Error", "Signup failed: $resBody");
      }
    } catch (e) {
      Get.snackbar("⚠️ Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
