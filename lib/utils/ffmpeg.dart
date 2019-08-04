import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:io';
import 'common.dart';

class FFmpeg{
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  Future<int> concat(String videoName, List<String> pathList, String distPath) async {
    if(pathList.isEmpty){ return 1;}
    final inputFileName = '${Common.cache}/$videoName.txt';
    IOSink iw = File(inputFileName).openWrite();
    pathList.forEach((path){
      iw.writeln('file $path');
    });
    iw.close();
    await _flutterFFmpeg.execute("-f concat -i $inputFileName $distPath");
    return 0;
  }
}