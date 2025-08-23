import 'package:advertising/controller/gallery_controller.dart';
import 'package:advertising/view/poster.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Gallery extends StatelessWidget {
  Gallery({super.key});
  final GalleryController controller = Get.find<GalleryController>();

  @override
  Widget build(BuildContext context) {
    // Fetch initial images
    controller.fetchImages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.selectedCategory.value = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              ...controller.imagesByCategory.keys.map(
                (e) => PopupMenuItem(value: e, child: Text(e)),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.imagesByCategory.isEmpty) {
          return _shimmerGrid();
        }

        // Flatten images based on selected category
        List images = controller.selectedCategory.value == 'All'
            ? controller.imagesByCategory.values.expand((e) => e).toList()
            : controller.imagesByCategory[controller.selectedCategory.value] ??
                  [];

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoadingMore.value &&
                controller.hasMore.value &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100) {
              controller.fetchImages(loadMore: true);
            }
            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length + (controller.isLoadingMore.value ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= images.length) return _shimmerTile();
              final img = images[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => Poster(image: img));
                },
                child: Image.network(img.imageUrl, fit: BoxFit.cover),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _shimmerTile(),
    );
  }

  Widget _shimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }
}
