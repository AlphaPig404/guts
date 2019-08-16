import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './PlayVideo.dart';


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
      datalist:[1,2,3,4,5,6,7];
    });
  }

  void _testclick(index){
    print('正在点击第${index}个box');
    Navigator.push(context, new MaterialPageRoute(builder: (context) {return new PlayVideo();}));
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
    
    // print('设备宽度:${ScreenUtil.screenWidth}'); //Device width
    // print('设备高度:${ScreenUtil.screenHeight}'); //Device height
    // print('实际宽度的dp与设计稿px的比例:${ScreenUtil.getInstance().scaleWidth}');
    // print('实际高度的dp与设计稿px的比例:${ScreenUtil.getInstance().scaleHeight}');
    
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
                onTap: ()=> _testclick(indexnum),
              ),
              Positioned(
                left:ScreenUtil.getInstance().setWidth(10),
                bottom: ScreenUtil.getInstance().setWidth(10),
                child: Text("wo shi kakaxi",style: TextStyle(
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
                itemCount: 40,
                padding:EdgeInsets.all(paddingNum),
                itemBuilder: (context, index) {
                  print('这是inde的显示:${index}');
                  return _itemLi(index);
                },
              ),
      ),
      
    );
  }
}

