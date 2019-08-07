import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gut/pages/videoEdit.dart';
import 'package:gut/utils/common.dart';
import 'package:gut/model/localVideo.dart';

List<CameraDescription> cameras = [];

class RecordPage extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<RecordPage> with WidgetsBindingObserver {
  CameraController controller;
  bool _isReady = false;
  int camerasIndex = 1;
  bool isRecording = false;
  Timer _countdownTimer;
  double _progereeRate = 0.0;
  int _millisecondsCounter = 0;
  LocalVideo localVideo;
  String _segmentVideoPath;
  String _segmentVideoName;
  Segment _segmentVideo;
  final int limitSeconds = 15;
  final int _millisecondsStep = 17;
  final String videoName = DateTime.now().millisecondsSinceEpoch.toString();

  bool get isPause {
    return !isRecording && localVideo.segments.isNotEmpty;
  }

  int get _counter {
    return _millisecondsCounter;
  }

  set _counter(int count) {
    _millisecondsCounter = count;
    _progereeRate = _millisecondsCounter / (limitSeconds * 1000);
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
        segments: [],
        duration: 0.0,
        targetDuration: limitSeconds);
  }

  void _setupCameras() {
    print('_setupCamners');
    print(cameras.length);
    if (cameras.length > 0) {
      onNewCameraSelected(camerasIndex);
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        availableCameras().then((_cameras) {
          print('ok');
          cameras = _cameras;
          if (cameras.length > 0) {
            onNewCameraSelected(camerasIndex);
          } else {
            print('Error: avialibelCameras');
          }
        });
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
          duration: _counter / 1000 - localVideo.duration);
      setState(() {
        localVideo.pushSement(_segmentVideo);
      });
    } on CameraException catch (e) {
      print('CameraException$e');
      return null;
    }
  }

  void _initTimer() {
    if (_countdownTimer != null) {
      return;
    }
    _countdownTimer =
        Timer.periodic(Duration(milliseconds: _millisecondsStep), (timer) {
      //   print('tick');
      if (_progereeRate < 1) {
        setState(() {
          _counter += _millisecondsStep;
        });
      } else {
        pauseVideo();
      }
    });
  }

  void _clearTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void pauseVideo() {
    if (!isRecording) {
      return;
    }
    _clearTimer();
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
      await controller.prepareForVideoRecording();
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
            right: 10,
            top: 200,
            child: buildFileList(),
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
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          buildProgressBar(),
          Container(
            padding: EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                buildCancleButton(),
                Expanded(
                  child: Text(
                    'Sing in a full resturant',
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

  Widget buildFileList() {
    return IconButton(
      icon: Icon(Icons.filter),
      onPressed: () {
        Navigator.of(context).pushNamed('/movieList');
      },
    );
  }

  Widget buildProgressBar() {
    Widget anchor = Container(
      width: 2,
      height: 6,
      color: Colors.white,
    );
    List<Widget> buildAnchors() {
      List<Widget> list = [];
      double parentWidth = MediaQuery.of(context).size.width - 20;
      localVideo.segments.asMap().forEach((index, segment) {
        double _length = localVideo.segments
            .sublist(0, index + 1)
            .fold(0, (t, e) => t + e.duration);
        double _left = parentWidth * (_length / localVideo.targetDuration);
        list.add(Positioned(
          left: _left,
          child: anchor,
        ));
      });
      return list;
    }

    return new Container(
        height: 38,
        child: Stack(
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  PhysicalModel(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(80.0),
                    clipBehavior: Clip.antiAlias,
                    child: LinearProgressIndicator(
                      backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
                      value: _progereeRate,
                      valueColor: AlwaysStoppedAnimation(Colors.yellow[200]),
                    ),
                  ),
                  Stack(
                    children: buildAnchors(),
                  )
                ],
              ),
              height: 8,
            ),
            Positioned(
              left: 0,
              top: 10,
              child: Text(
                (_counter / 1000).toStringAsFixed(1),
                style: TextStyle(fontSize: 10),
              ),
            ),
            Positioned(
              right: 0,
              top: 10,
              child: Text(
                localVideo.targetDuration.toString(),
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ));
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
            _deleteAllSegments();
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
                _initTimer();
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
          showMyMaterialDialog(context);
        },
        child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(22),
            child: Image.asset('assets/images/icRecordingDel.png',
                fit: BoxFit.fill)));
  }

  void showMyMaterialDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content:
                new Text("Are you sure you want to delete the last segment"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  _deleteSegment();
                  Navigator.of(context).pop();
                },
                child: Text("Confirm"),
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
      _counter -= (segment.duration * 1000).toInt();
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
      _counter = 0;
      setState(() {});
    }
  }
}
