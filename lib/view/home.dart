import 'package:advertising/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:advertising/controller/home_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeController controller = Get.find<HomeController>();
  final ProfileController profileController = Get.put(
    ProfileController(),
  ); // only once
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        title: const Text("Home"),

        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/profile'),
            icon: const Icon(Icons.person),
          ),
          // IconButton(
          //   onPressed: controller.logout,
          //   icon: const Icon(Icons.logout),
          // ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // shimmer for welcome section
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // shimmer grid for images
                buildShimmerGrid(),
              ],
            ),
          );
        }

        if (controller.imagesByCategory.isEmpty) {
          return const Center(child: Text("No images found"));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!controller.isLoadingMore.value &&
                controller.hasMore.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.fetchImages(loadMore: true);
            }
            return true;
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              buildCarousel(context),

              // ✅ show welcome section at the top
              buildWelcomeSection(context),
              const SizedBox(height: 20),

              // ✅ image categories
              ...controller.imagesByCategory.entries.map((entry) {
                final category = entry.key;
                final images = entry.value;

                return ExpansionTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        final img = images[index];
                        return Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  img.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(img.subcategoryName),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
              if (controller.isLoadingMore.value)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ✅ Welcome Section (uses existing controller instance)
  Widget buildWelcomeSection(BuildContext context) {
    return Obx(() {
      if (profileController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text:
                          'Welcome${profileController.firstName.isNotEmpty ? ", ${profileController.firstName}" : ""}',
                      style: GoogleFonts.oswald(
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Discover and organize your photos and videos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  //  shimmer Grid View
  Widget buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  //Drawer
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Obx(() => Text(profileController.firstName)),
            accountEmail: Obx(() => Text(profileController.email)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                '$baseUrl${profileController.image}',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Get.back();
              Get.toNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text("Gallery"),
            onTap: () {
              Get.toNamed('/gallery');
            },
          ),

          ListTile(
            leading: const Icon(Icons.video_collection_rounded),
            title: const Text("Videos"),
            onTap: () {
              Get.back();
              Get.toNamed('/videolist'); // add your route
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  //carousal
  Widget buildCarousel(BuildContext context) {
    return Obx(() {
      if (controller.imageUrls.isEmpty &&
          controller.errorMessage.value == null) {
        // Loading state
        return Container(
          height: 210,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          ),
        );
      }

      if (controller.errorMessage.value != null ||
          controller.imageUrls.isEmpty) {
        // Error or empty state
        return Container(
          height: 220,
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value ?? 'No images available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      // ✅ Carousel with auto-scrolling + swipe
      return CarouselSlider(
        options: CarouselOptions(
          height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 16 / 9,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items: controller.imageUrls.map((url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        }).toList(),
      );
    });
  }
}
