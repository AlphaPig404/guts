import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'WatchVideoList.dart';
// import 'TopUp.dart';
// import 'PlayVideo.dart';

class RegisterPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            bottom: ScreenUtil.getInstance().setWidth(100),
            left: ScreenUtil.getInstance().setWidth(200),
            child: Container(
              width: ScreenUtil.getInstance().setWidth(50),
              height:ScreenUtil.getInstance().setWidth(50),
              color: Colors.blue,
              child: GestureDetector(
                child: Container(
                  child: Text("跳转列表页"),
                ),
                onTap: (){
                  Navigator.of(context).popAndPushNamed('/watchVideoList');
                  // Navigator.push(context, new MaterialPageRoute(builder: (context) {return new WatchVideoList();}));
                },
              ),
            ),
          ),
          Positioned(
            bottom: ScreenUtil.getInstance().setWidth(400),
            left: ScreenUtil.getInstance().setWidth(200),
            child: Container(
              width: ScreenUtil.getInstance().setWidth(50),
              height:ScreenUtil.getInstance().setWidth(50),
              color: Colors.yellow,
              child: GestureDetector(
                child: Container(
                  child: Text("跳转coin列表页"),
                ),
                onTap: (){
                  Navigator.of(context).popAndPushNamed('/topup');
                  // Navigator.push(context, new MaterialPageRoute(builder: (context) {return new TopUp();}));
                },
              ),
            ),
          ),
          Positioned(
            bottom: ScreenUtil.getInstance().setWidth(400),
            left: ScreenUtil.getInstance().setWidth(100),
            child: Container(
              width: ScreenUtil.getInstance().setWidth(50),
              height:ScreenUtil.getInstance().setWidth(50),
              color: Colors.yellow,
              child: GestureDetector(
                child: Container(
                  child: Text("跳转live列表页"),
                ),
                onTap: (){
                  Navigator.of(context).popAndPushNamed('/playVideo');
                  // Navigator.push(context, new MaterialPageRoute(builder: (context) {return new PlayVideo();}));
                },
              ),
            ),
          ),
        ],
        
      ),
    );
  }
}