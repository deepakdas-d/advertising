import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VideoListController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<Map<String, dynamic>> videos = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final List<String> categories = ['All', 'Music', 'Training', 'Other'];
  final double standardPadding = 12.0;
  final double cardBorderRadius = 12.0;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final videoEndpoint = dotenv.env['VIDEO_ENDPOINT'] ?? '/video/';
      final url = Uri.parse("$baseUrl$videoEndpoint");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        videos.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load videos';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredVideos {
    return videos.where((video) {
      final name = video['video_name']?.toString().toLowerCase() ?? '';
      final category = video['category']?.toString() ?? '';
      final matchesSearch = name.contains(searchQuery.value.toLowerCase());
      final matchesCategory =
          selectedCategory.value == 'All' || category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }
}

class AppTheme {
  static const Color primaryColor = Color(0xFF00A19A); // Teal main color
  static const Color secondaryColor = Color(
    0xFFF8FAFA,
  ); // Very light background
  static const Color accentColor = Color(0xFF005F5C); // Darker teal for accents
  static const Color cardColor = Colors.white; // White card backgrounds
  static const Color textColor = Color(0xFF212121); // Primary text
  static const Color subtitleColor = Color(0xFF757575); // Subtitle text
}
