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

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final storage =
      const FlutterSecureStorage(); // secure storage for refresh token

  String? accessToken;
  String? refreshToken;

  /// Signin method
  Future<void> signin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      log("Signin failed: email or password empty");
      return;
    }

    try {
      isLoading.value = true;

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

        Get.snackbar("✅ Success", "Login successful!");
        emailController.clear();
        passwordController.clear();

        Get.offAll(() => Home());
      } else {
        log("Login failed with status: ${response.statusCode}");
        Get.snackbar("❌ Error", "Login failed: ${response.body}");
      }
    } catch (e) {
      log("Signin error: $e");
      Get.snackbar("Error", e.toString());
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
}
