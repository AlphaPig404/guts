class ExploreVideo {
  final int hostId;
  final int chanllengeId;
  final int videoId;
  final String videoUrl;
  final int votes;

  ExploreVideo(
      {this.hostId,
      this.chanllengeId,
      this.videoId,
      this.videoUrl,
      this.votes});

  ExploreVideo.fromJson(Map<String, dynamic> json)
      : hostId = json['host_id'],
        chanllengeId = json['chanllenge_id'],
        videoId = json['video_id'],
        videoUrl = json['video_url'],
        votes = json['votes'];
}
