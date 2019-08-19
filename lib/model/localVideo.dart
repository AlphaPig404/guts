import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:io';
import 'package:gut/utils/common.dart';

class LocalVideo {
  String name;
  String path;
  String coverImage;
  double duration;
  List<Segment> segments = [];
  int targetDuration;
  int challengId;
  static FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  LocalVideo(
      {String name,
      String path,
      double duration,
      List<Segment> segments,
      int targetDuration,
      int challengId,
      String coverImage}) {
    this.name = name;
    this.path = path;
    this.duration = duration;
    this.segments = segments;
    this.targetDuration = targetDuration;
    this.challengId = challengId;
    this.coverImage = coverImage;
  }

  Segment popSegment() {
    Segment segment = this.segments.removeLast();
    this.duration -= segment.duration;
    return segment;
  }

  void pushSement(Segment segment) {
    this.segments.add(segment);
    this.duration += segment.duration;
  }

  bool isCompleted() {
    return this.duration >= this.targetDuration;
  }

  void clear() {
    this.segments.clear();
    this.duration = 0;
  }

  Future<int> concatSegments() async {
    if (segments.isEmpty) {
      return 1;
    }
    final String inputFileName = '${Common.cache.path}/$name.txt';
    File inputFile = File(inputFileName);
    IOSink ism = inputFile.openWrite();
    segments.forEach((segment) {
      ism.write('file ${segment.path}\n');
    });
    await ism.flush();
    await ism.close();
    await _flutterFFmpeg.execute("-f concat -safe 0 -i $inputFileName $path");
    final int middleTime = duration ~/ 2;
    await _flutterFFmpeg
        .execute("-ss $middleTime -i $path -y -f mjpeg -vframes 1 $coverImage");
    return 0;
  }
}

class Segment {
  String name;
  String path;
  double duration;

  Segment({String name, String path, double duration}) {
    this.name = name;
    this.path = path;
    this.duration = duration;
  }
}
