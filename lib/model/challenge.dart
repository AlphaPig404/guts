class Challenge{
	final int id;
	final String title;
	final String description;
	final String cover;
	final int point;
	final int expireTime;
	final String level;
	final int status;
	
	Challenge(this.id, this.title, this.description, this.cover, this.point, this.expireTime, this.level, this.status);
	Challenge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
		description = json['description'],
		cover = json['cover'],
        point = json['point'],
        expireTime = json['expire_time'],
		level = json['level'],
		status = json['status'];
}