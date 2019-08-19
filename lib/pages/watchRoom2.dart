import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:video_player/video_player.dart';

class WatchRoomPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WatchRoomState();
  }
}

class VideoController {
	final String path;
	final VideoPlayerController controller;
	final Future<void> initializeVideoPlayerFuture;

	VideoController._({this.path,this.controller, this.initializeVideoPlayerFuture});

	factory VideoController(String videoPath){
	  final VideoPlayerController controller =
          VideoPlayerController.network(videoPath);
      final Future<void> initializeVideoPlayerFuture = controller.initialize();
      controller.setLooping(true);
	  return VideoController._(path: videoPath, controller: controller, initializeVideoPlayerFuture: initializeVideoPlayerFuture);
	}
}

enum SwiperGuesture{
	pull,
	push
}

class WatchRoomState extends State<WatchRoomPage> {
  List<String> videoList = [
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/2ceda7a036974a719cddc04455cc2ae7_1564985072455986.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/cfc6a214f98749cc8ac85a338d4db685_1564985192679807.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/38315d93258c4f9788ef77ee1233ef67_1564985217646970.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/abd9dcfbdeb24b4cbef2627f083bd1ee_1564985233887636.mp4',
     'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/2ceda7a036974a719cddc04455cc2ae7_1564985072455986.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/cfc6a214f98749cc8ac85a338d4db685_1564985192679807.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/38315d93258c4f9788ef77ee1233ef67_1564985217646970.mp4',
    'https://dgfbllonk2lcz.cloudfront.net/gut/video/2019/8/18/6/abd9dcfbdeb24b4cbef2627f083bd1ee_1564985233887636.mp4',
  ];

  List<VideoController> videoControllers = [];
  int cursor = 0;
  int _currentIndex = 0;
  final int _maxIndex = 4;

  @override
  void initState() {
    initController();
    super.initState();
  }

  get tailCursor{
	return cursor + _maxIndex;
  }

  get initMiddle{
	return _maxIndex~/2;
  }

  get middleIndex{
	  return (cursor + tailCursor)~/2;
  }

  bool inActiveRange(index){
	  return index >= initMiddle && index < videoList.length - initMiddle;
  }

  void initController() {
	if(videoList.isEmpty){ return ;}
	final int endCursor = videoList.length < (tailCursor + 1) ? videoList.length : (tailCursor+1);
    videoList.sublist(cursor, endCursor).forEach((videoPath){
	  final VideoController videoController =  VideoController(videoPath);
	  videoControllers.add(videoController);
	});
  }

  void updateVideoControllers({int index,SwiperGuesture direction}){
	  if(direction == SwiperGuesture.push){
		  cursor ++;
		  String videoPath = videoList[tailCursor];
		  final VideoController videoController =  VideoController(videoPath);
		  videoControllers.add(videoController);
		  final firstVideo = videoControllers.removeAt(0);
		  firstVideo.controller.dispose();
	  }
	  if(direction == SwiperGuesture.pull){
		  cursor --;
		  String videoPath = videoList[tailCursor];
		  final VideoController videoController =  VideoController(videoPath);
		  videoControllers.insert(0, videoController);
		  final lastVideo = videoControllers.removeLast();
		  lastVideo.controller.dispose();
	  }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    videoControllers.forEach((VideoController videoController) => videoController.controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
	print('build room');
    return Material(
        child: Container(
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
		  if(index >= cursor && index <= tailCursor){
			return buildVideoList(context, index);
		  }else{
			return Image.asset('assets/images/background.png');
		  }
        },
        itemCount: videoList.length,
        scrollDirection: Axis.vertical,
        onIndexChanged: (index) {
		  if(inActiveRange(index)){
			if(index > middleIndex){
				updateVideoControllers(index: index, direction: SwiperGuesture.push);
			}else if(index < middleIndex){
				updateVideoControllers(index: index, direction: SwiperGuesture.pull);
			}
		  }
          setState(() {
            _currentIndex = index;
            print(index);
          });
        },
        loop: false,
      ),
    ));
  }

  Widget buildVideoList(BuildContext context, int index) {
	final int relativeCursor = index - cursor;
	final VideoController videoController = videoControllers[relativeCursor];
    final VideoPlayerController _controller = videoController.controller;
    final Future<void> _initializeVideoPlayer =
        videoController.initializeVideoPlayerFuture;
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
			height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: _initializeVideoPlayer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
				  int _currentActiveIndex;
				  if(inActiveRange(_currentIndex)){
					  _currentActiveIndex = initMiddle;
				  }else{
					  if(_currentIndex >= videoList.length -2){
						_currentActiveIndex = videoControllers.length + _currentIndex - videoList.length;
						print(_currentActiveIndex);
					  }else{
						_currentActiveIndex = _currentIndex;
					  }
				  }
				  videoControllers[relativeCursor].controller.pause();
                  if (relativeCursor == _currentActiveIndex) {
					print('relativeCursor: $relativeCursor');
					videoControllers[relativeCursor].controller.seekTo(Duration(seconds: 0));
					videoControllers[relativeCursor].controller.play();
                  }
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          onTap: () {
            _controller.value.isPlaying
                ? videoControllers[relativeCursor].controller.pause()
                : videoControllers[relativeCursor].controller.play();
          },
        ),
		Positioned(
			bottom: 0,
			child: Container(
				width: MediaQuery.of(context).size.width,
				height: 100,
				decoration: BoxDecoration(  
					gradient: LinearGradient(  
						colors: [
							Color.fromARGB(0, 0, 0, 0),
							Color.fromARGB(76, 0, 0, 0),
						],
						begin: FractionalOffset(1, 0)
					)
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: <Widget>[
						_buildFavoriteButton(),
						_buildCommentButton(),
						_buildSharedButton(),
					],
				),
			)
		)
      ],
    );
  }

  Widget _buildFavoriteButton(){
	  return Column(
		  children: <Widget>[
			  IconButton(icon: Icon(Icons.favorite_border),onPressed: (){},),
			  Text('40.5k')
		  ],
	  );
  }

  Widget _buildSharedButton(){
	  return Column(
		  children: <Widget>[
			  IconButton(icon: Icon(Icons.share),onPressed: (){},),
			  Text('10k')
		  ],
	  );
  }

  Widget _buildCommentButton(){
	  return Column(
		  children: <Widget>[
			  IconButton(icon: Icon(Icons.comment),onPressed: (){},),
			  Text('40k')
		  ],
	  );
  }
}
