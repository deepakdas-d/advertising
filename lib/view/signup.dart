import 'dart:io';
import 'package:advertising/controller/signup_controller.dart';
import 'package:advertising/model/signup_model.dart';
import 'package:advertising/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  final controller = Get.find<SignupController>();

  Future<void> _pickImage(BuildContext context, bool isProfile) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.deepPlum
              : AppColors.lightPeach,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.wineRed),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.wineRed),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
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

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    String? errorText,
    bool isDark = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.1) // light fill for dark mode
          : AppColors.softPink.withOpacity(0.15),

      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white70 : AppColors.deepPlum.withOpacity(0.6),
        fontWeight: FontWeight.w400,
      ),

      prefixIcon: Icon(
        icon,
        color: isDark ? Colors.white70 : AppColors.wineRed.withOpacity(0.7),
      ),

      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.redAccent),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white38 : AppColors.wineRed.withOpacity(0.2),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white : AppColors.wineRed,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: isDark ? AppColors.deepPlum : AppColors.lightPeach,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isDark
                          ? AppColors.lightPeach
                          : AppColors.deepPlum,
                      child: Icon(
                        Icons.person_add,
                        size: 40,
                        color: isDark
                            ? AppColors.deepPlum
                            : AppColors.lightPeach,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.deepPlum,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us today and start your journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? Colors.white70
                            : AppColors.deepPlum.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Form Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: isDark
                      ? AppColors.lightPeach.withOpacity(0.5)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Obx(
                      () => Column(
                        children: [
                          // Username
                          TextFormField(
                            controller: controller.usernameController,
                            decoration: _inputDecoration(
                              isDark: isDark,

                              'Username',
                              Icons.person,
                              errorText: controller.usernameError.value.isEmpty
                                  ? null
                                  : controller.usernameError.value,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.deepPlum,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) =>
                                controller.validateUsername(value),
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              isDark: isDark,

                              'Phone Number',
                              Icons.phone,
                              errorText: controller.phoneError.value.isEmpty
                                  ? null
                                  : controller.phoneError.value,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.deepPlum,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) =>
                                controller.validatePhone(value),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              isDark: isDark,

                              'Email Address',
                              Icons.email,
                              errorText: controller.emailError.value.isEmpty
                                  ? null
                                  : controller.emailError.value,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.deepPlum,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) =>
                                controller.validateEmail(value),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: controller.passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              isDark: isDark,

                              'Password',
                              Icons.lock,
                              errorText: controller.passwordError.value.isEmpty
                                  ? null
                                  : controller.passwordError.value,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.deepPlum,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) =>
                                controller.validatePassword(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image Pickers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Profile Image
                    Obx(
                      () => Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(context, true),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.wineRed,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: isDark
                                    ? AppColors.lightPeach
                                    : AppColors.deepPlum,
                                backgroundImage:
                                    controller.profileImage.value != null
                                    ? FileImage(controller.profileImage.value!)
                                    : null,
                                child: controller.profileImage.value == null
                                    ? Icon(
                                        Icons.person,
                                        size: 40,
                                        color: isDark
                                            ? AppColors.deepPlum
                                            : AppColors.lightPeach,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Profile Photo',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.deepPlum,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logo
                    Obx(
                      () => Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(context, false),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.wineRed,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: isDark
                                    ? AppColors.lightPeach
                                    : AppColors.deepPlum,
                                backgroundImage: controller.logo.value != null
                                    ? FileImage(controller.logo.value!)
                                    : null,
                                child: controller.logo.value == null
                                    ? Icon(
                                        Icons.image,
                                        size: 40,
                                        color: isDark
                                            ? AppColors.deepPlum
                                            : AppColors.lightPeach,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logo',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.deepPlum,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Signup Button
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.softPink
                            : AppColors.wineRed,
                        foregroundColor: isDark
                            ? Colors.white
                            : AppColors.softPink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.wineRed.withOpacity(0.4),
                      ),
                      onPressed:
                          controller.isFormValid.value &&
                              !controller.isLoading.value
                          ? () {
                              final model = SignupModel(
                                username: controller.usernameController.text
                                    .trim(),
                                phone: controller.phoneController.text.trim(),
                                email: controller.emailController.text.trim(),
                                password: controller.passwordController.text
                                    .trim(),
                                profileImage: controller.profileImage.value,
                                logo: controller.logo.value,
                              );
                              controller.signup(model);
                            }
                          : null,
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Message
                Obx(
                  () => controller.errorMessage.value.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.roseRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: AppColors.roseRed,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Sign In Link
                TextButton(
                  onPressed: () => Get.toNamed('/signin'),
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.wineRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
