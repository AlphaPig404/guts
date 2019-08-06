import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:video_player/video_player.dart';

class WatchRoomPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WatchRoomState();
  }
}

class WatchRoomState extends State<WatchRoomPage> {
//   VideoPlayerController _currentController;
//   Future<void> _initializeVideoPlayerFuture;
  List<String> videoList = [
    'assets/videos/1564985072455986.mp4',
    'assets/videos/1564985192679807.mp4',
    'assets/videos/1564985217646970.mp4',
    'assets/videos/1564985233887636.mp4'
  ];
  List<VideoPlayerController> _controllerList = [];
  List<Future<void>> _initializeVideoPlayerFutureList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    initController(videoList);
    super.initState();
  }

  void initController(newVideos) {
    videoList.asMap().forEach((index, path) {
      final VideoPlayerController controller =
          VideoPlayerController.asset(path);
      final Future<void> initializeVideoPlayerFuture = controller.initialize();
      controller.setLooping(true);
      _controllerList.add(controller);
      _initializeVideoPlayerFutureList.add(initializeVideoPlayerFuture);
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controllerList.forEach((controller) => controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return buildVideoList(context, index);
        },
        itemCount: videoList.length,
        scrollDirection: Axis.vertical,
        onIndexChanged: (index) {
          if (index == videoList.length - 1) {
            initController(videoList.sublist(0, 4));
            videoList.addAll(videoList.sublist(0, 4));
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
    final VideoPlayerController _controller = _controllerList[index];
    final Future<void> _initializeVideoPlayer =
        _initializeVideoPlayerFutureList[index];
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
			height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: _initializeVideoPlayer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_currentIndex == index) {
                    _controllerList[index].seekTo(Duration(seconds: 0));
                    _controllerList[index].play();
                  } else {
                    _controllerList[index].pause();
                  }
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          onTap: () {
            _controller.value.isPlaying
                ? _controllerList[_currentIndex].pause()
                : _controllerList[_currentIndex].play();
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
			  Text('')
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
