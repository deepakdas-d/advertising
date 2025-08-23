import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var profile = {}.obs;
  var pickedProfileImage = Rx<File?>(null);
  var pickedLogo = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) return;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final profileEndpoint = dotenv.env['PROFILE_ENDPOINT'] ?? '/profile/';
      final url = Uri.parse("$baseUrl$profileEndpoint");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        profile.value = jsonDecode(response.body);
        usernameController.text = profile['username']?.toString() ?? '';
        emailController.text = profile['email']?.toString() ?? '';
        phoneController.text = profile['phone']?.toString() ?? '';
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        Get.snackbar('Error', 'Session expired. Please login again.');
      } else {
        profile.value = {};
        Get.snackbar('Error', 'Failed to load profile');
      }
    } catch (e, st) {
      log("Error fetching profile: $e", stackTrace: st);
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  //fetch  username.
  String get firstName {
    final name = profile['username'] ?? '';
    return name.toString();
  }

  //Fetch Image
  String get image {
    final name = profile['profile_image'] ?? '';
    return name.toString();
  }

  //Fetch Email

  String get email {
    final name = profile['email'] ?? '';
    return name.toString();
  }

  String get phone {
    final name = profile['phone'] ?? '';
    return name.toString();
  }

  String get logo {
    final name = profile['logo'] ?? '';
    return name.toString();
  }

  Future<void> updateProfile({File? profileImage, File? logo}) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null) return;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final profileEndpoint = dotenv.env['PROFILE_ENDPOINT'];
      final url = Uri.parse("$baseUrl$profileEndpoint");

      var request = http.MultipartRequest("PATCH", url);
      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['username'] = usernameController.text;
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', profileImage.path),
        );
      }
      if (logo != null) {
        request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        profile.value = jsonDecode(responseBody);

        // Reset picked images
        pickedProfileImage.value = null;
        pickedLogo.value = null;

        // Fetch updated profile to refresh UI
        await fetchProfile();

        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        print("DEBUG: ${response.statusCode} => $responseBody");
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickProfileImage({bool fromCamera = false}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (image != null) {
      pickedProfileImage.value = File(image.path);
    }
  }

  Future<void> pickLogo({bool fromCamera = false}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (image != null) {
      pickedLogo.value = File(image.path);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
