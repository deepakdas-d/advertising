import 'dart:convert';
import 'package:advertising/model/image_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GalleryController extends GetxController {
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  int page = 1;

  var selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages(); // fetch images when controller is initialized
  }

  // Map<CategoryName, List<Images>>
  var imagesByCategory = <String, List<ImageModel>>{}.obs;

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
        imagesByCategory.clear();
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final endpoint = dotenv.env['IMAGE_ENDPOINT'] ?? '';
      final url = Uri.parse("$baseUrl$endpoint?page=$page&limit=20");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        if (data.isEmpty) hasMore.value = false;

        List<ImageModel> images = data
            .map((e) => ImageModel.fromJson(e))
            .toList();

        for (var img in images) {
          final list = imagesByCategory.putIfAbsent(img.categoryName, () => []);
          if (!list.any((e) => e.id == img.id)) list.add(img);
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
}
