import 'package:advertising/controller/signin_controller.dart';
import 'package:advertising/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Signin extends StatelessWidget {
  const Signin({super.key});

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
    final SigninController controller = Get.find<SigninController>();
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
                        Icons.login,
                        size: 40,
                        color: isDark
                            ? AppColors.deepPlum
                            : AppColors.lightPeach,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.deepPlum,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your journey',
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
                      ? AppColors.lightPeach.withOpacity(0.95)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Obx(
                      () => Column(
                        children: [
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

                // Signin Button
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
                          ? controller.signin
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
                              'Sign In',
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

                // Signup Link
                TextButton(
                  onPressed: () => Get.toNamed('/signup'),
                  child: Text(
                    'Don\'t have an account? Sign Up',
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
