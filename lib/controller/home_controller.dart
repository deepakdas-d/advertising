import 'dart:convert';

import 'package:advertising/model/image_model.dart';
import 'package:advertising/view/signin.dart' show Signin;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  String? accessToken;
  String? refreshToken;

  var imagesByCategory = <String, List<ImageModel>>{}.obs;
  var isLoading = true.obs;
  var errorMessage = RxnString();
  var imageUrls = <String>[].obs;
  var page = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
    fetchCarouselImages();
  }

  Future<void> fetchImages({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (isLoadingMore.value || !hasMore.value) return;
        isLoadingMore.value = true;
        page++;
      } else {
        isLoading.value = true;
        page = 1;
        hasMore.value = true;
        imagesByCategory.clear(); // ✅ clear old data
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final profileEndpoint = dotenv.env['IMAGE_ENDPOINT'];
      final url = Uri.parse("$baseUrl$profileEndpoint?page=$page&limit=20");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        if (data.isEmpty) {
          hasMore.value = false;
        }

        List<ImageModel> images = data
            .map((e) => ImageModel.fromJson(e))
            .toList();

        // ✅ group without duplicates
        for (var img in images) {
          final list = imagesByCategory.putIfAbsent(img.categoryName, () => []);
          if (!list.any((e) => e.id == img.id)) {
            list.add(img);
          }
        }

        imagesByCategory.refresh();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch images: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  //CAROUSEL IMAGE VIEW
  Future<void> fetchCarouselImages() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final carouselEndpoint = dotenv.env['CAROUSEL_ENDPOINT'];
      final url = Uri.parse("$baseUrl$carouselEndpoint/1/");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        imageUrls.value = [
          data['image1'],
          data['image2'],
          data['image3'],
          data['image4'],
        ].where((url) => url != null).map((url) => url.toString()).toList();
      } else {
        errorMessage.value = "Failed to load images";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    accessToken = null;
    refreshToken = null;
    Get.offAll(() => Signin());

    Get.snackbar("Logged Out", "You have been logged out successfully");
  }
}
