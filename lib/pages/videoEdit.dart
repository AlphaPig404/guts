import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:gut/model/localVideo.dart';
import 'dart:async';
import 'package:gut/components/activeText.dart';

final GlobalKey<ActiveTextState> _textKey = GlobalKey<ActiveTextState>();

class VideoEditPage extends StatefulWidget {
  VideoEditPage({@required this.localVideo});

  final LocalVideo localVideo;

  @override
  createState() => VideoEditPageState();
}

class VideoEditPageState extends State<VideoEditPage> {
  VideoPlayerController _currentController;
  List<VideoPlayerController> _controllerList = [];
  int currentIndex = 0;
  List<Segment> segments;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    segments = widget.localVideo.segments;
    _initController();
  }

  void _initController() {
    segments.asMap().forEach((i, segment) {
      final File file = File(segments[i].path);
      VideoPlayerController controller = VideoPlayerController.file(file);
      controller.setLooping(false);
      if (currentIndex != i) {
        controller.initialize();
      }
      controller.addListener(videoListener);
      _controllerList.add(controller);
    });
    _currentController = _controllerList[currentIndex];
    _currentController.initialize().then((ov) {
      print('$currentIndex');
      setState(() {
        _currentController.play();
      });
    });
  }

  void videoListener() {
    if (_currentController == null ||
        _currentController.value == null ||
        _currentController.value.position == null ||
        _currentController.value.duration == null) {
      return;
    }
    if (_currentController.value.position.inSeconds ==
        _currentController.value.duration.inSeconds) {
      print('over');
      setState(() {
        currentIndex = (currentIndex + 1) % segments.length;
        _currentController = _controllerList[currentIndex];
      });
      if (_currentController.value.position.inSeconds ==
          _currentController.value.duration.inSeconds) {
        _currentController.seekTo(Duration(seconds: 0));
      } else {
        _currentController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build ${_currentController.value.initialized}');
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    Widget _buildUploadButton(BuildContext _context) {
      return IconButton(
        icon: Icon(Icons.cloud_upload),
        onPressed: () {
          if (_uploading) {
            return;
          }
          setState(() {
            _uploading = true;
          });
          final ActiveText activeText = ActiveText(key: _textKey);
          final SnackBar snackBar = SnackBar(
            duration: Duration(minutes: 1),
            content: activeText,
            action: SnackBarAction(
              label: 'Confirm',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          );
          Scaffold.of(_context).showSnackBar(snackBar);
          Future.delayed(Duration(milliseconds: 20), () {
            _textKey.currentState.start('Proccess');
            widget.localVideo.concatSegments().then((ret) {
              if (ret == 0) {
                print('upload');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              }
            });
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        actions: <Widget>[
          Builder(builder: (_context) => _buildUploadButton(_context))
        ],
      ),
      body: _currentController.value.initialized
          ? Container(
              child: Transform.scale(
              scale: _currentController.value.aspectRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _currentController.value.aspectRatio,
                  child: VideoPlayer(_currentController),
                ),
              ),
            ))
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    _controllerList.forEach((controller) => controller?.dispose());
  }
}
