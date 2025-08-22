import 'package:advertising/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/profile');
            },
            icon: Icon(Icons.person),
          ),
          IconButton(onPressed: controller.logout, icon: Icon(Icons.logout)),
        ],
      ),
    );
  }
}
