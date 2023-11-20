class ChatUser {
  ChatUser({
    required this.avatar,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.background,
    required this.dateOfBirth,
    required this.gender,
  });
  late String avatar;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String background;
  late String dateOfBirth;
  late String gender;

  ChatUser.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    background = json['background'] ?? '';
    gender = json['gender'] ?? '';
    dateOfBirth = json['dateOfBirth'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['background'] = background;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    return data;
  }
}