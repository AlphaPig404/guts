import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gut/components/progressBar.dart';
import 'package:gut/model/challenge.dart';
import 'package:gut/utils/common.dart';
import 'package:gut/model/localVideo.dart';
import 'package:flutter/cupertino.dart';

List<CameraDescription> cameras = [];
final lpbKey = GlobalKey<LinerProgressBarState>();

class RecordPage extends StatefulWidget {
  RecordPage({this.challenge});
  final Challenge challenge;
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<RecordPage> with WidgetsBindingObserver {
  CameraController controller;
  LinerProgressBar linerProgressBar;
  bool _isReady = false;
  int camerasIndex = 1;
  bool isRecording = false;
  LocalVideo localVideo;
  String _segmentVideoPath;
  String _segmentVideoName;
  Segment _segmentVideo;
  final int limitSeconds = 15;
  final String videoName = DateTime.now().millisecondsSinceEpoch.toString();

  bool get isPause {
    return !isRecording && localVideo.segments.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('initState');
    _setupCameras();
    _initLocalVideo();
  }

  void _initLocalVideo() {
    localVideo = LocalVideo(
        name: videoName,
        path: '${Common.movieDir.path}/$videoName.mp4',
		coverImage: '${Common.imgDir.path}/$videoName.jpg',
        segments: [],
        duration: 0.0,
		challengId: widget.challenge.id,
        targetDuration: limitSeconds);
    linerProgressBar = LinerProgressBar(
      localVideo: localVideo,
      key: lpbKey,
      pauseVideo: this.pauseVideo,
    );
  }

  void _setupCameras() {
    print('_setupCamners');
    print(cameras.length);
    if (cameras.length > 0) {
      onNewCameraSelected(camerasIndex);
    } else {
      availableCameras().then((_cameras) {
        print('ok');
        cameras = _cameras;
        if (cameras.length > 0) {
          onNewCameraSelected(camerasIndex);
        } else {
          print('Error: avialibelCameras');
        }
      });
    }
  }

  Future<String> _startVideoRecording() async {
    if (!controller.value.isInitialized || controller.value.isRecordingVideo) {
      print('Error: controller issue');
      return '';
    }
    print('${localVideo.segments.length}');
    _segmentVideoName = '${videoName}_segment_${localVideo.segments.length}';
    _segmentVideoPath = '${Common.movieDir.path}/$_segmentVideoName.mp4';
    try {
      await controller.startVideoRecording(_segmentVideoPath);
    } on CameraException catch (e) {
      print('CameraException:$e');
      return '';
    }
    return _segmentVideoPath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    try {
      await controller.stopVideoRecording();
      _segmentVideo = Segment(
          name: '${videoName}_segment_${localVideo.segments.length}',
          path: _segmentVideoPath,
          duration: lpbKey.currentState.counter / 1000 - localVideo.duration);
      setState(() {
        localVideo.pushSement(_segmentVideo);
      });
    } on CameraException catch (e) {
      print('CameraException$e');
      return null;
    }
  }

  void pauseVideo() {
    if (!isRecording) {
      return;
    }
    lpbKey.currentState.clearTimer();
    setState(() {
      isRecording = false;
    });
    _stopVideoRecording().then((_) {
      if (localVideo.isCompleted()) {
        print('complete recording');
        jump2EditPage();
      } else {
        print('pause recording');
      }
    });
  }

  void jump2EditPage() {
    Navigator.of(context).pushNamed('/videoEdit', arguments: localVideo);
  }

  void onNewCameraSelected(int index) async {
    if (controller != null) {
      print('dispose');
      await controller.dispose();
    }
    controller = CameraController(
      cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      //   if (mounted) setState(() {});
      print('controler');
    });

    try {
      await controller.initialize();
    } on CameraException catch (_) {}

    if (mounted) {
      setState(() {
        camerasIndex = index;
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    pauseVideo();
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('StateChange:${state.index}');
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      print('inactive');
    } else if (state == AppLifecycleState.resumed) {
      print('resumed');
      if (controller != null) {
        onNewCameraSelected(camerasIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build all');
    if (!_isReady || !controller.value.isInitialized) {
      return Center();
    }
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Material(
      child: Stack(
        children: <Widget>[
          Transform.scale(
            scale: controller.value.aspectRatio / deviceRatio,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
          Positioned(
            top: 35,
            child: buildHeader(),
          ),
          Positioned(
            bottom: 14,
            child: buildFooter(),
          )
        ],
      ),
    );
  }

  Widget buildHeader() {
	final challenge = widget.challenge;
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          linerProgressBar,
          Container(
            padding: EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                buildCancleButton(),
                Expanded(
                  child: Text(
                    challenge.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
                buildCanmareSwitchButton()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildFooter() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isPause ? buildSaveButton() : Container(height: 0.0, width: 0.0),
          buildRecordButton(),
          isPause ? buildClearButton() : Container(height: 0.0, width: 0.0),
        ],
      ),
    );
  }

  Widget buildCancleButton() {
    return GestureDetector(
        onTap: () {
          print('cancel');
          if (localVideo.segments.isEmpty) {
            Navigator.of(context).pop();
          } else {
            showCancelDialog(context);
          }
        },
        child: Container(
            width: 36,
            height: 36,
            padding: EdgeInsets.all(10),
            child: Image.asset('assets/images/icRecordingExit.png',
                fit: BoxFit.fill)));
  }

  Widget buildCanmareSwitchButton() {
    return GestureDetector(
        onTap: () {
          print('tapSwitchCanmera');
          onNewCameraSelected(1 - camerasIndex);
        },
        child: Container(
            width: 36,
            height: 36,
            child: Image.asset('assets/images/icRoomSwitchcamera.png',
                fit: BoxFit.fill)));
  }

  Widget buildSaveButton() {
    return GestureDetector(
        onTap: () {
          print('tapSave');
          jump2EditPage();
        },
        child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(22),
            child: Image.asset('assets/images/icRecording.png',
                fit: BoxFit.fill)));
  }

  Widget buildRecordButton() {
    return GestureDetector(
        onTap: () {
          if (isRecording) {
            pauseVideo();
          } else {
            _startVideoRecording().then((String filePath) {
              if (filePath != null) {
                lpbKey.currentState.initTimer();
                print('Saving video to $filePath');
                setState(() {
                  isRecording = true;
                });
              }
            });
          }
        },
        child: Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Image.asset(
                isRecording
                    ? 'assets/images/icRecordingPause.png'
                    : 'assets/images/icRecordingStart.png',
                fit: BoxFit.fill)));
  }

  Widget buildClearButton() {
    return GestureDetector(
        onTap: () {
          print('tapClear');
          showClearDialog(context);
        },
        child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(22),
            child: Image.asset('assets/images/icRecordingDel.png',
                fit: BoxFit.fill)));
  }

  void showClearDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: new Text(
              "Are you sure you want to delete the last segment",
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _deleteSegment();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Confirm",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          );
        });
  }

  void showCancelDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: new Text(
              "Are you sure you want to abandon the segments",
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _deleteAllSegments();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Confirm",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          );
        });
  }

  void _deleteSegment() {
    if (localVideo.segments.isNotEmpty) {
      Segment segment = localVideo.popSegment();
      if (File(segment.path).existsSync()) {
        File(segment.path).delete();
      }
      lpbKey.currentState.counter -= (segment.duration * 1000).toInt();
      setState(() {});
    }
  }

  void _deleteAllSegments() {
    if (localVideo.segments.isNotEmpty) {
      localVideo.segments.forEach((segment) {
        if (File(segment.path).existsSync()) {
          File(segment.path).delete();
        }
      });
      localVideo.clear();
      lpbKey.currentState.counter = 0;
      setState(() {});
    }
  }
}
