import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
          child: new Stack(
            children: <Widget>[
              Container(
                child: new Swiper(
                      itemBuilder: (BuildContext context,int index){
                        return new Image.network("http://via.placeholder.com/375x667",fit: BoxFit.fill,);
                      },
                      itemCount: 3,
                      pagination: new SwiperPagination()
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                alignment: Alignment.topCenter,
                child: new Text('Welcome to GUTS'),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      child: new RaisedButton(
                        child: new Text('Login'),
                        onPressed: (){
                          print('login');
                          Navigator.of(context).pushNamed('/login');
                        },
                      ),
                    ),
                    Expanded(
                      child: new RaisedButton(
                        child: new Text('Register'),
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        )
    );
  }
}
