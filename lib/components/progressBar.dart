import 'package:flutter/material.dart';
import 'package:gut/model/localVideo.dart';
import 'dart:async';

class LinerProgressBar extends StatefulWidget {
  final LocalVideo localVideo;
  final Function pauseVideo;
  LinerProgressBar({Key key, @required this.localVideo, @required this.pauseVideo}) :super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LinerProgressBarState();
  }
}

class LinerProgressBarState extends State<LinerProgressBar> {
  LocalVideo localVideo;
  double _progereeRate = 0.0;
  int _millisecondsCounter = 0;
  final int _millisecondsStep = 17;
  Timer _countdownTimer;

  int get counter {
    return _millisecondsCounter;
  }

  set counter(int count) {
	setState(() {
		_millisecondsCounter = count;
		_progereeRate = _millisecondsCounter / (localVideo.targetDuration * 1000);
	});
  }

  void initTimer() {
    if (_countdownTimer != null) {
      return;
    }
    _countdownTimer =
        Timer.periodic(Duration(milliseconds: _millisecondsStep), (timer) {
      //   print('tick');
      if (_progereeRate < 1) {
        setState(() {
          counter += _millisecondsStep;
        });
      } else {
        widget.pauseVideo();
      }
    });
  }

  void clearTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
	localVideo = widget.localVideo;
    return buildProgressBar();
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
                (counter / 1000).toStringAsFixed(1),
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
}
