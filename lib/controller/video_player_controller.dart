import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:no_screenshot/no_screenshot.dart';

class VideoPlayerController extends GetxController {
  final String videoId;
  final String title;
  late YoutubePlayerController youtubeController;
  final RxBool isFullScreen = false.obs;
  final RxString currentQuality = 'auto'.obs;
  final List<String> availableQualities = ['auto', '360p', '720p'];
  VideoAudioHandler? audioHandler;

  VideoPlayerController({required this.videoId, required this.title});

  @override
  void onInit() {
    super.onInit();
    NoScreenshot.instance.screenshotOff();
    youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    );
    youtubeController.addListener(_onPlayerValueChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudioSession();
    });
  }

  Future<void> _initializeAudioSession() async {
    debugPrint('VideoPlayerScreen: Initializing audio session');
    try {
      final session = await AudioSession.instance;

      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
        ),
      );

      final activated = await session.setActive(true);
      debugPrint('VideoPlayerScreen: Audio session activated=$activated');

      // Make sure your audioHandler is initialized somewhere before this
      // e.g., audioHandler = await AudioService.init(...);
      final trimmedVideoId = videoId.trim();
      final trimmedTitle = title.trim();

      if (trimmedVideoId.isNotEmpty && trimmedTitle.isNotEmpty) {
        debugPrint(
          'VideoPlayerScreen: Updating MediaItem with videoId=$trimmedVideoId, title=$trimmedTitle',
        );
        audioHandler!.updateMediaItem(
          MediaItem(
            id: trimmedVideoId,
            title: trimmedTitle,
            artist: 'YouTube',
            duration: null,
          ),
        );
      } else {
        debugPrint(
          'Error: Invalid inputs - videoId: "$trimmedVideoId", title: "$trimmedTitle"',
        );
      }

      // Sync playback state between AudioService and YouTube controller
      audioHandler!.playbackState.listen((state) {
        debugPrint(
          'VideoPlayerScreen: Playback state changed - playing=${state.playing}',
        );
        if (state.playing && !youtubeController.value.isPlaying) {
          debugPrint('VideoPlayerScreen: Playing video');
          youtubeController.play();
        } else if (!state.playing && youtubeController.value.isPlaying) {
          debugPrint('VideoPlayerScreen: Pausing video');
          youtubeController.pause();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing AudioService: $e\n$stackTrace');
    }
  }

  void _onPlayerValueChange() {
    if (audioHandler != null) {
      final newState = PlaybackState(
        playing: youtubeController.value.isPlaying,
        controls: [
          youtubeController.value.isPlaying
              ? MediaControl.pause
              : MediaControl.play,
          MediaControl.stop,
        ],
        processingState:
            youtubeController.value.playerState == PlayerState.buffering
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
      );
      if (newState != audioHandler!.playbackState.value) {
        debugPrint(
          'VideoPlayerScreen: Updating playback state - playing=${newState.playing}',
        );
        audioHandler!.playbackState.add(newState);
      }
    }
  }

  void skipBackward() {
    final currentPosition = youtubeController.value.position.inSeconds;
    youtubeController.seekTo(Duration(seconds: currentPosition - 10));
  }

  void skipForward() {
    final currentPosition = youtubeController.value.position.inSeconds;
    youtubeController.seekTo(Duration(seconds: currentPosition + 10));
  }

  void togglePlayPause() {
    if (youtubeController.value.isPlaying) {
      debugPrint('VideoPlayerScreen: Manual pause');
      youtubeController.pause();
      audioHandler?.pause();
    } else {
      debugPrint('VideoPlayerScreen: Manual play');
      youtubeController.play();
      audioHandler?.play();
    }
  }

  @override
  void onClose() {
    NoScreenshot.instance.screenshotOn();
    youtubeController.removeListener(_onPlayerValueChange);
    youtubeController.dispose();
    audioHandler?.stop();
    super.onClose();
  }
}

class VideoAudioHandler extends BaseAudioHandler {
  VideoAudioHandler() {
    debugPrint('VideoAudioHandler: Initialized');
  }

  @override
  Future<void> play() async {
    debugPrint('VideoAudioHandler: play() called');
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [MediaControl.pause, MediaControl.stop],
      ),
    );
  }

  @override
  Future<void> pause() async {
    debugPrint('VideoAudioHandler: pause() called');
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [MediaControl.play, MediaControl.stop],
      ),
    );
  }

  @override
  Future<void> stop() async {
    debugPrint('VideoAudioHandler: stop() called');
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  @override
  Future<void> updateMediaItem(MediaItem item) async {
    mediaItem.add(item);
  }

  @override
  Future<void> onTaskRemoved() async {
    debugPrint('VideoAudioHandler: onTaskRemoved');
    await stop();
  }

  Future<void> onNotificationClicked(bool show) async {
    debugPrint('VideoAudioHandler: Notification clicked, show=$show');
  }

  Future<void> onMediaButtonEvent(MediaButton button) async {
    debugPrint('VideoAudioHandler: MediaButton event: $button');

    // Only one case exists currently: MediaButton.media
    if (playbackState.value.playing) {
      await pause();
    } else {
      await play();
    }
  }
}
