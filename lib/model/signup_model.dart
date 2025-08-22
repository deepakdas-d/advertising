import 'dart:io';

class SignupModel {
  String username;
  String phone;
  String email;
  String password;
  bool isStaff;
  File? profileImage;
  File? logo;

  SignupModel({
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    this.isStaff = false,
    this.profileImage,
    this.logo,
  });

  Map<String, String> toJson() {
    return {
      "username": username,
      "phone": phone,
      "email": email,
      "password": password,
      "is_staff": isStaff.toString(),
    };
  }
}
