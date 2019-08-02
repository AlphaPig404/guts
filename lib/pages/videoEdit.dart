import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoEditPage extends StatefulWidget {
  VideoEditPage({@required this.videoPath});

  final String videoPath;

  @override
  createState() => VideoEditPageState();
}

class VideoEditPageAguments {
  final String videoPath;
  VideoEditPageAguments(this.videoPath);
}

class VideoEditPageState extends State<VideoEditPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    print(widget.videoPath);
    _controller = VideoPlayerController.file(File(widget.videoPath));
	_controller.setLooping(true);
	_controller.initialize().then((_) {
        print('init');
		_controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    // final VideoEditPageAguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
      ),
      body: Container(
		  height: MediaQuery.of(context).size.height,
		  child: AspectRatio(
				aspectRatio: _controller.value.aspectRatio,
				child: VideoPlayer(_controller),
			),
	  ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.pause();
			print('upload');
          });
        },
        child: Icon(
          Icons.cloud_upload
        ),
		backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
