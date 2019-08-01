import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class RecordPage extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<RecordPage> with WidgetsBindingObserver {
  CameraController controller;
  bool _isReady = false;
  int camerasIndex = 1;
  bool isRecording = false;
  List<String> videoList = [];
  Timer _countdownTimer;
  double _progereeRate = 0.0;
  int _millisecondsCounter = 0;

  bool get isPause{
	  return !isRecording && videoList.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    //  WidgetsBinding.instance.addObserver(this);
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    cameras = await availableCameras();
    onNewCameraSelected(camerasIndex);
  }

  void _initTimer(){
	  if (_countdownTimer != null) {
          return;
      }
	  _countdownTimer = Timer.periodic(Duration(milliseconds: 17), (timer){
		  print('tick');
		  if(_progereeRate < 1){
			  _millisecondsCounter += 17;
			  setState(() {
			    _progereeRate= _millisecondsCounter /(60*1000);
			  });
		  }else{
			_countdownTimer.cancel();
            _countdownTimer = null;
		  }
	  });
  }

  void onNewCameraSelected(int index) async {
    if (controller != null) {
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
    controller?.dispose();
	_countdownTimer?.cancel();
    _countdownTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('haha');
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        print('lala');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    if (!_isReady || !controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Material(
          child: Stack(
            children: <Widget>[
              CameraPreview(controller),
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
        ));
  }

  Widget buildHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          buildProgressBar(),
          SizedBox(height: 30),
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

  Widget buildProgressBar() {
    return new Container(
      height: 8,
      child: new PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(80.0),
        clipBehavior: Clip.antiAlias,
        child: LinearProgressIndicator(
          backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
          value: _progereeRate,
          valueColor: AlwaysStoppedAnimation(Colors.yellow[200]),
        ),
      ),
    );
  }

  Widget buildFooter() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          isPause
              ? Positioned(
                  left: 77.5,
                  child: buildSaveButton(),
                )
              : Container(height: 0.0, width: 0.0),
          buildRecordButton(),
          isPause
              ? Positioned(
                  right: 77.5,
                  child: buildClearButton(),
                )
              : Container(height: 0.0, width: 0.0),
        ],
      ),
    );
  }

  Widget buildCancleButton() {
    return GestureDetector(
        onTap: () {
          print('tap');
        },
        child: Container(
            width: 16,
            height: 16,
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
        },
        child: Container(
            width: 36,
            height: 36,
            child: Image.asset('assets/images/icRecording.png',
                fit: BoxFit.fill)));
  }

  Widget buildRecordButton() {
    return GestureDetector(
        onTap: () {
          print('tapRecordButton');
          setState(() {
            isRecording = !isRecording;
          });
		  _initTimer();
        },
        child: Container(
            width: 80,
            height: 80,
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
        },
        child: Container(
            width: 36,
            height: 36,
            child: Image.asset('assets/images/icRecordingDel.png',
                fit: BoxFit.fill)));
  }
}
