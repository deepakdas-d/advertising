import 'dart:developer';
import 'dart:io';
import 'package:advertising/model/signup_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;
  var isFormValid = false.obs;

  // Error message observables
  var usernameError = ''.obs;
  var phoneError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var errorMessage = ''.obs;

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var profileImage = Rx<File?>(null);
  var logo = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    // Add listeners for real-time validation
    usernameController.addListener(
      () => validateUsername(usernameController.text),
    );
    phoneController.addListener(() => validatePhone(phoneController.text));
    emailController.addListener(() => validateEmail(emailController.text));
    passwordController.addListener(
      () => validatePassword(passwordController.text),
    );
  }

  void setProfileImage(File file) {
    profileImage.value = file;
    _updateFormValidity();
  }

  void setLogo(File file) {
    logo.value = file;
    _updateFormValidity();
  }

  // Validation methods
  void validateUsername(String value) {
    if (value.isEmpty) {
      usernameError.value = 'Username is required';
    } else if (value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
    } else if (value.length > 20) {
      usernameError.value = 'Username cannot exceed 20 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      usernameError.value =
          'Username can only contain letters, numbers, and underscores';
    } else {
      usernameError.value = '';
    }
    _updateFormValidity();
  }

  void validatePhone(String value) {
    if (value.isEmpty) {
      phoneError.value = 'Phone number is required';
    } else if (!RegExp(r'^\+?\d{10,12}$').hasMatch(value)) {
      phoneError.value = 'Enter a valid phone number (10-12 digits)';
    } else {
      phoneError.value = '';
    }
    _updateFormValidity();
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      emailError.value = 'Enter a valid email address';
    } else {
      emailError.value = '';
    }
    _updateFormValidity();
  }

  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (value.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
    } else if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
    ).hasMatch(value)) {
      passwordError.value =
          'Password must contain uppercase, lowercase, number, and special character';
    } else {
      passwordError.value = '';
    }
    _updateFormValidity();
  }

  // Check if entire form is valid
  void _updateFormValidity() {
    isFormValid.value =
        usernameError.value.isEmpty &&
        phoneError.value.isEmpty &&
        emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        usernameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  Future<void> signup(SignupModel model) async {
    if (!isFormValid.value) {
      errorMessage.value = 'Please fix all form errors before submitting';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
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
        Get.snackbar(
          "✅ Success",
          "Signup successful!",
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );

        // Reset inputs
        usernameController.clear();
        phoneController.clear();
        emailController.clear();
        passwordController.clear();
        profileImage.value = null;
        logo.value = null;
        usernameError.value = '';
        phoneError.value = '';
        emailError.value = '';
        passwordError.value = '';
        errorMessage.value = '';
        Get.toNamed('/signin');
      } else {
        errorMessage.value = 'Signup failed: $resBody';
        Get.snackbar(
          "❌ Error",
          "Signup failed: $resBody",
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
      Get.snackbar(
        "⚠️ Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
