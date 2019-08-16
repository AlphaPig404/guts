import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gut/pages/movieList.dart';
import 'package:gut/pages/recordVideo.dart';
import 'package:gut/pages/home.dart';
import 'package:gut/pages/login.dart';
import 'package:gut/pages/register.dart';
import 'package:gut/pages/videoEdit.dart';
import 'package:gut/pages/watchRoom2.dart';
import 'package:gut/utils/common.dart';
import 'package:gut/utils/movieDir.dart';
import 'package:gut/model/localVideo.dart';
import 'package:gut/pages/TopUp.dart';
import 'package:gut/pages/WatchVideoList.dart';
import 'package:gut/pages/PlayVideo.dart';
import 'model/user.dart';
import 'dart:convert' as JSON;


const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: null,
    statusBarColor: null,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
);

const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: null,
    statusBarColor: null,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
);

void main() async {
  await MovieDir().init();
  final storage = FlutterSecureStorage();
  String value = await storage.read(key: 'user');
  Widget _indexPage; 
  if(value != null && value.isNotEmpty){
	_indexPage = HomePage();
	Common.user = User.fromJson(JSON.jsonDecode(value));
  }else{
	_indexPage = LoginPage();
  }
  runApp(Gut(home: _indexPage));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class Gut extends StatelessWidget{
   Gut({this.home});
   final Map<String, WidgetBuilder> routes= <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/register': (BuildContext context) => new RegisterPage(),
        '/home': (BuildContext context) => new HomePage(),
		'/recordVideo': (BuildContext context) => new RecordPage(),
		'/movieList': (BuildContext context) => new MovieListPage(),
		'/watchRoom': (BuildContext context) => new WatchRoomPage(),
    '/topup': (BuildContext context) => new TopUp(),
    '/playVideo': (BuildContext context) => new PlayVideo(),
    '/watchVideoList': (BuildContext context) => new WatchVideoList(),
  };
  final Widget home;
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 43, 43, 48),
        accentColor: Colors.cyan[600],
        // fontFamily: 'SFUIDisplay',

        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
          body1: TextStyle(fontSize: 15.0),
          body2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
        ),
      ),
	  onGenerateRoute: (RouteSettings settings){
		  switch (settings.name){
			 case '/videoEdit':
			 	final LocalVideo args = settings.arguments;
			 	return MaterialPageRoute(builder: (context)=>VideoEditPage(localVideo: args));
			 default: 
			 	return MaterialPageRoute(builder: routes[settings.name]);
		  }
	  },
      home: home
    );
  }
}
