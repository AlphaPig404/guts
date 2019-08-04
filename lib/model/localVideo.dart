import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:io';
import 'package:gut/utils/common.dart';

class LocalVideo{
  String name;
  String path;
  double duration;
  List<Segment> segments=[];
  int targetDuration;
  static FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  LocalVideo({String name, String path, double duration, List<Segment> segments, int targetDuration}){
    this.name = name;
    this.path = path;
    this.duration = duration;
    this.segments = segments;
    this.targetDuration = targetDuration;
  }

  Segment popSegment(){
    Segment segment = this.segments.removeLast();
    this.duration -= segment.duration;
    return segment;
  }

  void pushSement(Segment segment){
    this.segments.add(segment);
    this.duration += segment.duration;
  }

  bool isCompleted(){
    return this.duration >= this.targetDuration ;
  }

  void clear(){
    this.segments.clear();
    this.duration = 0;
  }

  Future<int> concatSegments() async {
    if(segments.isEmpty){ return 1;}
    final inputFileName = '${Common.cache.path}/$name.txt';
    File inputFile = File(inputFileName);
    IOSink ism =inputFile.openWrite();
    segments.forEach((segment){
      ism.write('file ${segment.path}\n');
    });
    await ism.flush();
    await ism.close();
    await _flutterFFmpeg.execute("-f concat -safe 0 -i $inputFileName $path");
    return 0;
  }
}

class Segment{
  String name;
  String path;
  double duration;

  Segment({String name, String path, double duration}){
    this.name = name;
    this.path = path;
    this.duration = duration;
  }
}