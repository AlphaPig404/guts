import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './PlayVideo.dart';
import 'package:gut/utils/common.dart';
import 'package:gut/utils/api.dart';
import 'package:gut/model/videoInfo.dart';




class WatchVideoList extends StatefulWidget {
  @override 
  State<StatefulWidget> createState() {
    return WatchVideoListState();
  }
}

class WatchVideoListState extends State<WatchVideoList> {
  List datalist = [];
  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      datalist:[];
    });
    getVideoList(4);
  }

   void getVideoList(int challengeId) async{
      var responsedata = await Common.dio.get('${Apis.getVideoList}?challenge_id=4');
      // List _challengeList = response.data;
      setState((){
        datalist  = responsedata.data;
      });
      // print("===============");
      // print(datalist);
      // print("===============");
    
  }

  void _testclick(context,data){
    // print(data);
    // VideoInfo data_s = VideoInfo(data['host_id'], data['challenge_id'], data['video_id'], data['video_url'], data['votes']);
    // print(data_s);
    Navigator.pushNamed(context, '/playVideo',arguments: Pepole("xiongben", 26));
   
    // Navigator.of(context).pushNamed('/playVideo',arguments: Pepole("xiongben", 26));
    // Navigator.push(context, new MaterialPageRoute(builder: (context) {return new PlayVideo();}));
    // showDialog(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (context) => dialogWidget("ooo"),
    // );
    
  }

  void _voteClick(params){
    print("========vote=====");
  }

  Widget dialogWidget(data){
    return AlertDialog(
        title: Text('Dialog'),
        content: Text(('Dialog content..')),
        actions: <Widget>[
          new FlatButton(
            child: new Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    double paddingNum = ScreenUtil.getInstance().setWidth(8);
    double itemRadius = ScreenUtil.getInstance().setWidth(5);
    
    Pepole ss=ModalRoute.of(context).settings.arguments;
    print("===============");
    print(ss);
    print("===============");


    Widget _itemLi(indexnum){
       return Container(
          width: ScreenUtil.getInstance().setWidth(175),
          height: ScreenUtil.getInstance().setWidth(175),
          color: Colors.red,
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(itemRadius),
          // ),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                      image: ExactAssetImage('assets/images/btLiveGiftSpecialNormal.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: ()=> _testclick(context,datalist[indexnum]),
              ),
              Positioned(
                left:ScreenUtil.getInstance().setWidth(10),
                bottom: ScreenUtil.getInstance().setWidth(10),
                child: Text("user name",style: TextStyle(
                  color:Colors.white,
                  fontSize: ScreenUtil.getInstance().setWidth(14),
                ),),
              ),
              Positioned(
                right:ScreenUtil.getInstance().setWidth(10),
                top: ScreenUtil.getInstance().setWidth(10),
                child: Text("30 min ago",style: TextStyle(
                  color:Colors.white,
                  fontSize: ScreenUtil.getInstance().setWidth(14),
                ),),
              ),
            ],
          ),
       );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Page"),
        backgroundColor: const Color.fromRGBO(43,43,48,1),
      ),
      body: Container(
        color: const Color.fromRGBO(43,43,48,1),
        child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: ScreenUtil.getInstance().setWidth(8),
                  mainAxisSpacing: ScreenUtil.getInstance().setWidth(8),
                ),
                itemCount: datalist.length,
                padding:EdgeInsets.all(paddingNum),
                itemBuilder: (context, index) {
                  return _itemLi(index);
                },
              ),
      ),
      
    );
  }
}

