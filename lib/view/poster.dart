import 'dart:developer';

import 'package:advertising/controller/poster_controller.dart';
import 'package:advertising/controller/profile_controller.dart';
import 'package:advertising/model/image_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Poster extends StatelessWidget {
  final ImageModel image;
  final GlobalKey cardKey = GlobalKey();

  Poster({super.key, required this.image}) {
    // NoScreenshot.instance.screenshotOff();
  }

  final ProfileController profileController = Get.find<ProfileController>();
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosterController(), permanent: false);

    return Obx(() {
      return WillPopScope(
        onWillPop: () async {
          if (controller.isLoadingForButton.value) {
            Get.snackbar("Wait", "Download in progress...");
            return false;
          }
          // NoScreenshot.instance.screenshotOn();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              image.subcategoryName,
              style: GoogleFonts.poppins(
                color: const Color(0xFF00A19A),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: controller.isLoadingForButton.value
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      // NoScreenshot.instance.screenshotOn();
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF00A19A),
                    ),
                  ),
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPosterCard(context, controller),
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildPosterCard(BuildContext context, PosterController controller) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          RepaintBoundary(
            key: cardKey,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        fit: BoxFit.cover,
                        memCacheHeight: 1200,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.grey[300]),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.error,
                            size: 48,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: CustomPaint(
                            painter: WatermarkPainter(
                              username: profileController.firstName,
                              phone: profileController.email,
                            ),
                          ),
                        ),
                      ),
                      _buildGradientOverlay(controller),
                    ],
                  ),
                ),
                _buildUserInfo(controller),
              ],
            ),
          ),
          _buildActions(context, controller),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay(PosterController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              controller.backgroundColor.value.withOpacity(0.1),
              controller.backgroundColor.value.withOpacity(0.3),
              controller.backgroundColor.value.withOpacity(0.7),
              controller.backgroundColor.value,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(PosterController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(color: controller.backgroundColor.value),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 8),
          Expanded(child: _buildUserTextDetails()),
          if (profileController.logo.isNotEmpty) _buildCompanyLogo(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final profileImg = "$baseUrl${profileController.image}";
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: profileImg.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: profileImg,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              placeholder: (_, __) => const CircularProgressIndicator(),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.person, size: 28, color: Colors.white),
            )
          : const Icon(Icons.person, size: 28, color: Colors.white),
    );
  }

  Widget _buildUserTextDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profileController.firstName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          profileController.email,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
        Text(
          profileController.phone,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCompanyLogo() {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final logoImg = "$baseUrl${profileController.logo}";
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoImg,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const CircularProgressIndicator(strokeWidth: 1.5),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.business, size: 20, color: Colors.white70),
      ),
    );
  }

  Widget _buildActions(BuildContext context, PosterController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.download, color: Colors.white, size: 18),
                label: const Text(
                  "Download",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: controller.backgroundColor.value,
                ),
                onPressed: controller.isLoadingForButton.value
                    ? null
                    : () async {
                        if (!(await controller.isSubscribed())) {
                          _showSubscribeDialog(context, controller);
                          return;
                        }
                        controller.setLoadingForButton(true);
                        await controller.captureAndSaveImage(
                          image.id.toString(),
                          image.imageUrl,
                          cardKey,
                          context,
                        );
                        controller.setLoadingForButton(false);
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.share, color: Colors.white, size: 18),
                label: const Text(
                  "Share",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: controller.backgroundColor.value,
                ),
                onPressed: () async {
                  if (!(await controller.isSubscribed())) {
                    _showSubscribeDialog(context, controller);
                    return;
                  }
                  await controller.shareImage(
                    image.id.toString(),
                    image.imageUrl,
                    cardKey,
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show subscription dialog with WhatsApp button
  Future<void> _showSubscribeDialog(
    BuildContext context,
    PosterController controller,
  ) async {
    // check subscription before showing UI
    bool subscribed = await controller.isSubscribed();
    log("value that return is $subscribed");
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 40, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                "Subscription Required",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subscribed
                    ? "Your subscription has expired. Renew to continue using downloads and sharing."
                    : "Please subscribe to unlock downloads and sharing.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text(
                  subscribed ? "Renew via WhatsApp" : "Subscribe via WhatsApp",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  controller.redirectToWhatsApp(
                    "Premium Plan",
                    199, // make this dynamic if needed
                    "1 Month",
                    context,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class WatermarkPainter extends CustomPainter {
  final String username;
  final String phone;

  WatermarkPainter({required this.username, required this.phone});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        text: "$username | $phone",
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(size.width - tp.width - 8, size.height - tp.height - 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
