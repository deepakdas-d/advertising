import 'package:advertising/authwrapper.dart';
import 'package:advertising/binding.dart';
import 'package:advertising/onboarding.dart';
import 'package:advertising/theme.dart';
import 'package:advertising/view/gallery.dart';
import 'package:advertising/view/home.dart';
import 'package:advertising/view/profile.dart';
import 'package:advertising/view/signin.dart';
import 'package:advertising/view/signup.dart';
import 'package:advertising/view/video_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: onboardingCompleted ? AuthWrapper() : OnboardingScreen(),
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
        GetPage(
          name: '/videolist',
          page: () => VideoList(),
          binding: VideoListBinding(),
        ),
      ],
    );
  }
}
