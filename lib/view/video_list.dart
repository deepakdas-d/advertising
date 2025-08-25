import 'package:advertising/controller/video_list_controller.dart';
import 'package:advertising/view/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoListController controller = Get.find<VideoListController>();

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          splashRadius: 24,
          tooltip: 'Back',
        ),
        title: Obx(
          () => AnimatedOpacity(
            opacity: controller.searchQuery.value.isEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Video Gallery',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.searchQuery.value.isEmpty
                    ? Icons.search_rounded
                    : Icons.close,
                color: Colors.white,
              ),
            ),
            splashRadius: 24,
            tooltip: controller.searchQuery.value.isEmpty
                ? 'Search'
                : 'Close Search',
            onPressed: () {
              if (controller.searchQuery.value.isNotEmpty) {
                controller.clearSearch();
              } else {
                controller.searchQuery.value = 'searching';
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            splashRadius: 24,
            tooltip: 'Refresh',
            onPressed: controller.fetchVideos,
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.searchQuery.value.isEmpty ? 0.0 : 60.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: controller.searchQuery.value.isEmpty
                  ? const SizedBox.shrink()
                  : _buildSearchBar(controller),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.fetchVideos,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: controller.standardPadding,
                  horizontal: controller.standardPadding,
                ),
                child: _buildCategoryChips(controller),
              ),
              Expanded(child: _buildVideosGrid(controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(VideoListController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textColor),
        decoration: InputDecoration(
          hintText: 'Search videos...',
          hintStyle: GoogleFonts.poppins(
            color: AppTheme.subtitleColor,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppTheme.subtitleColor,
                      size: 18,
                    ),
                    onPressed: controller.clearSearch,
                  )
                : const SizedBox.shrink(), // returns an empty widget
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(VideoListController controller) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(
              () => ChoiceChip(
                label: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: controller.selectedCategory.value == category
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: controller.selectedCategory.value == category
                        ? Colors.white
                        : AppTheme.textColor,
                  ),
                ),
                selected: controller.selectedCategory.value == category,
                onSelected: (selected) {
                  if (selected) {
                    controller.updateCategory(category);
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primaryColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: controller.selectedCategory.value == category
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideosGrid(VideoListController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }
      if (controller.hasError.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Something went wrong',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: GoogleFonts.poppins(
                    color: AppTheme.subtitleColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchVideos,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Retry', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        );
      }
      if (controller.videos.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_off_rounded,
                  color: AppTheme.subtitleColor,
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  'No videos available',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some videos to get started!',
                  style: GoogleFonts.poppins(
                    color: AppTheme.subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final filteredVideos = controller.filteredVideos;
      if (filteredVideos.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  color: AppTheme.subtitleColor,
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different search terms',
                  style: GoogleFonts.poppins(
                    color: AppTheme.subtitleColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.clearSearch,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Clear Search', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: controller.standardPadding),
        child: AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredVideos.length,
            itemBuilder: (context, index) {
              final videoData = filteredVideos[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CompactVideoCard(
                        videoData: videoData,
                        videoId: videoData['id'].toString(),
                        borderRadius: controller.cardBorderRadius,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class CompactVideoCard extends StatelessWidget {
  final Map<String, dynamic> videoData;
  final String videoId;
  final double borderRadius;

  const CompactVideoCard({
    super.key,
    required this.videoData,
    required this.videoId,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final videoUrl = videoData['video_url'] as String? ?? '';
    final title = videoData['video_name'] as String? ?? 'Untitled';
    final category = videoData['category'] as String? ?? 'Uncategorized';
    final youtubeId = _extractYouTubeId(videoUrl);
    final cardWidth = MediaQuery.of(context).size.width.clamp(0.0, 360.0);

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            if (youtubeId.isNotEmpty) {
              Get.to(() => VideoPlayer(videoId: youtubeId, title: title));
            } else {
              _showErrorSnackBar(context, 'Invalid YouTube video link');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildThumbnail(youtubeId),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String youtubeId) {
    if (youtubeId.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey,
              size: 32,
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.videocam_off_rounded, color: Colors.grey, size: 32),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.redAccent,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 8,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  String _extractYouTubeId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'] ?? '';
      }
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
