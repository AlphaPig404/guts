import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gut/pages/example.dart';
import 'package:gut/pages/movieList.dart';
import 'package:gut/pages/recordVideo.dart';
import 'package:gut/pages/home.dart';
import 'package:gut/pages/login.dart';
import 'package:gut/pages/register.dart';
import 'package:gut/pages/videoEdit.dart';
import 'package:gut/utils/movieDir.dart';
import 'pages/welcome.dart';
import 'package:gut/model/localVideo.dart';

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
  runApp(Gut());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class Gut extends StatelessWidget{
   final Map<String, WidgetBuilder> routes= <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/register': (BuildContext context) => new RegisterPage(),
        '/home': (BuildContext context) => new HomePage(),
		'/recordVideo': (BuildContext context) => new RecordPage(),
		'/movieList': (BuildContext context) => new MovieListPage(),
  };
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
      home: new HomePage()
    );
  }
}
