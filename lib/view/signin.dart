import 'package:advertising/controller/signin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Signin extends StatelessWidget {
  const Signin({super.key});

  @override
  Widget build(BuildContext context) {
    final SigninController controller = Get.find<SigninController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Signin"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: controller.signin,
                      child: const Text("Signin"),
                    ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Get.toNamed('/signup');
              },
              child: Text("Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
