import 'package:gut/utils/common.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class MovieDir {
	factory MovieDir() => _getInstance();
	static MovieDir get instance => _getInstance();
	static MovieDir _instance ;

	MovieDir._internal(){

	}

	Future<int> init() async {
		final Directory extDir = await getApplicationDocumentsDirectory();
		final String dirPath = '${extDir.path}/${Common.movieAbsolutePath}';
		final Directory movieDir = await Directory(dirPath).create(recursive: true);
		Common.movieDir = movieDir;
		return 0;
	}

	static MovieDir _getInstance(){
		if(_instance == null){
			_instance = new MovieDir._internal();
		}
		return _instance;
	}
}