import 'package:gut/utils/common.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class MovieDir {
  factory MovieDir() => _getInstance();
  static MovieDir get instance => _getInstance();
  static MovieDir _instance;

  MovieDir._internal() {}

  Future<int> init() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String movieDirPath = '${extDir.path}/${Common.movieAbsolutePath}';
    final Directory movieDir =
        await Directory(movieDirPath).create(recursive: true);
    Common.movieDir = movieDir;

    final String cacheDirPath = '${extDir.path}/${Common.cacheAbsolutePath}';
    final Directory cacheDir =
        await Directory(cacheDirPath).create(recursive: true);
    Common.cache = cacheDir;

	final String imgDirPath = '${extDir.path}/${Common.imgAbsolutePath}';
    final Directory imgDir =
        await Directory(imgDirPath).create(recursive: true);
    Common.imgDir = imgDir;

    return 0;
  }

  static MovieDir _getInstance() {
    if (_instance == null) {
      _instance = new MovieDir._internal();
    }
    return _instance;
  }
}
