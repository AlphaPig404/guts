import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gut/pages/home.dart';
import 'package:gut/pages/login.dart';
import 'package:gut/pages/register.dart';
import 'pages/welcome.dart';

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

void main(){
  runApp(Gut());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class Gut extends StatelessWidget{
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
          body2: TextStyle(fontSize: 16.0)
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/register': (BuildContext context) => new RegisterPage(),
        '/home': (BuildContext context) => new HomePage()
      },
      home: new LoginPage()
    );
  }
}