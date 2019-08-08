import 'package:flutter/material.dart';
import 'dart:async';

class ActiveText extends StatefulWidget {
  ActiveText({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ActiveTextState();
  }
}

enum ActiveMode{
	processing,
	upload
}

class ActiveTextState extends State<ActiveText> {
  int _processing = 0;
  Timer _timer;
  String _prefix;
  String suffix;

  @override
  void initState() {
    super.initState();
  }

  void _initTimer() {
	_clearTimer();
	_processing = 0;
    _timer = Timer.periodic(Duration(milliseconds: 40), (timer) {
      setState(() {
        if (_processing < 100) {
          _processing++;
        }
      });
    });
  }

  void _clearTimer(){
	  _timer?.cancel();
	  _timer = null;
  }

  void start(String prefix){
	  setState(() {
		_prefix = prefix;
	  });
	  _initTimer();
  }

  @override
  Widget build(BuildContext context) {
	suffix = _processing == 100 ? 'complete!' : '$_processing%...';
    return Text('$_prefix $suffix');
  }

  @override
  void dispose() {
    _clearTimer();
    super.dispose();
  }
}
