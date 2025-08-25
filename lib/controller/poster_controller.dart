import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'profile_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class PosterController extends GetxController {
  var isLoading = true.obs;
  var isLoadingForButton = false.obs;
  var backgroundColor = Colors.teal.obs;

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    _loadImage();
  }

  void _loadImage() async {
    // Fake loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  void setLoadingForButton(bool value) => isLoadingForButton.value = value;

  /// Check if user has an active subscription
  bool isSubscribed() {
    final profile = profileController.profile;
    log("DEBUG: profile = $profile"); // log the profile data

    if (profile.isEmpty) {
      log("DEBUG: profile is empty");
      return false;
    }

    final sub = profile['subscription'];
    log("DEBUG: subscription = $sub"); // log subscription object

    if (sub == null) {
      log("DEBUG: subscription is null");
      return false;
    }

    final bool isActive = sub['is_active'] ?? false;
    final bool revoked = sub['revoke'] ?? true;
    log("DEBUG: isActive=$isActive, revoked=$revoked");

    if (!isActive || revoked) {
      log("DEBUG: subscription not active or revoked");
      return false;
    }

    final startDate = DateTime.tryParse(sub['start_date'] ?? '');
    final endDate = DateTime.tryParse(sub['end_date'] ?? '');
    final now = DateTime.now();
    log("DEBUG: startDate=$startDate, endDate=$endDate, now=$now");

    if (startDate == null || endDate == null) {
      log("DEBUG: startDate or endDate is null");
      return false;
    }

    // inclusive check
    bool result = !now.isBefore(startDate) && !now.isAfter(endDate);
    log("DEBUG: subscription valid = $result");

    return result;
  }

  Future<void> captureAndSaveImage(
    String id,
    String url,
    GlobalKey key,
    BuildContext context,
  ) async {
    if (!isSubscribed()) {
      Get.snackbar(
        "Not Subscribed",
        "Your subscription is inactive or expired",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setLoadingForButton(true);

    try {
      // Request appropriate permission
      bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        Get.snackbar(
          "Permission Denied",
          "Storage or photos permission is required",
          snackPosition: SnackPosition.BOTTOM,
        );
        setLoadingForButton(false);
        return;
      }

      // Capture widget
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw "Failed to find render object";
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw "Failed to capture image data";
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get save directory
      Directory saveDirectory;
      if (Platform.isAndroid) {
        saveDirectory = Directory('/storage/emulated/0/Download');
        if (!await saveDirectory.exists()) {
          await saveDirectory.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        saveDirectory = await getTemporaryDirectory(); // Use temp for iOS
      } else {
        throw "Unsupported platform";
      }

      // Save file with unique name
      final filePath =
          '${saveDirectory.path}/$id-${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      Get.snackbar(
        "Saved",
        "Image saved successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save image: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setLoadingForButton(false);
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      var permission = await Permission.storage.status;
      if (!permission.isGranted) {
        permission = await Permission.storage.request();
      }
      // For Android 13+, check photos permission if needed
      if (!permission.isGranted) {
        permission = await Permission.photos.status;
        if (!permission.isGranted) {
          permission = await Permission.photos.request();
        }
      }
      return permission.isGranted;
    } else if (Platform.isIOS) {
      var permission = await Permission.photos.status;
      if (!permission.isGranted) {
        permission = await Permission.photos.request();
      }
      return permission.isGranted;
    }
    return false;
  }

  /// Capture widget and share image
  Future<void> shareImage(
    String id,
    String url,
    GlobalKey key,
    BuildContext context,
  ) async {
    if (!isSubscribed()) {
      Get.snackbar(
        "Not Subscribed",
        "Your subscription is inactive or expired",
      );
      return;
    }

    setLoadingForButton(true);

    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) throw "Failed to capture image";

      Uint8List pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$id.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Check out this image!");
    } catch (e) {
      Get.snackbar("Error", "Failed to share image: $e");
    } finally {
      setLoadingForButton(false);
    }
  }
}
