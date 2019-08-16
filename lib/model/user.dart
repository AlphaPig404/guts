class User {
  final int uid;
  final String accessToken;
  final String refreshToken;

  User(this.uid, this.accessToken, this.refreshToken);

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        accessToken = json['access_token'],
        refreshToken = json['refresh_token'];

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'access_token': accessToken, 'refresh_token': refreshToken};
}

enum Role{
	player,
	watcher
}
