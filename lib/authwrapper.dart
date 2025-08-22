import 'dart:developer';
import 'package:advertising/controller/home_controller.dart';
import 'package:advertising/controller/signin_controller.dart';
import 'package:advertising/view/home.dart';
import 'package:advertising/view/signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SigninController signinController = Get.put(
    SigninController(),
    permanent: true,
  );
  final HomeController homeController = Get.put(
    HomeController(),
    permanent: true,
  );

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    signinController.isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    signinController.accessToken = token;

    log("AuthWrapper: Loaded access token from SharedPreferences: $token");

    signinController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (signinController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      log(
        "AuthWrapper: Checking access token: ${signinController.accessToken}",
      );

      return signinController.accessToken != null &&
              signinController.accessToken!.isNotEmpty
          ? Home()
          : const Signin();
    });
  }
}
