import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class StackedVideoViewModel extends BaseViewModel {
  VideoPlayerController? videoPlayerController;

  void initialize(String videoUrl) {
    videoPlayerController = VideoPlayerController.network(videoUrl);
    videoPlayerController!.setLooping(true);
    videoPlayerController!.initialize().then((value) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }
}
