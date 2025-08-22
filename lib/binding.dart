import 'package:advertising/controller/home_controller.dart';
import 'package:advertising/controller/profile_controller.dart';
import 'package:advertising/controller/signin_controller.dart';
import 'package:advertising/controller/signup_controller.dart';
import 'package:get/get.dart';

//SignUP binding
class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}

//SignIn binding

class SigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SigninController>(() => SigninController());
  }
}

//Home bidnding

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
