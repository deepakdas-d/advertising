import 'package:advertising/controller/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatelessWidget {
  final String videoId;
  final String title;

  const VideoPlayer({super.key, required this.videoId, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      VideoPlayerController(videoId: videoId, title: title),
    );

    return WillPopScope(
      onWillPop: () async {
        if (controller.isFullScreen.value) {
          controller.youtubeController.toggleFullScreenMode();
          return false;
        } else {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          return true;
        }
      },
      child: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          controller.isFullScreen.value = false;
        },
        onEnterFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          controller.isFullScreen.value = true;
        },
        player: YoutubePlayer(
          controller: controller.youtubeController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF4CAF50),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF4CAF50),
            handleColor: Color(0xFF4CAF50),
          ),
          bottomActions: [
            const CurrentPosition(),
            const ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Color(0xFF4CAF50),
                handleColor: Color(0xFF4CAF50),
              ),
            ),
            const RemainingDuration(),
            IconButton(
              onPressed: controller.skipBackward,
              icon: const Icon(Icons.replay_10, color: Colors.white),
            ),
            IconButton(
              onPressed: controller.skipForward,
              icon: const Icon(Icons.forward_10, color: Colors.white),
            ),
            const FullScreenButton(),
          ],
        ),
        builder: (context, player) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Obx(
                () => controller.isFullScreen.value
                    ? const SizedBox.shrink()
                    : AppBar(
                        backgroundColor: Colors.white,
                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF00A19A),
                          ),
                          onPressed: () {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                            ]);
                            Get.back();
                          },
                        ),
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF00A19A),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        elevation: 0,
                      ),
              ),
            ),
            body: Column(
              children: [
                player,
                Obx(
                  () => !controller.isFullScreen.value
                      ? Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
