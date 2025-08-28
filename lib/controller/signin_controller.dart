import 'dart:convert';
import 'dart:developer';
import 'package:advertising/model/auth_model.dart';
import 'package:advertising/view/signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising/view/home.dart';

class SigninController extends GetxController {
  var isLoading = false.obs;
  var isFormValid = false.obs;

  // Error message observables
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var errorMessage = ''.obs;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final storage =
      const FlutterSecureStorage(); // secure storage for refresh token

  String? accessToken;
  String? refreshToken;

  @override
  void onInit() {
    super.onInit();
    // Add listeners for real-time validation
    emailController.addListener(() => validateEmail(emailController.text));
    passwordController.addListener(
      () => validatePassword(passwordController.text),
    );
  }

  // Validation methods
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
    } else {
      passwordError.value = '';
    }
    _updateFormValidity();
  }

  // Check if entire form is valid
  void _updateFormValidity() {
    isFormValid.value =
        emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  /// Signin method
  Future<void> signin() async {
    if (!isFormValid.value) {
      errorMessage.value = 'Please fix all form errors before submitting';
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final baseUrl = dotenv.env['BASE_URL']!;
      final endpoint = dotenv.env['SIGNIN_ENDPOINT']!;
      final url = Uri.parse("$baseUrl$endpoint");

      log("Sending login request to: $url with email: $email");

      // Use http.post with JSON body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': email, 'password': password}),
      );

      log("Received response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log("Decoded response JSON: $data");

        final auth = AuthModel.fromJson(data);

        // Save tokens
        accessToken = auth.accessToken;
        refreshToken = auth.refreshToken;

        log("Access token: $accessToken");
        log("Refresh token: $refreshToken");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken!);
        await storage.write(key: 'refresh_token', value: refreshToken!);

        // Confirm tokens saved
        final savedToken = prefs.getString('access_token');
        log("Saved access token in SharedPreferences: $savedToken");

        Get.snackbar(
          "✅ Success",
          "Login successful!",
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
        emailController.clear();
        passwordController.clear();
        emailError.value = '';
        passwordError.value = '';
        errorMessage.value = '';

        Get.offAll(() => Home());
      } else {
        errorMessage.value = 'Login failed: ${response.body}';
        Get.snackbar(
          "❌ Error",
          "Login failed: ${response.body}",
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
      log("Signin error: $e");
    } finally {
      isLoading.value = false;
      log("Signin process completed. isLoading: ${isLoading.value}");
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    if (refreshToken == null) {
      log("Refresh token is null, cannot refresh access token");
      return;
    }

    try {
      final baseUrl = dotenv.env['BASE_URL']!;
      final refreshEndpoint = dotenv.env['REFRESH_ENDPOINT']!;
      final url = Uri.parse("$baseUrl$refreshEndpoint");

      log("Refreshing access token at: $url with refresh token");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      log("Refresh token response status: ${response.statusCode}");
      log("Refresh token response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accessToken = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken!);

        log("Access token refreshed successfully: $accessToken");
      } else {
        log("Refresh token invalid or expired, logging out...");
        logout();
      }
    } catch (e) {
      log("Error refreshing token: $e");
      logout();
    }
  }

  Future<void> logout() async {
    log("Logging out user...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await storage.delete(key: 'refresh_token');
    accessToken = null;
    refreshToken = null;
    log("Tokens cleared from storage");
    Get.offAll(() => Signin());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
