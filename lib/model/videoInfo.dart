class VideoInfo{
	 int host_id;
   int challenge_id;
   int video_id;
	 String video_url;
	 int votes;
	
	
	VideoInfo(this.host_id, this.challenge_id, this.video_id, this.video_url, this.votes);
	VideoInfo.fromJson(Map<String, dynamic> json)
      : host_id = json['host_id'],
        challenge_id = json['challenge_id'],
		video_id = json['video_id'],
		video_url = json['video_url'],
        votes = json['votes'];

  // VideoInfo.getValue(params) {
  //    host_id = params[host_id];
  //    challenge_id = params[challenge_id];
  //    video_id = params[video_id];
  //    video_url = params[video_url];
  //    votes = params[votes];
  // }
}

class Pepole{
  String name;
  int age;
  Pepole(this.name,this.age);
}