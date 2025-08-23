import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PosterController extends GetxController {
  var isLoading = true.obs;
  var isLoadingForButton = false.obs;
  var backgroundColor = Colors.teal.obs;

  @override
  void onInit() {
    super.onInit();
    _loadImage();
  }

  void _loadImage() async {
    // fake loading
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  void setLoadingForButton(bool value) => isLoadingForButton.value = value;

  Future<void> captureAndSaveImage(
    String id,
    String url,
    GlobalKey key,
    BuildContext context,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    Get.snackbar("Saved", "Image saved successfully");
  }

  Future<void> shareImage(
    String id,
    String url,
    GlobalKey key,
    BuildContext context,
  ) async {
    try {
      // Capture widget as image using RepaintBoundary + key
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$id.png');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Check out this image!");
    } catch (e) {
      Get.snackbar("Error", "Failed to share: $e");
    }
  }
}
