import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gut/model/user.dart';
import 'package:gut/utils/api.dart';

Dio initDio() {
  BaseOptions options = new BaseOptions(
    baseUrl: "http://10.40.16.20:8000",
    connectTimeout: 30000,
    receiveTimeout: 10000,
  );
  Dio dio = Dio(options);
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options) async {
    if (options.path == Apis.upload) {
      options.baseUrl = 'https://webapi-loopstest.shabikplus.mozat.com';
      return options;
    }
    if (options.path == Apis.login ||
        options.path == Apis.getCode ||
        options.path == Apis.refreshAccessToken) {
      return options;
    } else {
      // options.path += '?uid=${Common.user.uid}';
      // options.headers["Authorization"] = Common.user.accessToken;
    }
    print(options.path);
    return options;
  }, onResponse: (Response response) {
    return response;
  }, onError: (DioError e) {
    print(e);
  }));
  return dio;
}

class Common {
  static final String movieAbsolutePath = 'Movies';
  static final String imgAbsolutePath = 'Img';
  static final String cacheAbsolutePath = 'Cache';
  static Directory movieDir;
  static Directory cache;
  static Directory imgDir;
  static final Dio dio = initDio();
  static User user;
}

// Loading 组件
class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(43, 43, 48, 1),
      child: new Center(
        child: new Container(
          child: new Text('Loading...',
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}

// 空数据组件
class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        child: new Text('No data！',
            style: TextStyle(
              fontSize: 35,
            )),
      ),
    );
  }
}

class ResponseError {}
