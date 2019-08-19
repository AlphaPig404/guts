import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import './../utils/common.dart';
import 'dart:async';
import 'package:gut/model/videoInfo.dart';


class TopUp extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return TopUpState();
  }
}

class TopUpState extends State<TopUp> {
  
  final testurl = "http://127.0.0.1:3001/flutter";
  List  dataList;
  @override
  void initState() {
    super.initState();
    dataList = [1,2,3,4];
    // gethttp();
  }
  
  void gethttp() async {
    
    try{
      var response = await Dio().get(testurl);
      Timer(new Duration(seconds: 3), 
        (){
          print("====6666==666=====");
          setState((){
            dataList=response.data['data'];
          });
        }
      );
      // setState((){
      //   dataList=[1,2,3];
      // });
      print(response.data['data']);
    } catch (e) {
      print(e);
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    // double paddingNum = ScreenUtil.getInstance().setWidth(15);
    double maxradiusNum = ScreenUtil.getInstance().setWidth(10);
    double minradiusNum = ScreenUtil.getInstance().setWidth(5);

    var datalistlen = dataList.length;
    print('datalist:${dataList}');

    Widget coinsItem(data) {
     Widget dialogWidget(data){
        return AlertDialog(
            title: Text('Top up'),
            content: Text(('Top up ${data['num']} coins ')),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Concerl"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
      }
      Widget box =  Container(
        width: ScreenUtil.getInstance().setWidth(165),
        height: ScreenUtil.getInstance().setWidth(100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(maxradiusNum),
          border: Border.all(color: Color.fromRGBO(231, 231, 238, 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Container(
              width: ScreenUtil.getInstance().setWidth(154),
              height: ScreenUtil.getInstance().setWidth(89),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(minradiusNum),
                border: Border.all(color: Color.fromRGBO(231, 231, 238, 1)),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: ScreenUtil.getInstance().setWidth(10),
                    top: ScreenUtil.getInstance().setWidth(12),
                    child: Image.asset(
                    'assets/images/ios-11-topupcoins-coins.png',
                    width: ScreenUtil.getInstance().setWidth(21),
                    height: ScreenUtil.getInstance().setWidth(21),
                    ),
                  ),
                  Positioned(
                    left: ScreenUtil.getInstance().setWidth(41),
                    top: ScreenUtil.getInstance().setWidth(10),
                    child: Text('${data['num']}',
                    style:TextStyle(
                      fontSize: ScreenUtil.getInstance().setWidth(24),
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                  Positioned(
                    right: ScreenUtil.getInstance().setWidth(11),
                    bottom: ScreenUtil.getInstance().setWidth(10),
                    child: Text("1.48 GB",
                    style:TextStyle(
                      fontSize: ScreenUtil.getInstance().setWidth(16),
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(236, 44, 122, 1),
                    )),
                  ),
                ],
              ),
            ),
          ],
        )
      );
      return GestureDetector(
        child: box,
        onTap: (){
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => dialogWidget(data),
          );
          // gethttp();
        },
      );
    }

    

    Widget mainpage() {
         return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: ScreenUtil.getInstance().setWidth(375),
            height: ScreenUtil.getInstance().setWidth(100),
            // color: Colors.blue,
            child: Stack(
              children: <Widget>[
                Positioned(
                   left: ScreenUtil.getInstance().setWidth(20),
                   top: ScreenUtil.getInstance().setWidth(18),
                   child: Image.asset(
                   'assets/images/ios-11-topupcoins-big-coins.png',
                   width: ScreenUtil.getInstance().setWidth(64),
                   height: ScreenUtil.getInstance().setWidth(64),
                   ),
                ),
                Positioned(
                  left: ScreenUtil.getInstance().setWidth(104),
                  top: ScreenUtil.getInstance().setWidth(25),
                  child: Text("827",
                  style:TextStyle(
                    fontSize: ScreenUtil.getInstance().setWidth(34),
                    fontWeight: FontWeight.w800,
                  )),
                ),
                Positioned(
                  left: ScreenUtil.getInstance().setWidth(104),
                  top: ScreenUtil.getInstance().setWidth(60),
                  child: Text("My coins",
                  style:TextStyle(
                    fontSize: ScreenUtil.getInstance().setWidth(12),
                    // fontWeight: FontWeight.w800,
                  )),
                ),
              ],
            ),
          ),
          Container(
            // color: Colors.yellow,
            child: Wrap(
              spacing: ScreenUtil.getInstance().setWidth(15),
              runSpacing: ScreenUtil.getInstance().setWidth(15),
              alignment: WrapAlignment.start,
              children: <Widget>[
                coinsItem({'num':100}),
                coinsItem({'num':200}),
                coinsItem({'num':300}),
                coinsItem({'num':500}),
                coinsItem({'num':1000})
              ],
            ),
          ),
        ],
        );
      }

    Widget initdom(){
       print('this is datalistlen:${datalistlen}');
       if(datalistlen>0){
         return mainpage();
       }else{
         return Loading();
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Top Up"),
        backgroundColor: const Color.fromRGBO(43,43,48,1),
      ),
      body: initdom(),
    );
  }

}