import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MascotVideo extends StatefulWidget {
  final String videoPath;

  const MascotVideo({Key? key, this.videoPath = "assets/mascot_success.mp4"}) : super(key: key);

  @override
  _MascotVideoState createState() => _MascotVideoState();
}

class _MascotVideoState extends State<MascotVideo> {
  late VideoPlayerController _controller;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }


  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
