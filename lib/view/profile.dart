import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class Profile extends StatelessWidget {
  Profile({super.key});
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.profile.isEmpty) {
          return const Center(child: Text('No profile data'));
        }

        final data = controller.profile;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image
              Obx(
                () => CircleAvatar(
                  radius: 50,
                  backgroundImage: controller.pickedProfileImage.value != null
                      ? FileImage(controller.pickedProfileImage.value!)
                      : NetworkImage('$baseUrl${data['profile_image']}')
                            as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.pickProfileImage(),
                    child: const Text("Change Picture"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        controller.pickProfileImage(fromCamera: true),
                    child: const Text("Camera"),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: controller.usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Logo
              Obx(() {
                if (controller.pickedLogo.value != null) {
                  return Image.file(controller.pickedLogo.value!, height: 100);
                } else if (data['logo'] != null) {
                  return Image.network('$baseUrl${data['logo']}', height: 100);
                } else {
                  return const SizedBox.shrink();
                }
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.pickLogo(),
                    child: const Text("Change Logo"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => controller.pickLogo(fromCamera: true),
                    child: const Text("Camera"),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.updateProfile(
                  profileImage: controller.pickedProfileImage.value,
                  logo: controller.pickedLogo.value,
                ),
                child: const Text("Save Changes"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
