import 'dart:io';
import 'package:advertising/controller/signup_controller.dart';
import 'package:advertising/model/signup_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  final controller = Get.find<SignupController>();

  Future<void> _pickImage(BuildContext context, bool isProfile) async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Text("Gallery"),
          ),
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 80);

      if (picked != null) {
        if (isProfile) {
          controller.setProfileImage(File(picked.path));
        } else {
          controller.setLogo(File(picked.path));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: controller.usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),

              // Profile Image Picker
              Obx(
                () => Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(context, true),
                      child: const Text("Pick Profile Image"),
                    ),
                    const SizedBox(width: 12),
                    controller.profileImage.value != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(
                              controller.profileImage.value!,
                            ),
                            radius: 30,
                          )
                        : const Text("No profile image"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logo Picker
              Obx(
                () => Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(context, false),
                      child: const Text("Pick Logo"),
                    ),
                    const SizedBox(width: 12),
                    controller.logo.value != null
                        ? Image.file(
                            controller.logo.value!,
                            width: 60,
                            height: 60,
                          )
                        : const Text("No logo"),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          final model = SignupModel(
                            username: controller.usernameController.text.trim(),
                            phone: controller.phoneController.text.trim(),
                            email: controller.emailController.text.trim(),
                            password: controller.passwordController.text.trim(),
                            profileImage: controller.profileImage.value,
                            logo: controller.logo.value,
                          );
                          controller.signup(model);
                        },
                        child: const Text("Sign Up"),
                      ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed('/signin');
                },
                child: Text("Sign in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
