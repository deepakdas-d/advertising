import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PosterController extends GetxController {
  var isLoading = true.obs;
  var isLoadingForButton = false.obs;
  var backgroundColor = Colors.teal.obs;
  late bool subscribed;
  final ProfileController profileController = Get.find<ProfileController>();
  @override
  void onInit() {
    super.onInit();
    _loadImage();
    fetchSubscriptionDetails();
    isSubscribed();
    checkSubscription();
  }

  Future<Map<String, dynamic>?> fetchSubscriptionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) return null;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final profileEndpoint = dotenv.env['PROFILE_ENDPOINT'] ?? '/profile/';
      final response = await http.get(
        Uri.parse("$baseUrl$profileEndpoint"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        profileController.profile.assignAll(data); // update controller
        return data;
      } else {
        log("DEBUG: Failed to fetch profile: ${response.body}");
        return null;
      }
    } catch (e) {
      log("DEBUG: Exception fetching profile: $e");
      return null;
    }
  }

  void _loadImage() async {
    // Fake loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  void setLoadingForButton(bool value) => isLoadingForButton.value = value;

  /// Check if user has an active subscription
  Future<bool> isSubscribed() async {
    final profile = await fetchSubscriptionDetails();
    if (profile == null || profile.isEmpty) return false;

    final sub = profile['subscription'];
    if (sub == null) {
      // user has no subscription
      log("No subscription");
      return false;
    }

    final bool isActive = sub['is_active'] ?? false;
    final bool revoked = sub['revoke'] ?? true;
    log("Is Active ${sub['is_active']}");
    if (!isActive || revoked) {
      // subscription is either inactive or revoked
      return false;
    }

    final startDate = DateTime.tryParse(sub['start_date'] ?? '');
    final endDate = DateTime.tryParse(sub['end_date'] ?? '');
    final now = DateTime.now();

    if (startDate == null || endDate == null) return false;

    // only valid if now is between start and end (inclusive)
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  Future<void> checkSubscription() async {
    bool subscribed = await isSubscribed();
    print('Is subscribed: $subscribed');
  }

  Future<void> captureAndSaveImage(
    String id,
    String url,
    GlobalKey key,
    BuildContext context,
  ) async {
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

  /// Redirect user to WhatsApp for subscription or renewal
  Future<void> redirectToWhatsApp(
    String plan,
    int price,
    String duration,
    BuildContext context,
  ) async {
    const adminWhatsAppNumber = '+919496407635';

    final message =
        'Hello, I want to ${await isSubscribed() ? 'renew' : 'subscribe to'} '
        'the $plan (₹$price/$duration) for the BrandBuilder app.';

    final encodedMessage = Uri.encodeComponent(message);

    final whatsappUrl =
        'https://wa.me/$adminWhatsAppNumber?text=$encodedMessage';
    final uri = Uri.parse(whatsappUrl);

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _showSnackBar(
            context,
            'Could not open WhatsApp. Please ensure WhatsApp is installed.',
          );
        }
      } else {
        // fallback for some devices
        final fallbackUri = Uri.parse(
          'whatsapp://send?phone=$adminWhatsAppNumber&text=$encodedMessage',
        );
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        } else {
          _showSnackBar(
            context,
            'WhatsApp is not installed or cannot be opened.',
          );
        }
      }
    } catch (e) {
      _showSnackBar(context, 'Failed to open WhatsApp: $e');
      log("redirectToWhatsApp error: $e");
    }
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
