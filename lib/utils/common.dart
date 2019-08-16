import 'dart:io';
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
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options) async{
	  if(options.path == Apis.login || options.path == Apis.getCode || options.path == Apis.refreshAccessToken){
		return options; 
	  }else{
		// options.path += '?uid=${Common.user.uid}';
		// options.headers["Authorization"] = Common.user.accessToken;
	  }
	  print(options.path);
      return options;
  }));
  return dio;
}

class Common {
  static final String movieAbsolutePath = 'Movies';
  static final String cacheAbsolutePath = 'Cache';
  static Directory movieDir;
  static Directory cache;
  static final Dio dio = initDio();
  static User user;
}

class ResponseError {}
