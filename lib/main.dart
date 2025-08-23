import 'package:advertising/authwrapper.dart';
import 'package:advertising/binding.dart';
import 'package:advertising/view/gallery.dart';
import 'package:advertising/view/home.dart';
import 'package:advertising/view/profile.dart';
import 'package:advertising/view/signin.dart';
import 'package:advertising/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: AuthWrapper(),
      getPages: [
        GetPage(
          name: '/signup',
          page: () => Signup(),
          binding: SignupBinding(),
        ),
        GetPage(
          name: '/signin',
          page: () => Signin(),
          binding: SigninBinding(),
        ),
        GetPage(name: '/home', page: () => Home(), binding: HomeBinding()),
        GetPage(
          name: '/profile',
          page: () => Profile(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: '/gallery',
          page: () => Gallery(),
          binding: GalleryBinding(),
        ),
      ],
    );
  }
}
